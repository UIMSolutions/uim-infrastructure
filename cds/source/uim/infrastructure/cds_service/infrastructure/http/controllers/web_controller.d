module uim.infrastructure.cds_service.infrastructure.http.controllers.web_controller;

import uim.infrastructure.cds_service.application.dto.definition_command : CdsFieldCommand,
    CreateDefinitionCommand;
import uim.infrastructure.cds_service.application.usecases.create_definition : CreateDefinitionUseCase;
import uim.infrastructure.cds_service.application.usecases.get_definition : GetDefinitionUseCase;
import uim.infrastructure.cds_service.application.usecases.list_definitions : ListDefinitionsUseCase;
import uim.infrastructure.cds_service.domain.entities.cds_definition : CdsDefinition;
import uim.infrastructure.cds_service.infrastructure.http.views.html_renderer : HtmlRenderer;
import std.conv : to;
import std.string : replace, split, splitLines, startsWith, strip, toLower;
import std.uri : decodeComponent;
import vibe.http.common : HTTPStatus;
import vibe.http.router : URLRouter;
import vibe.http.server : HTTPServerRequest, HTTPServerResponse;
import vibe.stream.operations : readAllUTF8;

class WebController {
    private CreateDefinitionUseCase createUseCase;
    private ListDefinitionsUseCase listUseCase;
    private GetDefinitionUseCase getUseCase;
    private HtmlRenderer renderer;
    private string defaultNamespace;

    this(
        CreateDefinitionUseCase createUseCase,
        ListDefinitionsUseCase listUseCase,
        GetDefinitionUseCase getUseCase,
        string defaultNamespace
    ) {
        this.createUseCase = createUseCase;
        this.listUseCase = listUseCase;
        this.getUseCase = getUseCase;
        this.defaultNamespace = defaultNamespace;
        this.renderer = new HtmlRenderer();
    }

    void registerRoutes(URLRouter router) {
        router.get("/", &definitions);
        router.get("/definitions", &definitions);
        router.get("/definitions/new", &newDefinitionForm);
        router.post("/definitions/new", &newDefinitionSubmit);
        router.get("/definitions/*", &definitionDetail);
    }

    void definitions(HTTPServerRequest req, HTTPServerResponse res) {
        writeHtml(res, renderer.renderDefinitions(listUseCase.execute()), HTTPStatus.ok);
    }

    void newDefinitionForm(HTTPServerRequest req, HTTPServerResponse res) {
        writeHtml(res, renderer.renderCreateForm(defaultNamespace, "1.0.0"), HTTPStatus.ok);
    }

    void newDefinitionSubmit(HTTPServerRequest req, HTTPServerResponse res) {
        try {
            auto form = parseForm(req.bodyReader.readAllUTF8());
            auto command = toCreateCommand(form);
            auto definition = createUseCase.execute(command);
            writeHtml(
                res,
                renderer.renderCreateForm(
                    defaultNamespace,
                    "1.0.0",
                    "",
                    "Created definition " ~ definition.name ~ " (" ~ definition.id ~ ")"
                ),
                HTTPStatus.created
            );
        } catch (Exception ex) {
            writeHtml(res, renderer.renderCreateForm(defaultNamespace, "1.0.0", ex.msg), HTTPStatus.badRequest);
        }
    }

    void definitionDetail(HTTPServerRequest req, HTTPServerResponse res) {
        auto id = extractId(req.requestPath.to!string, "/definitions/");
        if (id.length == 0) {
            writeHtml(res, renderer.renderNotFound(), HTTPStatus.notFound);
            return;
        }

        auto maybe = getUseCase.execute(id);
        if (!maybe.found) {
            writeHtml(res, renderer.renderNotFound(), HTTPStatus.notFound);
            return;
        }

        writeHtml(res, renderer.renderDefinitionDetail(maybe.value, toCdsSource(maybe.value)), HTTPStatus.ok);
    }

    private CreateDefinitionCommand toCreateCommand(string[string] form) {
        CreateDefinitionCommand command;
        command.namespaceName = form.get("namespace", "").strip;
        command.name = form.get("name", "").strip;
        command.modelVersion = form.get("modelVersion", "1.0.0").strip;
        command.deprecated_ = form.get("deprecated", "false").toLower == "true";
        command.fields = parseFields(form.get("fields", ""));

        return command;
    }

    private CdsFieldCommand[] parseFields(string source) {
        CdsFieldCommand[] fields;

        foreach (line; splitLines(source)) {
            auto normalized = line.strip;
            if (normalized.length == 0) {
                continue;
            }

            auto tokens = normalized.split(":");
            if (tokens.length < 2) {
                throw new Exception("invalid field line: " ~ normalized);
            }

            auto name = tokens[0].strip;
            auto typeName = tokens[1].strip;
            bool key = false;
            bool nullable = true;

            for (size_t i = 2; i < tokens.length; ++i) {
                auto option = tokens[i].strip.toLower;
                if (option == "key") {
                    key = true;
                } else if (option == "required" || option == "notnull" || option == "not-null") {
                    nullable = false;
                }
            }

            fields ~= CdsFieldCommand(name, typeName, nullable, key);
        }

        return fields;
    }

    private string[string] parseForm(string body) {
        string[string] result;

        foreach (pair; body.split("&")) {
            if (pair.length == 0) {
                continue;
            }

            auto parts = pair.split("=");
            auto key = decodeForm(parts.length > 0 ? parts[0] : "");
            auto value = decodeForm(parts.length > 1 ? parts[1] : "");
            result[key] = value;
        }

        return result;
    }

    private string decodeForm(string value) {
        return decodeComponent(value.replace("+", " "));
    }

    private string extractId(string requestPath, string prefix) {
        if (!requestPath.startsWith(prefix)) {
            return "";
        }

        auto parts = requestPath[prefix.length .. $].split("/");
        return parts.length > 0 ? parts[0] : "";
    }

    private string toCdsSource(in CdsDefinition definition) {
        string body = "namespace " ~ definition.namespaceName ~ ";\n\n";
        body ~= "entity " ~ definition.name ~ " {\n";

        foreach (field; definition.fields) {
            body ~= "  ";
            if (field.key) {
                body ~= "key ";
            }
            body ~= field.name ~ " : " ~ field.typeName;
            if (!field.nullable) {
                body ~= " not null";
            }
            body ~= ";\n";
        }

        body ~= "}\n";
        return body;
    }

    private void writeHtml(HTTPServerResponse res, string html, HTTPStatus status) {
        res.writeBody(html, cast(int) status, "text/html; charset=utf-8");
    }
}
