module uim.infrastructure.hts_service.infrastructure.http.controllers.web_controller;

import uim.infrastructure.hts_service.application.dto.hts_commands :
    IngestDatasetCommand, ListByReferenceCommand;
import uim.infrastructure.hts_service.application.dto.unix_auth_commands :
    CreateUserCommand, GenerateHashCommand, SetPasswordCommand;
import uim.infrastructure.hts_service.application.usecases.create_unix_user :
    CreateUnixUserUseCase;
import uim.infrastructure.hts_service.application.usecases.generate_unix_hash :
    GenerateUnixHashUseCase;
import uim.infrastructure.hts_service.application.usecases.get_unix_user :
    GetUnixUserUseCase;
import uim.infrastructure.hts_service.application.usecases.ingest_dataset :
    IngestDatasetUseCase;
import uim.infrastructure.hts_service.application.usecases.list_by_reference :
    ListByReferenceUseCase;
import uim.infrastructure.hts_service.application.usecases.list_dataset_records :
    ListDatasetRecordsUseCase;
import uim.infrastructure.hts_service.application.usecases.list_datasets :
    ListDatasetsUseCase;
import uim.infrastructure.hts_service.application.usecases.list_unix_users :
    ListUnixUsersUseCase;
import uim.infrastructure.hts_service.application.usecases.set_unix_password :
    SetUnixPasswordUseCase;
import uim.infrastructure.hts_service.domain.entities.hts_record : HtsFormat,
    HtsRecord;
import uim.infrastructure.hts_service.infrastructure.http.views.html_renderer :
    HtmlRenderer;
import std.conv : to;
import std.string : replace, split, startsWith, strip, toLower;
import std.uri : decodeComponent;
import vibe.http.common : HTTPStatus;
import vibe.http.router : URLRouter;
import vibe.http.server : HTTPServerRequest, HTTPServerResponse;
import vibe.stream.operations : readAllUTF8;

class WebController {
    private IngestDatasetUseCase ingestDatasetUseCase;
    private ListDatasetRecordsUseCase listDatasetRecordsUseCase;
    private ListByReferenceUseCase listByReferenceUseCase;
    private ListDatasetsUseCase listDatasetsUseCase;

    private ListUnixUsersUseCase listUnixUsersUseCase;
    private GetUnixUserUseCase getUnixUserUseCase;
    private CreateUnixUserUseCase createUnixUserUseCase;
    private SetUnixPasswordUseCase setUnixPasswordUseCase;
    private GenerateUnixHashUseCase generateUnixHashUseCase;

    private HtmlRenderer renderer;

    this(
        IngestDatasetUseCase ingestDatasetUseCase,
        ListDatasetRecordsUseCase listDatasetRecordsUseCase,
        ListByReferenceUseCase listByReferenceUseCase,
        ListDatasetsUseCase listDatasetsUseCase,
        ListUnixUsersUseCase listUnixUsersUseCase,
        GetUnixUserUseCase getUnixUserUseCase,
        CreateUnixUserUseCase createUnixUserUseCase,
        SetUnixPasswordUseCase setUnixPasswordUseCase,
        GenerateUnixHashUseCase generateUnixHashUseCase
    ) {
        this.ingestDatasetUseCase = ingestDatasetUseCase;
        this.listDatasetRecordsUseCase = listDatasetRecordsUseCase;
        this.listByReferenceUseCase = listByReferenceUseCase;
        this.listDatasetsUseCase = listDatasetsUseCase;
        this.listUnixUsersUseCase = listUnixUsersUseCase;
        this.getUnixUserUseCase = getUnixUserUseCase;
        this.createUnixUserUseCase = createUnixUserUseCase;
        this.setUnixPasswordUseCase = setUnixPasswordUseCase;
        this.generateUnixHashUseCase = generateUnixHashUseCase;
        this.renderer = new HtmlRenderer();
    }

    void registerRoutes(URLRouter router) {
        router.get("/", &home);

        router.get("/datasets/new", &newDatasetForm);
        router.post("/datasets/new", &newDatasetSubmit);
        router.get("/datasets/*", &datasetDetail);

        router.get("/users", &listUsers);
        router.get("/users/new", &newUserForm);
        router.post("/users/new", &newUserSubmit);
        router.get("/users/*", &userDetail);
        router.post("/users/*", &userAction);

        router.get("/hash", &hashToolForm);
        router.post("/hash", &hashToolSubmit);
    }

    void home(HTTPServerRequest req, HTTPServerResponse res) {
        writeHtml(res, renderer.renderHome(listDatasetsUseCase.execute()), HTTPStatus.ok);
    }

    void newDatasetForm(HTTPServerRequest req, HTTPServerResponse res) {
        writeHtml(res, renderer.renderIngestForm(), HTTPStatus.ok);
    }

    void newDatasetSubmit(HTTPServerRequest req, HTTPServerResponse res) {
        try {
            auto form = parseForm(req.bodyReader.readAllUTF8());
            auto summary = ingestDatasetUseCase.execute(
                IngestDatasetCommand(
                    form.get("datasetId", "").strip,
                    parseFormat(form.get("format", "sam").toLower.strip),
                    form.get("rawContent", "")
                )
            );

            writeHtml(
                res,
                renderer.renderIngestForm(
                    "",
                    "Ingested " ~ summary.datasetId ~ " with " ~ to!string(summary.totalRecords) ~ " records"
                ),
                HTTPStatus.created
            );
        } catch (Exception ex) {
            writeHtml(res, renderer.renderIngestForm(ex.msg, ""), HTTPStatus.badRequest);
        }
    }

