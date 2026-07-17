module uim.infrastructure.jenkins.infrastructure.http.controllers.jenkins;

import jenkins_service.application.dto.commands;
import jenkins_service.application.use_cases.create_pipeline : CreatePipelineUseCase;
import jenkins_service.application.use_cases.list_pipelines : ListPipelinesUseCase;
import jenkins_service.application.use_cases.get_pipeline : GetPipelineUseCase;
import jenkins_service.application.use_cases.delete_pipeline : DeletePipelineUseCase;
import jenkins_service.application.use_cases.trigger_build : TriggerBuildUseCase;
import jenkins_service.application.use_cases.get_build : GetBuildUseCase;
import jenkins_service.application.use_cases.list_builds : ListBuildsUseCase;
import jenkins_service.domain.entities.pipeline : Pipeline, Stage, PipelineStatus;
import jenkins_service.domain.entities.build : Build, BuildStatus, StageResult;
import std.conv : to;
import std.string : split, startsWith;
import vibe.http.router : URLRouter;
import vibe.http.server : HTTPServerRequest, HTTPServerResponse;
import vibe.http.common : HTTPStatus;
import vibe.data.json : serializeToJsonString, Json;

// --- View structs ---

struct StageView {
    string name;
    string command;
    uint timeoutSeconds;
}

struct PipelineView {
    string id;
    string name;
    string description;
    string repository;
    string branch;
    string status;
    StageView[] stages;
    string createdAt;
}

struct StageResultView {
    string stageName;
    string status;
    string output;
    uint durationSeconds;
}

struct BuildView {
    string id;
    string pipelineId;
    uint buildNumber;
    string status;
    StageResultView[] stageResults;
    string triggeredBy;
    string startedAt;
    string finishedAt;
}

class JenkinsController {
    private CreatePipelineUseCase createPipelineUC;
    private ListPipelinesUseCase listPipelinesUC;
    private GetPipelineUseCase getPipelineUC;
    private DeletePipelineUseCase deletePipelineUC;
    private TriggerBuildUseCase triggerBuildUC;
    private GetBuildUseCase getBuildUC;
    private ListBuildsUseCase listBuildsUC;

    this(
        CreatePipelineUseCase createPipelineUC,
        ListPipelinesUseCase listPipelinesUC,
        GetPipelineUseCase getPipelineUC,
        DeletePipelineUseCase deletePipelineUC,
        TriggerBuildUseCase triggerBuildUC,
        GetBuildUseCase getBuildUC,
        ListBuildsUseCase listBuildsUC,
    ) {
        this.createPipelineUC = createPipelineUC;
        this.listPipelinesUC = listPipelinesUC;
        this.getPipelineUC = getPipelineUC;
        this.deletePipelineUC = deletePipelineUC;
        this.triggerBuildUC = triggerBuildUC;
        this.getBuildUC = getBuildUC;
        this.listBuildsUC = listBuildsUC;
    }

    void registerRoutes(URLRouter router) {
        // Health
        router.get("/health", &health);

        // Pipelines
        router.get("/v1/pipelines", &listPipelines);
        router.get("/v1/pipelines/*", &getPipeline);
        router.post("/v1/pipelines", &createPipeline);
        router.delete_("/v1/pipelines/*", &deletePipeline);

        // Builds
        router.get("/v1/builds/*", &getBuild);
        router.post("/v1/pipelines/*/builds", &triggerBuild);
        router.get("/v1/pipelines/*/builds", &listBuilds);
    }

    // --- Handlers ---

    void health(HTTPServerRequest req, HTTPServerResponse res) {
        writeJson(res, `{ "status": "ok" }`, HTTPStatus.ok);
    }

    void listPipelines(HTTPServerRequest req, HTTPServerResponse res) {
        auto pipelines = listPipelinesUC.execute();
        writeJson(res, serializeToJsonString(pipelinesToViews(pipelines)), HTTPStatus.ok);
    }

    void getPipeline(HTTPServerRequest req, HTTPServerResponse res) {
        auto segments = splitPathAfterPrefix(req.requestPath.to!string, "/v1/pipelines/");
        if (segments.length == 0 || segments[0].length == 0) {
            writeJson(res, `{ "error": "expected /v1/pipelines/<id>" }`, HTTPStatus.badRequest);
            return;
        }

        // Check if this is a builds sub-resource request — delegate to listBuilds/triggerBuild
        if (segments.length >= 2 && segments[$ - 1] == "builds") {
            return;
        }

        try {
            auto query = GetPipelineQuery(segments[0]);
            auto pipeline = getPipelineUC.execute(query);
            writeJson(res, serializeToJsonString(pipelineToView(pipeline)), HTTPStatus.ok);
        } catch (Exception ex) {
            writeJson(res, `{ "error": "` ~ ex.msg ~ `" }`, HTTPStatus.notFound);
        }
    }

