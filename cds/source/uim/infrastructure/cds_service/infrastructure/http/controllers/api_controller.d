module uim.infrastructure.cds_service.infrastructure.http.controllers.api_controller;

import uim.infrastructure.cds_service.application.dto.definition_command : CdsFieldCommand,
    CreateDefinitionCommand;
import uim.infrastructure.cds_service.application.usecases.create_definition : CreateDefinitionUseCase;
import uim.infrastructure.cds_service.application.usecases.delete_definition : DeleteDefinitionUseCase;
import uim.infrastructure.cds_service.application.usecases.get_definition : GetDefinitionUseCase;
import uim.infrastructure.cds_service.application.usecases.list_definitions : ListDefinitionsUseCase;
import uim.infrastructure.cds_service.domain.entities.cds_definition : CdsDefinition, CdsField;
import std.conv : to;
import std.string : split, startsWith;
import vibe.data.json : Json, parseJsonString, serializeToJsonString;
import vibe.http.common : HTTPStatus;
import vibe.http.router : URLRouter;
import vibe.http.server : HTTPServerRequest, HTTPServerResponse;
import vibe.stream.operations : readAllUTF8;

struct FieldView {
    string name;
    string type;
    bool nullable;
    bool key;
}

struct DefinitionView {
    string id;
    string namespaceName;
    string name;
    string modelVersion;
    bool deprecated_;
    string createdAt;
    FieldView[] fields;
    string cdsSource;
}

class ApiController {
    private CreateDefinitionUseCase createUseCase;
    private ListDefinitionsUseCase listUseCase;
    private GetDefinitionUseCase getUseCase;
    private DeleteDefinitionUseCase deleteUseCase;

    this(
        CreateDefinitionUseCase createUseCase,
        ListDefinitionsUseCase listUseCase,
        GetDefinitionUseCase getUseCase,
        DeleteDefinitionUseCase deleteUseCase
    ) {
        this.createUseCase = createUseCase;
        this.listUseCase = listUseCase;
        this.getUseCase = getUseCase;
        this.deleteUseCase = deleteUseCase;
    }

    void registerRoutes(URLRouter router) {
        router.get("/health", &health);
        router.get("/v1/definitions", &listDefinitions);
        router.post("/v1/definitions", &createDefinition);
        router.get("/v1/definitions/*", &getDefinition);
        router.delete_("/v1/definitions/*", &deleteDefinition);
    }

    void health(HTTPServerRequest req, HTTPServerResponse res) {
        writeJson(res, "{ \"status\": \"ok\" }", HTTPStatus.ok);
    }

    void listDefinitions(HTTPServerRequest req, HTTPServerResponse res) {
        auto definitions = listUseCase.execute();
        DefinitionView[] outViews;
        foreach (definition; definitions) {
            outViews ~= toView(definition);
        }
        writeJson(res, serializeToJsonString(outViews), HTTPStatus.ok);
    }

    void createDefinition(HTTPServerRequest req, HTTPServerResponse res) {
        try {
            auto payload = parseJsonString(req.bodyReader.readAllUTF8());
            auto command = toCreateCommand(payload);
            auto definition = createUseCase.execute(command);
            writeJson(res, serializeToJsonString(toView(definition)), HTTPStatus.created);
        } catch (Exception ex) {
            writeJson(res, "{ \"error\": \"" ~ ex.msg ~ "\" }", HTTPStatus.badRequest);
        }
    }

    void getDefinition(HTTPServerRequest req, HTTPServerResponse res) {
        auto id = extractId(req.requestPath.to!string, "/v1/definitions/");
        if (id.length == 0) {
            writeJson(res, "{ \"error\": \"expected /v1/definitions/<id>\" }", HTTPStatus.badRequest);
            return;
        }

        auto maybe = getUseCase.execute(id);
        if (!maybe.found) {
            writeJson(res, "{ \"error\": \"definition not found\" }", HTTPStatus.notFound);
            return;
        }

        writeJson(res, serializeToJsonString(toView(maybe.value)), HTTPStatus.ok);
    }

    void deleteDefinition(HTTPServerRequest req, HTTPServerResponse res) {
        auto id = extractId(req.requestPath.to!string, "/v1/definitions/");
        if (id.length == 0) {
            writeJson(res, "{ \"error\": \"expected /v1/definitions/<id>\" }", HTTPStatus.badRequest);
            return;
        }

        try {
            deleteUseCase.execute(id);
            res.writeBody("", cast(int) HTTPStatus.noContent, "application/json");
        } catch (Exception ex) {
            writeJson(res, "{ \"error\": \"" ~ ex.msg ~ "\" }", HTTPStatus.badRequest);
        }
    }

    private CreateDefinitionCommand toCreateCommand(Json json) {
        CreateDefinitionCommand command;
        command.namespaceName = requiredString(json, "namespace");
        command.name = requiredString(json, "name");
        command.modelVersion = "modelVersion" in json ? json["modelVersion"].get!string : "1.0.0";
        command.deprecated_ = "deprecated" in json ? json["deprecated"].get!bool : false;

        if (!("fields" in json)) {
            throw new Exception("fields are required");
        }

        foreach (fieldJson; json["fields"]) {
            CdsFieldCommand field;
            field.name = requiredString(fieldJson, "name");
            field.typeName = requiredString(fieldJson, "type");
            field.nullable = "nullable" in fieldJson ? fieldJson["nullable"].get!bool : true;
            field.key = "key" in fieldJson ? fieldJson["key"].get!bool : false;
            command.fields ~= field;
        }

        return command;
    }

    private string requiredString(Json json, string key) {
        if (!(key in json)) {
            throw new Exception(key ~ " is required");
        }
        auto value = json[key].get!string;
        if (value.length == 0) {
            throw new Exception(key ~ " cannot be empty");
        }
        return value;
    }

    private DefinitionView toView(in CdsDefinition definition) {
        FieldView[] fieldViews;
        foreach (field; definition.fields) {
            fieldViews ~= FieldView(field.name, field.typeName, field.nullable, field.key);
        }

        return DefinitionView(
            definition.id,
            definition.namespaceName,
            definition.name,
            definition.modelVersion,
            definition.deprecated_,
            definition.createdAt.toISOExtString(),
            fieldViews,
            toCdsSource(definition)
        );
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

    private string extractId(string requestPath, string prefix) {
        if (!requestPath.startsWith(prefix)) {
            return "";
        }
        auto segments = split(requestPath[prefix.length .. $], "/");
        return segments.length > 0 ? segments[0] : "";
    }

    private void writeJson(HTTPServerResponse res, string body_, HTTPStatus status) {
        res.writeBody(body_, cast(int) status, "application/json");
    }
}
