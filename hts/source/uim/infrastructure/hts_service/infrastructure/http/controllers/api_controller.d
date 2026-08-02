module uim.infrastructure.hts_service.infrastructure.http.controllers.api_controller;

import uim.infrastructure.hts_service.application.dto.hts_commands :
    IngestDatasetCommand, ListByReferenceCommand;
import uim.infrastructure.hts_service.application.dto.unix_auth_commands :
    CreateUserCommand, GenerateHashCommand, SetPasswordCommand,
    VerifyPasswordCommand;
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
import uim.infrastructure.hts_service.application.usecases.verify_unix_password :
    VerifyUnixPasswordUseCase;
import uim.infrastructure.hts_service.domain.entities.hts_record : HtsFormat,
    HtsRecord;
import uim.infrastructure.hts_service.domain.entities.unix_user : UnixUser;
import std.conv : to;
import std.string : split, startsWith, toLower;
import vibe.data.json : Json, parseJsonString, serializeToJsonString;
import vibe.http.common : HTTPStatus;
import vibe.http.router : URLRouter;
import vibe.http.server : HTTPServerRequest, HTTPServerResponse;
import vibe.stream.operations : readAllUTF8;

struct HtsRecordView {
    string id;
    string datasetId;
    string format;
    string referenceName;
    long position;
    string sampleName;
    string payload;
}

struct UnixUserView {
    string username;
    uint uid;
    uint gid;
    string gecos;
    string homeDirectory;
    string loginShell;
    bool hasShadow;
    bool locked;
    string passwordHash;
    long lastChangeDay;
}

class ApiController {
    private IngestDatasetUseCase ingestDatasetUseCase;
    private ListDatasetRecordsUseCase listDatasetRecordsUseCase;
    private ListByReferenceUseCase listByReferenceUseCase;
    private ListDatasetsUseCase listDatasetsUseCase;

    private ListUnixUsersUseCase listUnixUsersUseCase;
    private GetUnixUserUseCase getUnixUserUseCase;
    private CreateUnixUserUseCase createUnixUserUseCase;
    private SetUnixPasswordUseCase setUnixPasswordUseCase;
    private GenerateUnixHashUseCase generateUnixHashUseCase;
    private VerifyUnixPasswordUseCase verifyUnixPasswordUseCase;

    this(
        IngestDatasetUseCase ingestDatasetUseCase,
        ListDatasetRecordsUseCase listDatasetRecordsUseCase,
        ListByReferenceUseCase listByReferenceUseCase,
        ListDatasetsUseCase listDatasetsUseCase,
        ListUnixUsersUseCase listUnixUsersUseCase,
        GetUnixUserUseCase getUnixUserUseCase,
        CreateUnixUserUseCase createUnixUserUseCase,
        SetUnixPasswordUseCase setUnixPasswordUseCase,
        GenerateUnixHashUseCase generateUnixHashUseCase,
        VerifyUnixPasswordUseCase verifyUnixPasswordUseCase
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
        this.verifyUnixPasswordUseCase = verifyUnixPasswordUseCase;
    }

    void registerRoutes(URLRouter router) {
        router.get("/health", &health);

        router.get("/v1/hts/datasets", &listDatasets);
        router.post("/v1/hts/datasets", &ingestDataset);
        router.get("/v1/hts/datasets/*", &listDatasetRecords);
        router.get("/v1/hts/query/reference", &listByReference);

        router.get("/v1/unix/users", &listUnixUsers);
        router.get("/v1/unix/users/*", &getUnixUser);
        router.post("/v1/unix/users", &createUnixUser);
        router.post("/v1/unix/users/*", &unixUserAction);
        router.post("/v1/unix/hash", &generateUnixHash);
        router.post("/v1/unix/verify", &verifyUnixPassword);
    }

    void health(HTTPServerRequest req, HTTPServerResponse res) {
        writeJson(res, "{ \"status\": \"ok\", \"service\": \"uim-hts-service\" }", HTTPStatus.ok);
    }

