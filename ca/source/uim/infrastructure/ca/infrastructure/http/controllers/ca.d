/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.infrastructure.ca.infrastructure.http.controllers.ca;

import uim.infrastructure.ca.application.dto.commands;
import uim.infrastructure.ca.application.usecases.initialize_ca : InitializeCaUseCase;
import uim.infrastructure.ca.application.usecases.get_ca : GetCaUseCase;
import uim.infrastructure.ca.application.usecases.issue_certificate : IssueCertificateUseCase;
import uim.infrastructure.ca.application.usecases.list_certificates : ListCertificatesUseCase;
import uim.infrastructure.ca.application.usecases.get_certificate : GetCertificateUseCase;
import uim.infrastructure.ca.application.usecases.revoke_certificate : RevokeCertificateUseCase;
import uim.infrastructure.ca.domain.entities.ca_state : CaState;
import uim.infrastructure.ca.domain.entities.certificate : Certificate;
import std.conv : to;
import std.string : split, startsWith;
import vibe.http.router : URLRouter;
import vibe.http.server : HTTPServerRequest, HTTPServerResponse;
import vibe.http.common : HTTPStatus;
import vibe.data.json : Json, serializeToJsonString;

struct CaView {
    string id;
    string name;
    string commonName;
    string serialNumber;
    string createdAt;
    uint validDays;
    string certPem;
}

struct CertificateView {
    string id;
    string commonName;
    string[] subjectAltNames;
    string serialNumber;
    string status;
    string createdAt;
    string notBefore;
    string notAfter;
    string revokedAt;
    string revokedReason;
    string namespaceName;
    string certPem;
    string keyPem;
    string chainPem;
}

class CaController {
    private InitializeCaUseCase initializeCaUC;
    private GetCaUseCase getCaUC;
    private IssueCertificateUseCase issueCertificateUC;
    private ListCertificatesUseCase listCertificatesUC;
    private GetCertificateUseCase getCertificateUC;
    private RevokeCertificateUseCase revokeCertificateUC;

    this(
        InitializeCaUseCase initializeCaUC,
        GetCaUseCase getCaUC,
        IssueCertificateUseCase issueCertificateUC,
        ListCertificatesUseCase listCertificatesUC,
        GetCertificateUseCase getCertificateUC,
        RevokeCertificateUseCase revokeCertificateUC
    ) {
        this.initializeCaUC = initializeCaUC;
        this.getCaUC = getCaUC;
        this.issueCertificateUC = issueCertificateUC;
        this.listCertificatesUC = listCertificatesUC;
        this.getCertificateUC = getCertificateUC;
        this.revokeCertificateUC = revokeCertificateUC;
    }

    void registerRoutes(URLRouter router) {
        router.get("/health", &health);

        router.post("/v1/ca/init", &initializeCa);
        router.get("/v1/ca", &getCa);

        router.post("/v1/certificates", &issueCertificate);
        router.get("/v1/certificates", &listCertificates);
        router.get("/v1/certificates/*", &getCertificate);
        router.post("/v1/certificates/*", &certificateAction);
    }

    void health(HTTPServerRequest req, HTTPServerResponse res) {
        writeJson(res, "{\"status\":\"ok\",\"service\":\"uim-ca-service\"}", HTTPStatus.ok);
    }

    void initializeCa(HTTPServerRequest req, HTTPServerResponse res) {
        try {
            auto json = req.json;
            auto cmd = InitializeCaCommand(
                jsonString(json, "name"),
                jsonString(json, "common_name"),
                jsonUint(json, "valid_days")
            );

            auto state = initializeCaUC.execute(cmd);
            writeJson(res, serializeToJsonString(toCaView(state)), HTTPStatus.created);
        } catch (Exception ex) {
            writeError(res, ex.msg, HTTPStatus.badRequest);
        }
    }

    void getCa(HTTPServerRequest req, HTTPServerResponse res) {
        auto ptr = getCaUC.execute();
        if (ptr is null) {
            writeError(res, "CA is not initialized", HTTPStatus.notFound);
            return;
        }

        writeJson(res, serializeToJsonString(toCaView(*ptr)), HTTPStatus.ok);
    }