    void datasetDetail(HTTPServerRequest req, HTTPServerResponse res) {
        auto datasetId = extractId(req.requestPath.to!string, "/datasets/");
        if (datasetId.length == 0) {
            writeHtml(res, renderer.renderNotFound("Dataset id is missing"), HTTPStatus.notFound);
            return;
        }

        string referenceFilter;
        foreach (kv; req.query.byKeyValue()) {
            if (kv.key == "reference") {
                referenceFilter = kv.value;
                break;
            }
        }

        HtsRecord[] records;
        if (referenceFilter.length > 0) {
            records = listByReferenceUseCase.execute(ListByReferenceCommand(datasetId, referenceFilter));
        } else {
            records = listDatasetRecordsUseCase.execute(datasetId);
        }

        writeHtml(res, renderer.renderDatasetDetail(datasetId, records, referenceFilter), HTTPStatus.ok);
    }

    void listUsers(HTTPServerRequest req, HTTPServerResponse res) {
        writeHtml(res, renderer.renderUnixUsers(listUnixUsersUseCase.execute()), HTTPStatus.ok);
    }

    void newUserForm(HTTPServerRequest req, HTTPServerResponse res) {
        writeHtml(res, renderer.renderCreateUserForm(), HTTPStatus.ok);
    }

    void newUserSubmit(HTTPServerRequest req, HTTPServerResponse res) {
        try {
            auto form = parseForm(req.bodyReader.readAllUTF8());
            auto created = createUnixUserUseCase.execute(
                CreateUserCommand(
                    form.get("username", "").strip,
                    form.get("uid", "0").to!uint,
                    form.get("gid", "0").to!uint,
                    form.get("gecos", "").strip,
                    form.get("homeDirectory", "").strip,
                    form.get("loginShell", "").strip,
                    form.get("password", "")
                )
            );

            writeHtml(
                res,
                renderer.renderCreateUserForm("", "Created user " ~ created.passwd.username),
                HTTPStatus.created
            );
        } catch (Exception ex) {
            writeHtml(res, renderer.renderCreateUserForm(ex.msg, ""), HTTPStatus.badRequest);
        }
    }

    void userDetail(HTTPServerRequest req, HTTPServerResponse res) {
        auto username = extractId(req.requestPath.to!string, "/users/");
        if (username.length == 0) {
            writeHtml(res, renderer.renderNotFound("Username is missing"), HTTPStatus.notFound);
            return;
        }

        auto maybe = getUnixUserUseCase.execute(username);
        if (!maybe.found) {
            writeHtml(res, renderer.renderNotFound("User not found"), HTTPStatus.notFound);
            return;
        }

        writeHtml(res, renderer.renderUnixUserDetail(maybe.value), HTTPStatus.ok);
    }

    void userAction(HTTPServerRequest req, HTTPServerResponse res) {
        auto rest = extractRest(req.requestPath.to!string, "/users/");
        auto parts = rest.split("/");

        if (parts.length == 2 && parts[1] == "password") {
            auto username = parts[0];
            auto maybe = getUnixUserUseCase.execute(username);
            if (!maybe.found) {
                writeHtml(res, renderer.renderNotFound("User not found"), HTTPStatus.notFound);
                return;
            }

            try {
                auto form = parseForm(req.bodyReader.readAllUTF8());
                auto updated = setUnixPasswordUseCase.execute(
                    SetPasswordCommand(
                        username,
                        form.get("password", ""),
                        form.get("algorithm", "sha512").toLower.strip
                    )
                );

                writeHtml(res, renderer.renderUnixUserDetail(updated, "", "Password hash updated"), HTTPStatus.ok);
                return;
            } catch (Exception ex) {
                writeHtml(res, renderer.renderUnixUserDetail(maybe.value, ex.msg, ""), HTTPStatus.badRequest);
                return;
            }
        }

        writeHtml(res, renderer.renderNotFound("Unsupported action"), HTTPStatus.notFound);
    }

    void hashToolForm(HTTPServerRequest req, HTTPServerResponse res) {
        writeHtml(res, renderer.renderHashTool(), HTTPStatus.ok);
    }

    void hashToolSubmit(HTTPServerRequest req, HTTPServerResponse res) {
        try {
            auto form = parseForm(req.bodyReader.readAllUTF8());
            auto hashResult = generateUnixHashUseCase.execute(
                GenerateHashCommand(
                    form.get("password", ""),
                    form.get("algorithm", "sha512").toLower.strip,
                    ""
                )
            );

            writeHtml(
                res,
                renderer.renderHashTool("", "Hash generated", hashResult.salt, hashResult.hash),
                HTTPStatus.ok
            );
        } catch (Exception ex) {
            writeHtml(res, renderer.renderHashTool(ex.msg, ""), HTTPStatus.badRequest);
        }
    }

    private HtsFormat parseFormat(string value) {
        switch (value) {
            case "sam":
                return HtsFormat.sam;
            case "vcf":
                return HtsFormat.vcf;
            case "fastq":
                return HtsFormat.fastq;
            default:
                throw new Exception("unsupported format: " ~ value);
        }
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
        auto rest = extractRest(requestPath, prefix);
        auto parts = rest.split("/");
        return parts.length > 0 ? parts[0] : "";
    }

    private string extractRest(string requestPath, string prefix) {
        if (!requestPath.startsWith(prefix)) {
            return "";
        }

        return requestPath[prefix.length .. $];
    }

    private void writeHtml(HTTPServerResponse res, string html, HTTPStatus status) {
        res.writeBody(html, cast(int) status, "text/html; charset=utf-8");
    }
}