    void listDatasets(HTTPServerRequest req, HTTPServerResponse res) {
        writeJson(res, serializeToJsonString(listDatasetsUseCase.execute()), HTTPStatus.ok);
    }

    void ingestDataset(HTTPServerRequest req, HTTPServerResponse res) {
        try {
            auto payload = parseJsonString(req.bodyReader.readAllUTF8());
            auto summary = ingestDatasetUseCase.execute(
                IngestDatasetCommand(
                    requiredString(payload, "datasetId"),
                    parseFormat(requiredString(payload, "format")),
                    requiredString(payload, "rawContent")
                )
            );

            writeJson(res, serializeToJsonString(summary), HTTPStatus.created);
        } catch (Exception ex) {
            writeJson(res, "{ \"error\": \"" ~ ex.msg ~ "\" }", HTTPStatus.badRequest);
        }
    }

    void listDatasetRecords(HTTPServerRequest req, HTTPServerResponse res) {
        auto datasetId = extractId(req.requestPath.to!string, "/v1/hts/datasets/");
        if (datasetId.length == 0) {
            writeJson(res, "{ \"error\": \"datasetId is required\" }", HTTPStatus.badRequest);
            return;
        }

        HtsRecordView[] views;
        foreach (record; listDatasetRecordsUseCase.execute(datasetId)) {
            views ~= toView(record);
        }
        writeJson(res, serializeToJsonString(views), HTTPStatus.ok);
    }

    void listByReference(HTTPServerRequest req, HTTPServerResponse res) {
        string datasetId;
        string referenceName;

        foreach (kv; req.query.byKeyValue()) {
            if (kv.key == "datasetId") datasetId = kv.value;
            if (kv.key == "reference") referenceName = kv.value;
        }

        try {
            HtsRecordView[] views;
            foreach (record; listByReferenceUseCase.execute(ListByReferenceCommand(datasetId, referenceName))) {
                views ~= toView(record);
            }
            writeJson(res, serializeToJsonString(views), HTTPStatus.ok);
        } catch (Exception ex) {
            writeJson(res, "{ \"error\": \"" ~ ex.msg ~ "\" }", HTTPStatus.badRequest);
        }
    }

    void listUnixUsers(HTTPServerRequest req, HTTPServerResponse res) {
        UnixUserView[] views;
        foreach (user; listUnixUsersUseCase.execute()) {
            views ~= toView(user);
        }

        writeJson(res, serializeToJsonString(views), HTTPStatus.ok);
    }

    void getUnixUser(HTTPServerRequest req, HTTPServerResponse res) {
        auto username = extractId(req.requestPath.to!string, "/v1/unix/users/");
        if (username.length == 0) {
            writeJson(res, "{ \"error\": \"username is required\" }", HTTPStatus.badRequest);
            return;
        }

        auto maybe = getUnixUserUseCase.execute(username);
        if (!maybe.found) {
            writeJson(res, "{ \"error\": \"user not found\" }", HTTPStatus.notFound);
            return;
        }

        writeJson(res, serializeToJsonString(toView(maybe.value)), HTTPStatus.ok);
    }

    void createUnixUser(HTTPServerRequest req, HTTPServerResponse res) {
        try {
            auto payload = parseJsonString(req.bodyReader.readAllUTF8());
            auto created = createUnixUserUseCase.execute(
                CreateUserCommand(
                    requiredString(payload, "username"),
                    requiredUInt(payload, "uid"),
                    requiredUInt(payload, "gid"),
                    optionalString(payload, "gecos", ""),
                    requiredString(payload, "homeDirectory"),
                    requiredString(payload, "loginShell"),
                    requiredString(payload, "password")
                )
            );

            writeJson(res, serializeToJsonString(toView(created)), HTTPStatus.created);
        } catch (Exception ex) {
            writeJson(res, "{ \"error\": \"" ~ ex.msg ~ "\" }", HTTPStatus.badRequest);
        }
    }

