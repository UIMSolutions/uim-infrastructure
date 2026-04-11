module dns_service.infrastructure.http.dns_controller;

import dns_service.application.dto.record_command : RegisterRecordCommand, ResolveRecordQuery;
import dns_service.application.use_cases.list_records : ListRecordsUseCase;
import dns_service.application.use_cases.register_record : RegisterRecordUseCase;
import dns_service.application.use_cases.resolve_record : ResolveRecordUseCase;
import dns_service.domain.entities.dns_record : DNSRecord;
import std.conv : to;
import std.string : split, startsWith;
import vibe.http.router : URLRouter;
import vibe.http.server : HTTPServerRequest, HTTPServerResponse;
import vibe.http.common : HTTPStatus;
import vibe.data.json : serializeToJsonString;

struct DNSRecordView {
    string zone;
    string name;
    string fqdn;
    string recordType;
    string value;
    uint ttl;
}

class DNSController {
    private RegisterRecordUseCase registerUseCase;
    private ResolveRecordUseCase resolveUseCase;
    private ListRecordsUseCase listUseCase;

    this(RegisterRecordUseCase registerUseCase, ResolveRecordUseCase resolveUseCase, ListRecordsUseCase listUseCase) {
        this.registerUseCase = registerUseCase;
        this.resolveUseCase = resolveUseCase;
        this.listUseCase = listUseCase;
    }

    void registerRoutes(URLRouter router) {
        router.get("/health", &health);
        router.get("/v1/records", &listRecords);
        router.get("/v1/resolve/*", &resolveRecord);
        router.post("/v1/records/*", &createRecord);
    }

    void health(HTTPServerRequest req, HTTPServerResponse res) {
        writeJson(res, `{ "status": "ok" }`, HTTPStatus.ok);
    }

    void listRecords(HTTPServerRequest req, HTTPServerResponse res) {
        auto records = listUseCase.execute();
        auto payload = recordsToViews(records);
        writeJson(res, serializeToJsonString(payload), HTTPStatus.ok);
    }

    void resolveRecord(HTTPServerRequest req, HTTPServerResponse res) {
        auto segments = splitPathAfterPrefix(req.requestPath.to!string, "/v1/resolve/");
        if (segments.length != 3) {
            writeJson(res, `{ "error": "expected /v1/resolve/<zone>/<name>/<type>" }`, HTTPStatus.badRequest);
            return;
        }

        try {
            auto query = ResolveRecordQuery(segments[0], segments[1], segments[2]);
            auto records = resolveUseCase.execute(query);
            writeJson(res, serializeToJsonString(recordsToViews(records)), HTTPStatus.ok);
        } catch (Exception ex) {
            writeJson(res, `{ "error": "` ~ ex.msg ~ `" }`, HTTPStatus.badRequest);
        }
    }

    void createRecord(HTTPServerRequest req, HTTPServerResponse res) {
        auto segments = splitPathAfterPrefix(req.requestPath.to!string, "/v1/records/");
        if (segments.length != 5) {
            writeJson(res, `{ "error": "expected /v1/records/<zone>/<name>/<type>/<value>/<ttl>" }`, HTTPStatus.badRequest);
            return;
        }

        try {
            auto command = RegisterRecordCommand(segments[0], segments[1], segments[2], segments[3], segments[4].to!uint);
            auto created = registerUseCase.execute(command);
            auto payload = recordsToViews([created]);
            writeJson(res, serializeToJsonString(payload), HTTPStatus.created);
        } catch (Exception ex) {
            writeJson(res, `{ "error": "` ~ ex.msg ~ `" }`, HTTPStatus.badRequest);
        }
    }

    private DNSRecordView[] recordsToViews(scope const DNSRecord[] records) {
        DNSRecordView[] views;
        foreach (record; records) {
            views ~= DNSRecordView(record.zone, record.name, record.fqdn(), record.type.to!string, record.value, record.ttl);
        }
        return views;
    }

    private string[] splitPathAfterPrefix(string requestPath, string prefix) {
        if (!requestPath.startsWith(prefix)) {
            return [];
        }

        auto remainder = requestPath[prefix.length .. $];
        return split(remainder, "/");
    }

    private void writeJson(HTTPServerResponse res, string body, HTTPStatus status) {
        res.writeBody(body, cast(int)status, "application/json");
    }
}
