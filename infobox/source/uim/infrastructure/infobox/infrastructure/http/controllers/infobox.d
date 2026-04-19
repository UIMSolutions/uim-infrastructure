module uim.infrastructure.infobox.infrastructure.http.controllers.infobox;

import uim.infrastructure.infobox.application.dto.commands;
import uim.infrastructure.infobox.application.usecases.create_project : CreateProjectUseCase;
import uim.infrastructure.infobox.application.usecases.list_projects : ListProjectsUseCase;
import uim.infrastructure.infobox.application.usecases.get_project : GetProjectUseCase;
import uim.infrastructure.infobox.application.usecases.delete_project : DeleteProjectUseCase;
import uim.infrastructure.infobox.application.usecases.trigger_build : TriggerBuildUseCase;
import uim.infrastructure.infobox.application.usecases.get_build : GetBuildUseCase;
import uim.infrastructure.infobox.application.usecases.list_builds : ListBuildsUseCase;
import uim.infrastructure.infobox.application.usecases.create_job : CreateJobUseCase;
import uim.infrastructure.infobox.application.usecases.get_job : GetJobUseCase;
import uim.infrastructure.infobox.application.usecases.list_jobs : ListJobsUseCase;
import uim.infrastructure.infobox.application.usecases.create_secret : CreateSecretUseCase;
import uim.infrastructure.infobox.application.usecases.list_secrets : ListSecretsUseCase;
import uim.infrastructure.infobox.application.usecases.delete_secret : DeleteSecretUseCase;
import uim.infrastructure.infobox.domain.entities.project : Project;
import uim.infrastructure.infobox.domain.entities.build : Build;
import uim.infrastructure.infobox.domain.entities.job : Job, ResourceLimits, Dependency, EnvironmentVar;
import uim.infrastructure.infobox.domain.entities.secret : Secret;
import std.conv : to;
import std.string : split, startsWith;
import vibe.http.router : URLRouter;
import vibe.http.server : HTTPServerRequest, HTTPServerResponse;
import vibe.http.common : HTTPStatus;
import vibe.data.json : serializeToJsonString, Json;

// --- View structs ---

struct ProjectView {
    string id;
    string name;
    string description;
    string repository;
    string branch;
    string status;
    string createdAt;
    string updatedAt;
}

struct BuildView {
    string id;
    string projectId;
    uint buildNumber;
    string status;
    string trigger;
    string commitSha;
    string branch;
    string triggeredBy;
    uint totalJobs;
    uint completedJobs;
    string startedAt;
    string finishedAt;
}

struct ResourceLimitsView {
    uint cpuMillis;
    uint memoryMb;
    uint timeoutSeconds;
}

struct DependencyView {
    string jobName;
    bool onSuccess;
    bool onFailure;
}

struct EnvironmentVarView {
    string name;
    string value;
    bool isSecret;
}

struct JobView {
    string id;
    string projectId;
    string buildId;
    string name;
    string jobType;
    string status;
    string dockerFile;
    string image;
    string command;
    ResourceLimitsView resources;
    DependencyView[] dependencies;
    EnvironmentVarView[] environment;
    uint durationSeconds;
    string startedAt;
    string finishedAt;
}

struct SecretView {
    string id;
    string projectId;
    string name;
    string createdAt;
}

class InfoboxController {
    private CreateProjectUseCase createProjectUC;
    private ListProjectsUseCase listProjectsUC;
    private GetProjectUseCase getProjectUC;
    private DeleteProjectUseCase deleteProjectUC;
    private TriggerBuildUseCase triggerBuildUC;
    private GetBuildUseCase getBuildUC;
    private ListBuildsUseCase listBuildsUC;
    private CreateJobUseCase createJobUC;
    private GetJobUseCase getJobUC;
    private ListJobsUseCase listJobsUC;
    private CreateSecretUseCase createSecretUC;
    private ListSecretsUseCase listSecretsUC;
    private DeleteSecretUseCase deleteSecretUC;

