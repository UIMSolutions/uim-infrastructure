module monitoring_service.infrastructure.http.controllers.monitoring;

import monitoring_service.application.dto.check_command : DeregisterCheckCommand, RegisterCheckCommand, RunCheckCommand;
import monitoring_service.application.usecases.deregister_check : DeregisterCheckUseCase;
import monitoring_service.application.usecases.list_check_results : ListCheckResultsUseCase;
import monitoring_service.application.usecases.list_checks : ListChecksUseCase;
import monitoring_service.application.usecases.register_check : RegisterCheckUseCase;
import monitoring_service.application.usecases.run_check : RunCheckUseCase;
import monitoring_service.domain.entities.check : Check;
import monitoring_service.domain.entities.check_result : CheckResult;
import std.conv : to;
import std.string : split, startsWith;
import vibe.data.json : serializeToJsonString;
import vibe.http.common : HTTPStatus;
import vibe.http.router : URLRouter;
import vibe.http.server : HTTPServerRequest, HTTPServerResponse;

struct CheckView {
    string id;
    string name;
    string host;
    ushort port;
    uint intervalSecs;
    bool active;
    string address;
}

struct CheckResultView {
    string checkId;
    bool healthy;
    uint statusCode;
    string message;
    long timestampUnix;
}

class MonitoringController {
    private RegisterCheckUseCase    registerUseCase;
    private DeregisterCheckUseCase  deregisterUseCase;
    private ListChecksUseCase       listUseCase;
    private RunCheckUseCase         runUseCase;
    private ListCheckResultsUseCase listResultsUseCase;

    this(
        RegisterCheckUseCase    registerUseCase,
        DeregisterCheckUseCase  deregisterUseCase,
        ListChecksUseCase       listUseCase,
        RunCheckUseCase         runUseCase,
        ListCheckResultsUseCase listResultsUseCase
    ) {
        this.registerUseCase    = registerUseCase;
        this.deregisterUseCase  = deregisterUseCase;
        this.listUseCase        = listUseCase;
        this.runUseCase         = runUseCase;
        this.listResultsUseCase = listResultsUseCase;
    }

    void registerRoutes(URLRouter router) {
        router.get    ("/health",              &health);
        router.get    ("/v1/checks",           &listChecks);
        router.post   ("/v1/checks/*",         &handlePost);
        router.delete_("/v1/checks/*",         &deregisterCheck);
        router.get    ("/v1/checks/*/results", &listResults);
    }

    // GET /health
    void health(HTTPServerRequest req, HTTPServerResponse res) {
        writeJson(res, `{ "status": "ok" }`, HTTPStatus.ok);
    }

    // GET /v1/checks
    void listChecks(HTTPServerRequest req, HTTPServerResponse res) {
        auto checks = listUseCase.execute();
        writeJson(res, serializeToJsonString(checksToViews(checks)), HTTPStatus.ok);
    }

    // POST /v1/checks/<id>/<name>/<host>/<port>[/<intervalSecs>]
    // POST /v1/checks/<id>/run
    void handlePost(HTTPServerRequest req, HTTPServerResponse res) {
        auto segments = splitPathAfterPrefix(req.requestPath.to!string, "/v1/checks/");

        // POST /v1/checks/<id>/run
        if (segments.length == 2 && segments[1] == "run") {
            runCheckById(req, res, segments[0]);
            return;
        }

        // POST /v1/checks/<id>/<name>/<host>/<port>[/<intervalSecs>]
        if (segments.length < 4) {
            writeJson(res,
                `{ "error": "expected /v1/checks/<id>/<name>/<host>/<port>[/<intervalSecs>] or /v1/checks/<id>/run" }`,
                HTTPStatus.badRequest);
            return;
        }

        try {
            ushort port         = segments[3].to!ushort;
            uint   intervalSecs = segments.length >= 5 ? segments[4].to!uint : 30;

            auto command = RegisterCheckCommand(segments[0], segments[1], segments[2], port, intervalSecs);
            auto check   = registerUseCase.execute(command);
            writeJson(res, serializeToJsonString(checksToViews([check])), HTTPStatus.created);
        } catch (Exception ex) {
            writeJson(res, `{ "error": "` ~ ex.msg ~ `" }`, HTTPStatus.badRequest);
        }
    }

    // DELETE /v1/checks/<id>
    void deregisterCheck(HTTPServerRequest req, HTTPServerResponse res) {
        auto segments = splitPathAfterPrefix(req.requestPath.to!string, "/v1/checks/");
        if (segments.length == 0) {
            writeJson(res, `{ "error": "expected /v1/checks/<id>" }`, HTTPStatus.badRequest);
            return;
        }

        try {
            deregisterUseCase.execute(DeregisterCheckCommand(segments[0]));
            res.writeBody("", cast(int) HTTPStatus.noContent, "application/json");
        } catch (Exception ex) {
            writeJson(res, `{ "error": "` ~ ex.msg ~ `" }`, HTTPStatus.badRequest);
        }
    }

    // GET /v1/checks/<id>/results
    void listResults(HTTPServerRequest req, HTTPServerResponse res) {
        auto segments = splitPathAfterPrefix(req.requestPath.to!string, "/v1/checks/");
        // segments: ["<id>", "results"]
        if (segments.length < 2 || segments[1] != "results") {
            writeJson(res, `{ "error": "expected /v1/checks/<id>/results" }`, HTTPStatus.badRequest);
            return;
        }

        try {
            auto results = listResultsUseCase.execute(segments[0]);
            writeJson(res, serializeToJsonString(resultsToViews(results)), HTTPStatus.ok);
        } catch (Exception ex) {
            writeJson(res, `{ "error": "` ~ ex.msg ~ `" }`, HTTPStatus.badRequest);
        }
    }

    private void runCheckById(HTTPServerRequest req, HTTPServerResponse res, string id) {
        try {
            auto result = runUseCase.execute(RunCheckCommand(id));
            writeJson(res, serializeToJsonString(resultToView(result)), HTTPStatus.ok);
        } catch (Exception ex) {
            auto status = ex.msg.startsWith("check not found") ? HTTPStatus.notFound : HTTPStatus.badRequest;
            writeJson(res, `{ "error": "` ~ ex.msg ~ `" }`, status);
        }
    }

    private CheckView[] checksToViews(scope const Check[] checks) {
        CheckView[] views;
        foreach (c; checks) {
            views ~= CheckView(c.id, c.name, c.host, c.port, c.intervalSecs, c.active, c.address());
        }
        return views;
    }

    private CheckResultView resultToView(in CheckResult r) {
        return CheckResultView(r.checkId, r.healthy, r.statusCode, r.message, r.timestampUnix);
    }

    private CheckResultView[] resultsToViews(scope const CheckResult[] results) {
        CheckResultView[] views;
        foreach (r; results) {
            views ~= resultToView(r);
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
