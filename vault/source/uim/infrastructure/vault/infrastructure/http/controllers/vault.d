module uim.infrastructure.vault.infrastructure.http.controllers.vault;

import std.conv : to;
import uim.infrastructure.vault.application.dto.vault_command : CreateSecretCommand, IssueCertificateCommand;
import uim.infrastructure.vault.application.usecases.create_secret : CreateSecretUseCase;
import uim.infrastructure.vault.application.usecases.get_secret : GetSecretUseCase;
import uim.infrastructure.vault.application.usecases.issue_certificate : IssueCertificateUseCase;
import uim.infrastructure.vault.application.usecases.list_secrets : ListSecretsUseCase;
import uim.infrastructure.vault.application.usecases.revoke_certificate : RevokeCertificateUseCase;
import uim.infrastructure.vault.domain.entities.secret_record : SecretRecord, CertificateRecord;
import vibe.data.json : Json, serializeToJsonString;
import vibe.http.common : HTTPStatus;
import vibe.http.router : URLRouter;
import vibe.http.server : HTTPServerRequest, HTTPServerResponse;

class VaultController {
    private string serverName;
    private string serverVersion;
    private ListSecretsUseCase listSecretsUseCase;
    private GetSecretUseCase getSecretUseCase;
    private CreateSecretUseCase createSecretUseCase;
    private IssueCertificateUseCase issueCertificateUseCase;
    private RevokeCertificateUseCase revokeCertificateUseCase;

    this(
        string serverName,
        string serverVersion,
        ListSecretsUseCase listSecretsUseCase,
        GetSecretUseCase getSecretUseCase,
        CreateSecretUseCase createSecretUseCase,
        IssueCertificateUseCase issueCertificateUseCase,
        RevokeCertificateUseCase revokeCertificateUseCase
    ) {
        this.serverName = serverName;
        this.serverVersion = serverVersion;
        this.listSecretsUseCase = listSecretsUseCase;
        this.getSecretUseCase = getSecretUseCase;
        this.createSecretUseCase = createSecretUseCase;
        this.issueCertificateUseCase = issueCertificateUseCase;
        this.revokeCertificateUseCase = revokeCertificateUseCase;
    }

    void registerRoutes(URLRouter router) {
        router.get("/health", &health);
        router.get("/v1/secrets", &listSecrets);
        router.post("/v1/secrets", &createSecret);
        router.get("/v1/secrets/*", &getSecret);
        router.post("/v1/certificates", &issueCertificate);
        router.post("/v1/certificates/*/revoke", &revokeCertificate);
    }

    void health(HTTPServerRequest req, HTTPServerResponse res) {
        Json payload = Json.emptyObject;
        payload["status"] = Json("ok");
        payload["server"] = Json(serverName);
        payload["version"] = Json(serverVersion);
        payload["description"] = Json("Identity-based secret lifecycle service for humans, machines, and AI agents.");
        writeJson(res, serializeToJsonString(payload), HTTPStatus.ok);
    }

    void listSecrets(HTTPServerRequest req, HTTPServerResponse res) {
        auto records = listSecretsUseCase.execute();
        Json payload = Json.emptyObject;
        payload["secrets"] = secretsToJson(records);
        writeJson(res, serializeToJsonString(payload), HTTPStatus.ok);
    }

    void createSecret(HTTPServerRequest req, HTTPServerResponse res) {
        auto body = req.json;

        auto path = readString(body, "path", "");
        auto value = readString(body, "value", "");
        auto ownerIdentity = readString(body, "owner_identity", "");
        auto category = readString(body, "category", "secret");
        auto ttlSeconds = readUint(body, "ttl_seconds", 0);

        if (path.length == 0 || value.length == 0 || ownerIdentity.length == 0) {
            writeError(res, HTTPStatus.badRequest, "path, value and owner_identity are required");
            return;
        }

        auto created = createSecretUseCase.execute(
            CreateSecretCommand(path, value, ownerIdentity, category, ttlSeconds)
        );

        Json payload = Json.emptyObject;
        payload["secret"] = secretToJson(created);
        writeJson(res, serializeToJsonString(payload), HTTPStatus.created);
    }

    void getSecret(HTTPServerRequest req, HTTPServerResponse res) {
        auto id = readWildcardId(req.requestPath.to!string, "/v1/secrets/");
        if (id.length == 0) {
            writeError(res, HTTPStatus.badRequest, "expected /v1/secrets/<id>");
            return;
        }

        auto found = getSecretUseCase.execute(id);
        if (found is null) {
            writeError(res, HTTPStatus.notFound, "secret not found");
            return;
        }

        Json payload = Json.emptyObject;
        payload["secret"] = secretToJson(*found);
        writeJson(res, serializeToJsonString(payload), HTTPStatus.ok);
    }