    this(
        CreateProjectUseCase createProjectUC,
        ListProjectsUseCase listProjectsUC,
        GetProjectUseCase getProjectUC,
        DeleteProjectUseCase deleteProjectUC,
        TriggerBuildUseCase triggerBuildUC,
        GetBuildUseCase getBuildUC,
        ListBuildsUseCase listBuildsUC,
        CreateJobUseCase createJobUC,
        GetJobUseCase getJobUC,
        ListJobsUseCase listJobsUC,
        CreateSecretUseCase createSecretUC,
        ListSecretsUseCase listSecretsUC,
        DeleteSecretUseCase deleteSecretUC,
    ) {
        this.createProjectUC = createProjectUC;
        this.listProjectsUC = listProjectsUC;
        this.getProjectUC = getProjectUC;
        this.deleteProjectUC = deleteProjectUC;
        this.triggerBuildUC = triggerBuildUC;
        this.getBuildUC = getBuildUC;
        this.listBuildsUC = listBuildsUC;
        this.createJobUC = createJobUC;
        this.getJobUC = getJobUC;
        this.listJobsUC = listJobsUC;
        this.createSecretUC = createSecretUC;
        this.listSecretsUC = listSecretsUC;
        this.deleteSecretUC = deleteSecretUC;
    }

    void registerRoutes(URLRouter router) {
        // Health
        router.get("/health", &health);

        // Projects
        router.get("/v1/projects", &listProjects);
        router.get("/v1/projects/*", &getProject);
        router.post("/v1/projects", &createProject);
        router.delete_("/v1/projects/*", &deleteProject);

        // Builds
        router.post("/v1/projects/*/builds", &triggerBuild);
        router.get("/v1/projects/*/builds", &listBuilds);
        router.get("/v1/builds/*", &getBuild);

        // Jobs
        router.post("/v1/builds/*/jobs", &createJob);
        router.get("/v1/builds/*/jobs", &listJobs);
        router.get("/v1/jobs/*", &getJob);

        // Secrets
        router.post("/v1/projects/*/secrets", &createSecret);
        router.get("/v1/projects/*/secrets", &listSecrets);
        router.delete_("/v1/secrets/*", &deleteSecret);
    }

    // --- Health ---

    void health(HTTPServerRequest req, HTTPServerResponse res) {
        writeJson(res, `{ "status": "ok" }`, HTTPStatus.ok);
    }

    // --- Projects ---

    void listProjects(HTTPServerRequest req, HTTPServerResponse res) {
        auto projects = listProjectsUC.execute();
        writeJson(res, serializeToJsonString(projectsToViews(projects)), HTTPStatus.ok);
    }

    void getProject(HTTPServerRequest req, HTTPServerResponse res) {
        auto segments = splitPathAfterPrefix(req.requestPath.to!string, "/v1/projects/");
        if (segments.length == 0 || segments[0].length == 0) {
            writeJson(res, `{ "error": "expected /v1/projects/<id>" }`, HTTPStatus.badRequest);
            return;
        }

        if (segments.length >= 2 && (segments[$ - 1] == "builds" || segments[$ - 1] == "secrets")) {
            return;
        }

        try {
            auto query = GetProjectQuery(segments[0]);
            auto project = getProjectUC.execute(query);
            writeJson(res, serializeToJsonString(projectToView(project)), HTTPStatus.ok);
        } catch (Exception ex) {
            writeJson(res, `{ "error": "` ~ ex.msg ~ `" }`, HTTPStatus.notFound);
        }
    }