    void createPipeline(HTTPServerRequest req, HTTPServerResponse res) {
        try {
            auto json = req.json;
            if (json.type == Json.Type.undefined) {
                writeJson(res, `{ "error": "request body must be JSON" }`, HTTPStatus.badRequest);
                return;
            }

            string[] stageNames;
            string[] stageCommands;
            uint[] stageTimeouts;

            if ("stages" in json) {
                foreach (stageJson; json["stages"]) {
                    stageNames ~= stageJson["name"].get!string;
                    stageCommands ~= stageJson["command"].get!string;
                    stageTimeouts ~= ("timeoutSeconds" in stageJson)
                        ? stageJson["timeoutSeconds"].get!uint
                        : cast(uint) 300;
                }
            }

            auto command = CreatePipelineCommand(
                json["name"].get!string,
                ("description" in json) ? json["description"].get!string : "",
                json["repository"].get!string,
                ("branch" in json) ? json["branch"].get!string : "main",
                stageNames,
                stageCommands,
                stageTimeouts,
            );

            auto created = createPipelineUC.execute(command);
            writeJson(res, serializeToJsonString(pipelineToView(created)), HTTPStatus.created);
        } catch (Exception ex) {
            writeJson(res, `{ "error": "` ~ ex.msg ~ `" }`, HTTPStatus.badRequest);
        }
    }

    void deletePipeline(HTTPServerRequest req, HTTPServerResponse res) {
        auto segments = splitPathAfterPrefix(req.requestPath.to!string, "/v1/pipelines/");
        if (segments.length == 0 || segments[0].length == 0) {
            writeJson(res, `{ "error": "expected /v1/pipelines/<id>" }`, HTTPStatus.badRequest);
            return;
        }

        try {
            deletePipelineUC.execute(segments[0]);
            writeJson(res, `{ "status": "deleted" }`, HTTPStatus.ok);
        } catch (Exception ex) {
            writeJson(res, `{ "error": "` ~ ex.msg ~ `" }`, HTTPStatus.notFound);
        }
    }

    void triggerBuild(HTTPServerRequest req, HTTPServerResponse res) {
        auto segments = splitPathAfterPrefix(req.requestPath.to!string, "/v1/pipelines/");
        if (segments.length < 2 || segments[$ - 1] != "builds") {
            writeJson(res, `{ "error": "expected /v1/pipelines/<id>/builds" }`, HTTPStatus.badRequest);
            return;
        }

        auto pipelineId = segments[0];

        try {
            string triggeredBy = "system";
            auto json = req.json;
            if (json.type != Json.Type.undefined && "triggeredBy" in json) {
                triggeredBy = json["triggeredBy"].get!string;
            }

            auto command = TriggerBuildCommand(pipelineId, triggeredBy);
            auto build = triggerBuildUC.execute(command);
            writeJson(res, serializeToJsonString(buildToView(build)), HTTPStatus.created);
        } catch (Exception ex) {
            writeJson(res, `{ "error": "` ~ ex.msg ~ `" }`, HTTPStatus.badRequest);
        }
    }

    void listBuilds(HTTPServerRequest req, HTTPServerResponse res) {
        auto segments = splitPathAfterPrefix(req.requestPath.to!string, "/v1/pipelines/");
        if (segments.length < 2 || segments[$ - 1] != "builds") {
            writeJson(res, `{ "error": "expected /v1/pipelines/<id>/builds" }`, HTTPStatus.badRequest);
            return;
        }

        auto pipelineId = segments[0];

        try {
            auto query = ListBuildsQuery(pipelineId);
            auto builds = listBuildsUC.execute(query);
            writeJson(res, serializeToJsonString(buildsToViews(builds)), HTTPStatus.ok);
        } catch (Exception ex) {
            writeJson(res, `{ "error": "` ~ ex.msg ~ `" }`, HTTPStatus.badRequest);
        }
    }

    void getBuild(HTTPServerRequest req, HTTPServerResponse res) {
        auto segments = splitPathAfterPrefix(req.requestPath.to!string, "/v1/builds/");
        if (segments.length == 0 || segments[0].length == 0) {
            writeJson(res, `{ "error": "expected /v1/builds/<id>" }`, HTTPStatus.badRequest);
            return;
        }

        try {
            auto query = GetBuildQuery(segments[0]);
            auto build = getBuildUC.execute(query);
            writeJson(res, serializeToJsonString(buildToView(build)), HTTPStatus.ok);
        } catch (Exception ex) {
            writeJson(res, `{ "error": "` ~ ex.msg ~ `" }`, HTTPStatus.notFound);
        }
    }

    // --- Mappers ---

    private PipelineView pipelineToView(in Pipeline p) {
        StageView[] sv;
        foreach (s; p.stages) {
            sv ~= StageView(s.name, s.command, s.timeoutSeconds);
        }
        return PipelineView(p.id, p.name, p.description, p.repository, p.branch, p.status.to!string, sv, p.createdAt);
    }

    private PipelineView[] pipelinesToViews(scope const Pipeline[] pipelines) {
        PipelineView[] views;
        foreach (p; pipelines) {
            views ~= pipelineToView(p);
        }
        return views;
    }

    private BuildView buildToView(in Build b) {
        StageResultView[] srv;
        foreach (sr; b.stageResults) {
            srv ~= StageResultView(sr.stageName, sr.status.to!string, sr.output, sr.durationSeconds);
        }
        return BuildView(b.id, b.pipelineId, b.buildNumber, b.status.to!string, srv, b.triggeredBy, b.startedAt, b.finishedAt);
    }

    private BuildView[] buildsToViews(scope const Build[] builds) {
        BuildView[] views;
        foreach (b; builds) {
            views ~= buildToView(b);
        }
        return views;
    }

    // --- Helpers ---

    private string[] splitPathAfterPrefix(string requestPath, string prefix) {
        if (!requestPath.startsWith(prefix)) {
            return [];
        }
        auto remainder = requestPath[prefix.length .. $];
        return split(remainder, "/");
    }

    private void writeJson(HTTPServerResponse res, string body, HTTPStatus status) {
        res.writeBody(body, cast(int) status, "application/json");
    }
}