    void unixUserAction(HTTPServerRequest req, HTTPServerResponse res) {
        auto rest = extractRest(req.requestPath.to!string, "/v1/unix/users/");
        auto parts = rest.split("/");

        if (parts.length == 2 && parts[1] == "password") {
            try {
                auto payload = parseJsonString(req.bodyReader.readAllUTF8());
                auto updated = setUnixPasswordUseCase.execute(
                    SetPasswordCommand(
                        parts[0],
                        requiredString(payload, "password"),
                        optionalString(payload, "algorithm", "sha512")
                    )
                );
                writeJson(res, serializeToJsonString(toView(updated)), HTTPStatus.ok);
                return;
            } catch (Exception ex) {
                writeJson(res, "{ \"error\": \"" ~ ex.msg ~ "\" }", HTTPStatus.badRequest);
                return;
            }
        }

        writeJson(res, "{ \"error\": \"unsupported action\" }", HTTPStatus.notFound);
    }

    void generateUnixHash(HTTPServerRequest req, HTTPServerResponse res) {
        try {
            auto payload = parseJsonString(req.bodyReader.readAllUTF8());
            auto hashResult = generateUnixHashUseCase.execute(
                GenerateHashCommand(
                    requiredString(payload, "password"),
                    optionalString(payload, "algorithm", "sha512"),
                    optionalString(payload, "salt", "")
                )
            );
            writeJson(res, serializeToJsonString(hashResult), HTTPStatus.ok);
        } catch (Exception ex) {
            writeJson(res, "{ \"error\": \"" ~ ex.msg ~ "\" }", HTTPStatus.badRequest);
        }
    }

    void verifyUnixPassword(HTTPServerRequest req, HTTPServerResponse res) {
        try {
            auto payload = parseJsonString(req.bodyReader.readAllUTF8());
            auto valid = verifyUnixPasswordUseCase.execute(
                VerifyPasswordCommand(
                    requiredString(payload, "password"),
                    requiredString(payload, "existingHash")
                )
            );

            Json response = Json.emptyObject;
            response["valid"] = Json(valid);
            writeJson(res, serializeToJsonString(response), HTTPStatus.ok);
        } catch (Exception ex) {
            writeJson(res, "{ \"error\": \"" ~ ex.msg ~ "\" }", HTTPStatus.badRequest);
        }
    }

    private HtsRecordView toView(in HtsRecord record) {
        return HtsRecordView(
            record.id,
            record.datasetId,
            record.format.to!string,
            record.referenceName,
            record.position,
            record.sampleName,
            record.payload
        );
    }

    private UnixUserView toView(in UnixUser user) {
        return UnixUserView(
            user.passwd.username,
            user.passwd.uid,
            user.passwd.gid,
            user.passwd.gecos,
            user.passwd.homeDirectory,
            user.passwd.loginShell,
            user.hasShadow,
            user.hasShadow ? user.shadow.locked() : false,
            user.hasShadow ? user.shadow.passwordHash : "",
            user.hasShadow ? user.shadow.lastChangeDay : -1
        );
    }

    private HtsFormat parseFormat(string value) {
        auto v = value.toLower();
        switch (v) {
            case "sam":
                return HtsFormat.sam;
            case "vcf":
                return HtsFormat.vcf;
            case "fastq":
                return HtsFormat.fastq;
            default:
                throw new Exception("unsupported format: " ~ value ~ ". expected sam, vcf, or fastq");
        }
    }

    private string requiredString(Json j, string key) {
        if (!(key in j)) {
            throw new Exception(key ~ " is required");
        }
        auto value = j[key].get!string;
        if (value.length == 0) {
            throw new Exception(key ~ " cannot be empty");
        }
        return value;
    }

    private string optionalString(Json j, string key, string fallback) {
        if (!(key in j)) {
            return fallback;
        }
        return j[key].get!string;
    }

    private uint requiredUInt(Json j, string key) {
        if (!(key in j)) {
            throw new Exception(key ~ " is required");
        }
        return j[key].get!uint;
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

    private void writeJson(HTTPServerResponse res, string body_, HTTPStatus status) {
        res.writeBody(body_, cast(int) status, "application/json");
    }
}