    void createProject(HTTPServerRequest req, HTTPServerResponse res) {
        try {
            auto json = req.json;
            if (json.type == Json.Type.undefined) {
                writeJson(res, `{ "error": "request body must be JSON" }`, HTTPStatus.badRequest);
                return;
            }

            auto command = CreateProjectCommand(
                json["name"].get!string,
                ("description" in json) ? json["description"].get!string : "",
                json["repository"].get!string,
                ("branch" in json) ? json["branch"].get!string : "main",
            );

            auto created = createProjectUC.execute(command);
            writeJson(res, serializeToJsonString(projectToView(created)), HTTPStatus.created);
        } catch (Exception ex) {
            writeJson(res, `{ "error": "` ~ ex.msg ~ `" }`, HTTPStatus.badRequest);
        }
    }

    void deleteProject(HTTPServerRequest req, HTTPServerResponse res) {
        auto segments = splitPathAfterPrefix(req.requestPath.to!string, "/v1/projects/");
        if (segments.length == 0 || segments[0].length == 0) {
            writeJson(res, `{ "error": "expected /v1/projects/<id>" }`, HTTPStatus.badRequest);
            return;
        }

        try {
            deleteProjectUC.execute(segments[0]);
            writeJson(res, `{ "status": "deleted" }`, HTTPStatus.ok);
        } catch (Exception ex) {
            writeJson(res, `{ "error": "` ~ ex.msg ~ `" }`, HTTPStatus.notFound);
        }
    }

    // --- Builds ---

    void triggerBuild(HTTPServerRequest req, HTTPServerResponse res) {
        auto segments = splitPathAfterPrefix(req.requestPath.to!string, "/v1/projects/");
        if (segments.length < 2 || segments[$ - 1] != "builds") {
            writeJson(res, `{ "error": "expected /v1/projects/<id>/builds" }`, HTTPStatus.badRequest);
            return;
        }

        auto projectId = segments[0];

        try {
            string triggeredBy = "system";
            string commitSha = "";
            string branch = "";
            string triggerType = "manual";

            auto json = req.json;
            if (json.type != Json.Type.undefined) {
                if ("triggeredBy" in json) triggeredBy = json["triggeredBy"].get!string;
                if ("commitSha" in json) commitSha = json["commitSha"].get!string;
                if ("branch" in json) branch = json["branch"].get!string;
                if ("trigger" in json) triggerType = json["trigger"].get!string;
            }

            auto command = TriggerBuildCommand(projectId, commitSha, branch, triggeredBy, triggerType);
            auto build = triggerBuildUC.execute(command);
            writeJson(res, serializeToJsonString(buildToView(build)), HTTPStatus.created);
        } catch (Exception ex) {
            writeJson(res, `{ "error": "` ~ ex.msg ~ `" }`, HTTPStatus.badRequest);
        }
    }

