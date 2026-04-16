module log_service.infrastructure.http.controllers.logging;

import log_service.application.dto.log_command : QueryLogsQuery, WriteLogCommand;
import log_service.application.usecases.list_logs : ListLogsUseCase;
import log_service.application.usecases.query_logs : QueryLogsUseCase;
import log_service.application.usecases.write_log : WriteLogUseCase;
import log_service.domain.entities.log_entry : LogEntry;
import std.array : join;
import std.conv : to;
import std.string : split, startsWith;
import vibe.data.json : serializeToJsonString;
import vibe.http.common : HTTPStatus;
import vibe.http.router : URLRouter;
import vibe.http.server : HTTPServerRequest, HTTPServerResponse;

struct LogEntryView {
    string id;
    string level;
    string message;
    string service;
    string timestamp;
}

class LoggingController {
    private WriteLogUseCase writeUseCase;
    private QueryLogsUseCase queryUseCase;
    private ListLogsUseCase listUseCase;

    this(
        WriteLogUseCase writeUseCase,
        QueryLogsUseCase queryUseCase,
        ListLogsUseCase listUseCase
    ) {
        this.writeUseCase = writeUseCase;
        this.queryUseCase = queryUseCase;
        this.listUseCase  = listUseCase;
    }

    void registerRoutes(URLRouter router) {
        router.get ("/health",        &health);
        router.get ("/v1/logs",       &listLogs);
        router.get ("/v1/logs/*",     &queryLogs);
        router.post("/v1/logs/*",     &writeLog);
    }

    // GET /health
    void health(HTTPServerRequest req, HTTPServerResponse res) {
        writeJson(res, `{ "status": "ok" }`, HTTPStatus.ok);
    }

    // GET /v1/logs
    void listLogs(HTTPServerRequest req, HTTPServerResponse res) {
        auto entries = listUseCase.execute();
        writeJson(res, serializeToJsonString(entriesToViews(entries)), HTTPStatus.ok);
    }

    // GET /v1/logs/<service>
    // GET /v1/logs/<service>/<level>
    void queryLogs(HTTPServerRequest req, HTTPServerResponse res) {
        auto segments = splitPathAfterPrefix(req.requestPath.to!string, "/v1/logs/");
        if (segments.length == 0) {
            writeJson(res, `{ "error": "expected /v1/logs/<service>[/<level>]" }`, HTTPStatus.badRequest);
            return;
        }

        try {
            auto query = QueryLogsQuery(
                segments[0],
                segments.length >= 2 ? segments[1] : ""
            );
            auto entries = queryUseCase.execute(query);
            writeJson(res, serializeToJsonString(entriesToViews(entries)), HTTPStatus.ok);
        } catch (Exception ex) {
            writeJson(res, `{ "error": "` ~ ex.msg ~ `" }`, HTTPStatus.badRequest);
        }
    }

    // POST /v1/logs/<service>/<level>/<message>
    void writeLog(HTTPServerRequest req, HTTPServerResponse res) {
        auto segments = splitPathAfterPrefix(req.requestPath.to!string, "/v1/logs/");
        if (segments.length < 3) {
            writeJson(res, `{ "error": "expected /v1/logs/<service>/<level>/<message>" }`, HTTPStatus.badRequest);
            return;
        }

        try {
            auto command = WriteLogCommand(segments[0], segments[1], segments[2 .. $].join("/"));
            auto entry   = writeUseCase.execute(command);
            writeJson(res, serializeToJsonString(entriesToViews([entry])), HTTPStatus.created);
        } catch (Exception ex) {
            writeJson(res, `{ "error": "` ~ ex.msg ~ `" }`, HTTPStatus.badRequest);
        }
    }

    private LogEntryView[] entriesToViews(scope const LogEntry[] entries) {
        LogEntryView[] views;
        foreach (e; entries) {
            views ~= LogEntryView(e.id, e.level.to!string, e.message, e.service, e.timestamp);
        }
        return views;
    }

    private string[] splitPathAfterPrefix(string requestPath, string prefix) {
        if (!requestPath.startsWith(prefix)) {
            return [];
        }
        return split(requestPath[prefix.length .. $], "/");
    }

    private void writeJson(HTTPServerResponse res, string body, HTTPStatus status) {
        res.writeBody(body, cast(int) status, "application/json");
    }
}