    void issueCertificate(HTTPServerRequest req, HTTPServerResponse res) {
        try {
            auto json = req.json;
            auto cmd = IssueCertificateCommand(
                jsonString(json, "common_name"),
                jsonStringArray(json, "subject_alt_names"),
                jsonUint(json, "valid_days"),
                jsonString(json, "namespace")
            );

            auto certificate = issueCertificateUC.execute(cmd);
            writeJson(res, serializeToJsonString(toCertificateView(certificate)), HTTPStatus.created);
        } catch (Exception ex) {
            writeError(res, ex.msg, HTTPStatus.badRequest);
        }
    }

    void listCertificates(HTTPServerRequest req, HTTPServerResponse res) {
        string namespaceName = "";
        foreach (kv; req.query.byKeyValue()) {
            if (kv.key == "namespace") {
                namespaceName = kv.value;
                break;
            }
        }

        auto entries = listCertificatesUC.execute(namespaceName);
        CertificateView[] views;
        foreach (ref entry; entries) {
            views ~= toCertificateView(entry);
        }

        writeJson(res, serializeToJsonString(views), HTTPStatus.ok);
    }

    void getCertificate(HTTPServerRequest req, HTTPServerResponse res) {
        auto path = req.requestPath.to!string;
        auto id = extractId(path, "/v1/certificates/");
        if (id.length == 0) {
            writeError(res, "missing certificate id", HTTPStatus.badRequest);
            return;
        }

        auto ptr = getCertificateUC.execute(id);
        if (ptr is null) {
            writeError(res, "certificate not found", HTTPStatus.notFound);
            return;
        }

        writeJson(res, serializeToJsonString(toCertificateView(*ptr)), HTTPStatus.ok);
    }

    void certificateAction(HTTPServerRequest req, HTTPServerResponse res) {
        auto path = req.requestPath.to!string;
        auto rest = extractRest(path, "/v1/certificates/");
        auto parts = rest.split("/");

        if (parts.length == 2 && parts[1] == "revoke") {
            try {
                auto json = req.json;
                auto cmd = RevokeCertificateCommand(parts[0], jsonString(json, "reason"));
                revokeCertificateUC.execute(cmd);
                res.writeBody("", cast(int) HTTPStatus.noContent, "application/json");
                return;
            } catch (Exception ex) {
                writeError(res, ex.msg, HTTPStatus.badRequest);
                return;
            }
        }

        writeError(res, "unsupported certificate action", HTTPStatus.notFound);
    }

    private string extractId(string path, string prefix) {
        auto rest = extractRest(path, prefix);
        if (rest.length == 0) return "";

        auto parts = rest.split("/");
        if (parts.length > 0 && parts[0].length > 0)
            return parts[0];

        return "";
    }

    private string extractRest(string path, string prefix) {
        if (path.startsWith(prefix) && path.length > prefix.length) {
            return path[prefix.length .. $];
        }
        return "";
    }

    private void writeJson(HTTPServerResponse res, string body_, HTTPStatus status) {
        res.writeBody(body_, cast(int) status, "application/json");
    }

    private void writeError(HTTPServerResponse res, string message, HTTPStatus status) {
        writeJson(res, "{\"error\":\"" ~ message ~ "\"}", status);
    }

    private string jsonString(Json json, string key) {
        if (json.type != Json.Type.object) return "";
        auto value = json[key];
        if (value.type == Json.Type.string) return value.get!string;
        return "";
    }

    private uint jsonUint(Json json, string key) {
        if (json.type != Json.Type.object) return 0;
        auto value = json[key];
        if (value.type == Json.Type.int_) return cast(uint) value.get!long;
        return 0;
    }

    private string[] jsonStringArray(Json json, string key) {
        if (json.type != Json.Type.object) return [];
        auto value = json[key];
        if (value.type != Json.Type.array) return [];

        string[] result;
        foreach (entry; value.byValue()) {
            if (entry.type == Json.Type.string)
                result ~= entry.get!string;
        }
        return result;
    }

    private CaView toCaView(in CaState state) {
        return CaView(
            state.id,
            state.name,
            state.commonName,
            state.serialNumber,
            state.createdAt,
            state.validDays,
            state.certPem
        );
    }

    private CertificateView toCertificateView(in Certificate certificate) {
        return CertificateView(
            certificate.id,
            certificate.commonName,
            certificate.subjectAltNames.dup,
            certificate.serialNumber,
            certificate.status.to!string,
            certificate.createdAt,
            certificate.notBefore,
            certificate.notAfter,
            certificate.revokedAt,
            certificate.revokedReason,
            certificate.namespace,
            certificate.certPem,
            certificate.keyPem,
            certificate.chainPem
        );
    }
}