    void listBuilds(HTTPServerRequest req, HTTPServerResponse res) {
        auto segments = splitPathAfterPrefix(req.requestPath.to!string, "/v1/projects/");
        if (segments.length < 2 || segments[$ - 1] != "builds") {
            writeJson(res, `{ "error": "expected /v1/projects/<id>/builds" }`, HTTPStatus.badRequest);
            return;
        }

        auto projectId = segments[0];

        try {
            auto query = ListBuildsQuery(projectId);
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

        if (segments.length >= 2 && segments[$ - 1] == "jobs") {
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

    // --- Jobs ---

    void createJob(HTTPServerRequest req, HTTPServerResponse res) {
        auto segments = splitPathAfterPrefix(req.requestPath.to!string, "/v1/builds/");
        if (segments.length < 2 || segments[$ - 1] != "jobs") {
            writeJson(res, `{ "error": "expected /v1/builds/<id>/jobs" }`, HTTPStatus.badRequest);
            return;
        }

        auto buildId = segments[0];

        try {
            auto json = req.json;
            if (json.type == Json.Type.undefined) {
                writeJson(res, `{ "error": "request body must be JSON" }`, HTTPStatus.badRequest);
                return;
            }

            string[] depNames;
            if ("dependencies" in json) {
                foreach (dep; json["dependencies"]) {
                    depNames ~= dep.get!string;
                }
            }

            string[] envNames, envValues;
            bool[] envIsSecret;
            if ("environment" in json) {
                foreach (env; json["environment"]) {
                    envNames ~= env["name"].get!string;
                    envValues ~= env["value"].get!string;
                    envIsSecret ~= ("isSecret" in env) ? env["isSecret"].get!bool : false;
                }
            }

            auto command = CreateJobCommand(
                json["projectId"].get!string,
                buildId,
                json["name"].get!string,
                ("type" in json) ? json["type"].get!string : "docker",
                ("dockerFile" in json) ? json["dockerFile"].get!string : "Dockerfile",
                ("image" in json) ? json["image"].get!string : "",
                ("command" in json) ? json["command"].get!string : "",
                ("buildContext" in json) ? json["buildContext"].get!string : ".",
                ("cpuMillis" in json) ? json["cpuMillis"].get!uint : 1000,
                ("memoryMb" in json) ? json["memoryMb"].get!uint : 2048,
                ("timeoutSeconds" in json) ? json["timeoutSeconds"].get!uint : 600,
                depNames,
                envNames,
                envValues,
                envIsSecret,
            );

            auto job = createJobUC.execute(command);
            writeJson(res, serializeToJsonString(jobToView(job)), HTTPStatus.created);
        } catch (Exception ex) {
            writeJson(res, `{ "error": "` ~ ex.msg ~ `" }`, HTTPStatus.badRequest);
        }
    }

    void listJobs(HTTPServerRequest req, HTTPServerResponse res) {
        auto segments = splitPathAfterPrefix(req.requestPath.to!string, "/v1/builds/");
        if (segments.length < 2 || segments[$ - 1] != "jobs") {
            writeJson(res, `{ "error": "expected /v1/builds/<id>/jobs" }`, HTTPStatus.badRequest);
            return;
        }

        auto buildId = segments[0];

        try {
            auto query = ListJobsQuery(buildId);
            auto jobs = listJobsUC.execute(query);
            writeJson(res, serializeToJsonString(jobsToViews(jobs)), HTTPStatus.ok);
        } catch (Exception ex) {
            writeJson(res, `{ "error": "` ~ ex.msg ~ `" }`, HTTPStatus.badRequest);
        }
    }

    void getJob(HTTPServerRequest req, HTTPServerResponse res) {
        auto segments = splitPathAfterPrefix(req.requestPath.to!string, "/v1/jobs/");
        if (segments.length == 0 || segments[0].length == 0) {
            writeJson(res, `{ "error": "expected /v1/jobs/<id>" }`, HTTPStatus.badRequest);
            return;
        }

        try {
            auto query = GetJobQuery(segments[0]);
            auto job = getJobUC.execute(query);
            writeJson(res, serializeToJsonString(jobToView(job)), HTTPStatus.ok);
        } catch (Exception ex) {
            writeJson(res, `{ "error": "` ~ ex.msg ~ `" }`, HTTPStatus.notFound);
        }
    }

    // --- Secrets ---

    void createSecret(HTTPServerRequest req, HTTPServerResponse res) {
        auto segments = splitPathAfterPrefix(req.requestPath.to!string, "/v1/projects/");
        if (segments.length < 2 || segments[$ - 1] != "secrets") {
            writeJson(res, `{ "error": "expected /v1/projects/<id>/secrets" }`, HTTPStatus.badRequest);
            return;
        }

        auto projectId = segments[0];

        try {
            auto json = req.json;
            if (json.type == Json.Type.undefined) {
                writeJson(res, `{ "error": "request body must be JSON" }`, HTTPStatus.badRequest);
                return;
            }

            auto command = CreateSecretCommand(
                projectId,
                json["name"].get!string,
                json["value"].get!string,
            );

            auto secret = createSecretUC.execute(command);
            writeJson(res, serializeToJsonString(secretToView(secret)), HTTPStatus.created);
        } catch (Exception ex) {
            writeJson(res, `{ "error": "` ~ ex.msg ~ `" }`, HTTPStatus.badRequest);
        }
    }

    void listSecrets(HTTPServerRequest req, HTTPServerResponse res) {
        auto segments = splitPathAfterPrefix(req.requestPath.to!string, "/v1/projects/");
        if (segments.length < 2 || segments[$ - 1] != "secrets") {
            writeJson(res, `{ "error": "expected /v1/projects/<id>/secrets" }`, HTTPStatus.badRequest);
            return;
        }

        auto projectId = segments[0];

        try {
            auto query = ListSecretsQuery(projectId);
            auto secrets = listSecretsUC.execute(query);
            writeJson(res, serializeToJsonString(secretsToViews(secrets)), HTTPStatus.ok);
        } catch (Exception ex) {
            writeJson(res, `{ "error": "` ~ ex.msg ~ `" }`, HTTPStatus.badRequest);
        }
    }

    void deleteSecret(HTTPServerRequest req, HTTPServerResponse res) {
        auto segments = splitPathAfterPrefix(req.requestPath.to!string, "/v1/secrets/");
        if (segments.length == 0 || segments[0].length == 0) {
            writeJson(res, `{ "error": "expected /v1/secrets/<id>" }`, HTTPStatus.badRequest);
            return;
        }

        try {
            deleteSecretUC.execute(segments[0]);
            writeJson(res, `{ "status": "deleted" }`, HTTPStatus.ok);
        } catch (Exception ex) {
            writeJson(res, `{ "error": "` ~ ex.msg ~ `" }`, HTTPStatus.notFound);
        }
    }

    // --- Mappers ---

    private ProjectView projectToView(in Project p) {
        return ProjectView(p.id, p.name, p.description, p.repository, p.branch,
            p.status.to!string, p.createdAt, p.updatedAt);
    }

    private ProjectView[] projectsToViews(scope const Project[] projects) {
        ProjectView[] views;
        foreach (p; projects) {
            views ~= projectToView(p);
        }
        return views;
    }

    private BuildView buildToView(in Build b) {
        return BuildView(b.id, b.projectId, b.buildNumber, b.status.to!string,
            b.trigger.to!string, b.commitSha, b.branch, b.triggeredBy,
            b.totalJobs, b.completedJobs, b.startedAt, b.finishedAt);
    }

    private BuildView[] buildsToViews(scope const Build[] builds) {
        BuildView[] views;
        foreach (b; builds) {
            views ~= buildToView(b);
        }
        return views;
    }

    private JobView jobToView(in Job j) {
        DependencyView[] dvs;
        foreach (d; j.dependencies) {
            dvs ~= DependencyView(d.jobName, d.onSuccess, d.onFailure);
        }
        EnvironmentVarView[] evs;
        foreach (e; j.environment) {
            evs ~= EnvironmentVarView(e.name, e.isSecret ? "***" : e.value, e.isSecret);
        }
        return JobView(j.id, j.projectId, j.buildId, j.name, j.type.to!string,
            j.status.to!string, j.dockerFile, j.image, j.command,
            ResourceLimitsView(j.resources.cpuMillis, j.resources.memoryMb, j.resources.timeoutSeconds),
            dvs, evs, j.durationSeconds, j.startedAt, j.finishedAt);
    }

    private JobView[] jobsToViews(scope const Job[] jobs) {
        JobView[] views;
        foreach (j; jobs) {
            views ~= jobToView(j);
        }
        return views;
    }

    private SecretView secretToView(in Secret s) {
        return SecretView(s.id, s.projectId, s.name, s.createdAt);
    }

    private SecretView[] secretsToViews(scope const Secret[] secrets) {
        SecretView[] views;
        foreach (s; secrets) {
            views ~= secretToView(s);
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