    void issueCertificate(HTTPServerRequest req, HTTPServerResponse res) {
        auto body = req.json;

        auto commonName = readString(body, "common_name", "");
        auto ownerIdentity = readString(body, "owner_identity", "");
        auto ttlSeconds = readUint(body, "ttl_seconds", 0);

        if (commonName.length == 0 || ownerIdentity.length == 0) {
            writeError(res, HTTPStatus.badRequest, "common_name and owner_identity are required");
            return;
        }

        auto issued = issueCertificateUseCase.execute(
            IssueCertificateCommand(commonName, ownerIdentity, ttlSeconds)
        );

        Json payload = Json.emptyObject;
        payload["certificate"] = certificateToJson(issued);
        writeJson(res, serializeToJsonString(payload), HTTPStatus.created);
    }

    void revokeCertificate(HTTPServerRequest req, HTTPServerResponse res) {
        auto serial = readWildcardId(req.requestPath.to!string, "/v1/certificates/");
        auto marker = "/revoke";
        if (serial.length >= marker.length && serial[$ - marker.length .. $] == marker) {
            serial = serial[0 .. $ - marker.length];
        }

        if (serial.length == 0) {
            writeError(res, HTTPStatus.badRequest, "expected /v1/certificates/<serial>/revoke");
            return;
        }

        auto changed = revokeCertificateUseCase.execute(serial);
        if (!changed) {
            writeError(res, HTTPStatus.notFound, "certificate not found");
            return;
        }

        Json payload = Json.emptyObject;
        payload["status"] = Json("revoked");
        payload["serial"] = Json(serial);
        writeJson(res, serializeToJsonString(payload), HTTPStatus.ok);
    }

    private string readWildcardId(string requestPath, string prefix) {
        if (requestPath.length <= prefix.length || requestPath[0 .. prefix.length] != prefix) {
            return "";
        }
        return requestPath[prefix.length .. $];
    }

    private string readString(Json root, string key, string fallback) {
        auto value = root[key];
        if (value.type == Json.Type.string) {
            return value.get!string;
        }
        return fallback;
    }

    private uint readUint(Json root, string key, uint fallback) {
        auto value = root[key];
        final switch (value.type) {
            case Json.Type.int_:
                return cast(uint) value.get!long;
            case Json.Type.float_:
                return cast(uint) value.get!double;
            case Json.Type.string:
                try {
                    return value.get!string.to!uint;
                } catch (Exception) {
                    return fallback;
                }
            case Json.Type.undefined:
            case Json.Type.null_:
            case Json.Type.bigInt:
            case Json.Type.bool_:
            case Json.Type.array:
            case Json.Type.object:
                return fallback;
        }
    }

    private Json secretsToJson(SecretRecord[] records) {
        Json[] entries;
        foreach (record; records) {
            entries ~= secretToJson(record);
        }
        return Json(entries);
    }

    private Json secretToJson(SecretRecord record) {
        Json json = Json.emptyObject;
        json["id"] = Json(record.id);
        json["path"] = Json(record.path);
        json["owner_identity"] = Json(record.ownerIdentity);
        json["category"] = Json(record.category);
        json["created_at_epoch"] = Json(cast(long) record.createdAtEpoch);
        json["expires_at_epoch"] = Json(cast(long) record.expiresAtEpoch);
        json["redacted_value"] = Json("***");
        return json;
    }

    private Json certificateToJson(CertificateRecord record) {
        Json json = Json.emptyObject;
        json["serial"] = Json(record.serial);
        json["common_name"] = Json(record.commonName);
        json["owner_identity"] = Json(record.ownerIdentity);
        json["issued_at_epoch"] = Json(cast(long) record.issuedAtEpoch);
        json["expires_at_epoch"] = Json(cast(long) record.expiresAtEpoch);
        json["revoked"] = Json(record.revoked);
        return json;
    }

    private void writeError(HTTPServerResponse res, HTTPStatus status, string message) {
        Json payload = Json.emptyObject;
        payload["error"] = Json(message);
        writeJson(res, serializeToJsonString(payload), status);
    }

    private void writeJson(HTTPServerResponse res, string body, HTTPStatus status) {
        res.writeBody(body, cast(int) status, "application/json");
    }
}
