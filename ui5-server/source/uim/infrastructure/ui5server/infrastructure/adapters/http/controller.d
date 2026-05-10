module uim.infrastructure.ui5server.infrastructure.adapters.http.controller;

import std.conv : to;
import std.string : indexOf;

import vibe.http.router : URLRouter;
import vibe.http.server : HTTPServerRequest, HTTPServerResponse;
import vibe.http.status : HTTPStatus;
import vibe.data.json : Json;

import uim.infrastructure.ui5server.application.usecases.create_server : CreateServerUseCase;
import uim.infrastructure.ui5server.application.usecases.get_server : GetServerUseCase;
import uim.infrastructure.ui5server.application.usecases.list_servers : ListServersUseCase;
import uim.infrastructure.ui5server.application.usecases.delete_server : DeleteServerUseCase;
import uim.infrastructure.ui5server.application.usecases.update_server_status : UpdateServerStatusUseCase;
import uim.infrastructure.ui5server.application.usecases.register_middleware : RegisterMiddlewareUseCase;
import uim.infrastructure.ui5server.application.usecases.list_middleware : ListMiddlewareUseCase;
import uim.infrastructure.ui5server.application.usecases.remove_middleware : RemoveMiddlewareUseCase;
import uim.infrastructure.ui5server.application.usecases.upload_resource : UploadResourceUseCase;
import uim.infrastructure.ui5server.application.usecases.serve_resource : ServeResourceUseCase;
import uim.infrastructure.ui5server.application.usecases.list_resources : ListResourcesUseCase;
import uim.infrastructure.ui5server.application.usecases.delete_resource : DeleteResourceUseCase;
import uim.infrastructure.ui5server.application.usecases.create_project : CreateProjectUseCase;
import uim.infrastructure.ui5server.application.usecases.list_projects : ListProjectsUseCase;
import uim.infrastructure.ui5server.application.usecases.delete_project : DeleteProjectUseCase;
import uim.infrastructure.ui5server.application.usecases.get_csp_reports : GetCspReportsUseCase;

import uim.infrastructure.ui5server.application.dtos.server;
import uim.infrastructure.ui5server.application.dtos.middleware;
import uim.infrastructure.ui5server.application.dtos.resource;
import uim.infrastructure.ui5server.application.dtos.project;
import uim.infrastructure.ui5server.application.dtos.csp;

class UI5ServerController {
    private CreateServerUseCase createServerUC;
    private GetServerUseCase getServerUC;
    private ListServersUseCase listServersUC;
    private DeleteServerUseCase deleteServerUC;
    private UpdateServerStatusUseCase updateServerStatusUC;
    private RegisterMiddlewareUseCase registerMiddlewareUC;
    private ListMiddlewareUseCase listMiddlewareUC;
    private RemoveMiddlewareUseCase removeMiddlewareUC;
    private UploadResourceUseCase uploadResourceUC;
    private ServeResourceUseCase serveResourceUC;
    private ListResourcesUseCase listResourcesUC;
    private DeleteResourceUseCase deleteResourceUC;
    private CreateProjectUseCase createProjectUC;
    private ListProjectsUseCase listProjectsUC;
    private DeleteProjectUseCase deleteProjectUC;
    private GetCspReportsUseCase getCspReportsUC;

    this(
        CreateServerUseCase createServerUC,
        GetServerUseCase getServerUC,
        ListServersUseCase listServersUC,
        DeleteServerUseCase deleteServerUC,
        UpdateServerStatusUseCase updateServerStatusUC,
        RegisterMiddlewareUseCase registerMiddlewareUC,
        ListMiddlewareUseCase listMiddlewareUC,
        RemoveMiddlewareUseCase removeMiddlewareUC,
        UploadResourceUseCase uploadResourceUC,
        ServeResourceUseCase serveResourceUC,
        ListResourcesUseCase listResourcesUC,
        DeleteResourceUseCase deleteResourceUC,
        CreateProjectUseCase createProjectUC,
        ListProjectsUseCase listProjectsUC,
        DeleteProjectUseCase deleteProjectUC,
        GetCspReportsUseCase getCspReportsUC,
    ) {
        this.createServerUC = createServerUC;
        this.getServerUC = getServerUC;
        this.listServersUC = listServersUC;
        this.deleteServerUC = deleteServerUC;
        this.updateServerStatusUC = updateServerStatusUC;
        this.registerMiddlewareUC = registerMiddlewareUC;
        this.listMiddlewareUC = listMiddlewareUC;
        this.removeMiddlewareUC = removeMiddlewareUC;
        this.uploadResourceUC = uploadResourceUC;
        this.serveResourceUC = serveResourceUC;
        this.listResourcesUC = listResourcesUC;
        this.deleteResourceUC = deleteResourceUC;
        this.createProjectUC = createProjectUC;
        this.listProjectsUC = listProjectsUC;
        this.deleteProjectUC = deleteProjectUC;
        this.getCspReportsUC = getCspReportsUC;
    }

    void registerRoutes(URLRouter router) {
        router.get("/health", &healthCheck);

        // Server management
        router.post("/api/v1/servers", &createServer);
        router.get("/api/v1/servers", &listServers);
        router.get("/api/v1/servers/*", &getServer);
        router.delete_("/api/v1/servers/*", &deleteServer);
        router.patch("/api/v1/servers/*", &updateServerStatus);

        // Middleware management
        router.post("/api/v1/middleware", &registerMiddleware);
        router.get("/api/v1/middleware", &listMiddleware);
        router.delete_("/api/v1/middleware/*", &removeMiddleware);

        // Resource serving
        router.post("/api/v1/resources", &uploadResource);
        router.get("/api/v1/resources", &listResources);
        router.delete_("/api/v1/resources/*", &deleteResource);
        router.get("/resources/*", &serveResource);

        // Project management
        router.post("/api/v1/projects", &createProject);
        router.get("/api/v1/projects", &listProjects);
        router.delete_("/api/v1/projects/*", &deleteProject);

        // CSP reports
        router.get("/.ui5/csp/csp-reports.json", &getCspReports);

        // Discovery endpoint
        router.get("/discovery", &discoveryEndpoint);

        // Directory index (serve index for any unmatched GET)
        router.get("/api/v1/directory/*", &directoryIndex);
    }

    // --- Health ---

    void healthCheck(HTTPServerRequest req, HTTPServerResponse res) {
        auto j = Json.emptyObject;
        j["status"] = "healthy";
        j["service"] = "uim-ui5-server-service";
        res.writeBody(j.toString(), cast(int) HTTPStatus.ok, "application/json");
    }

    // --- Servers ---

    void createServer(HTTPServerRequest req, HTTPServerResponse res) {
        try {
            auto j = req.json;
            if (j.type == Json.Type.undefined) {
                res.writeBody(`{"error":"Request body required"}`, cast(int) HTTPStatus.badRequest, "application/json");
                return;
            }

            string[] mwNames;
            if (j["middlewareNames"].type == Json.Type.array) {
                foreach (m; j["middlewareNames"]) mwNames ~= m.get!string;
            }

            auto dto = CreateServerDTO(
                j["name"].get!string,
                j["port"].type != Json.Type.undefined ? j["port"].get!ushort : cast(ushort) 8080,
                j["host"].type != Json.Type.undefined ? j["host"].get!string : "0.0.0.0",
                j["protocol"].type != Json.Type.undefined ? j["protocol"].get!string : "http",
                j["acceptRemoteConnections"].type != Json.Type.undefined ? j["acceptRemoteConnections"].get!bool : false,
                j["changePortIfInUse"].type != Json.Type.undefined ? j["changePortIfInUse"].get!bool : false,
                j["simpleIndex"].type != Json.Type.undefined ? j["simpleIndex"].get!bool : false,
                j["sslCertPath"].type != Json.Type.undefined ? j["sslCertPath"].get!string : "",
                j["sslKeyPath"].type != Json.Type.undefined ? j["sslKeyPath"].get!string : "",
                mwNames,
            );

            auto result = createServerUC.execute(dto);
            res.writeBody(serverToJson(result).toString(), cast(int) HTTPStatus.created, "application/json");
        } catch (Exception e) {
            auto err = Json.emptyObject;
            err["error"] = e.msg;
            res.writeBody(err.toString(), cast(int) HTTPStatus.badRequest, "application/json");
        }
    }

    void listServers(HTTPServerRequest req, HTTPServerResponse res) {
        auto results = listServersUC.execute();
        auto arr = Json.emptyArray;
        foreach (s; results) arr ~= serverToJson(s);
        res.writeBody(arr.toString(), cast(int) HTTPStatus.ok, "application/json");
    }

    void getServer(HTTPServerRequest req, HTTPServerResponse res) {
        auto id = extractLastSegment(req.requestURI);
        auto result = getServerUC.execute(id);
        if (result is null) {
            res.writeBody(`{"error":"Server not found"}`, cast(int) HTTPStatus.notFound, "application/json");
            return;
        }
        res.writeBody(serverToJson(*result).toString(), cast(int) HTTPStatus.ok, "application/json");
    }

    void deleteServer(HTTPServerRequest req, HTTPServerResponse res) {
        auto id = extractLastSegment(req.requestURI);
        if (deleteServerUC.execute(id)) {
            res.writeBody(`{"status":"deleted"}`, cast(int) HTTPStatus.ok, "application/json");
        } else {
            res.writeBody(`{"error":"Server not found"}`, cast(int) HTTPStatus.notFound, "application/json");
        }
    }

    void updateServerStatus(HTTPServerRequest req, HTTPServerResponse res) {
        try {
            auto j = req.json;
            if (j.type == Json.Type.undefined) {
                res.writeBody(`{"error":"Request body required"}`, cast(int) HTTPStatus.badRequest, "application/json");
                return;
            }
            auto id = extractLastSegment(req.requestURI);
            auto status = j["status"].get!string;
            if (updateServerStatusUC.execute(id, status)) {
                res.writeBody(`{"status":"updated"}`, cast(int) HTTPStatus.ok, "application/json");
            } else {
                res.writeBody(`{"error":"Server not found or invalid status"}`, cast(int) HTTPStatus.notFound, "application/json");
            }
        } catch (Exception e) {
            auto err = Json.emptyObject;
            err["error"] = e.msg;
            res.writeBody(err.toString(), cast(int) HTTPStatus.badRequest, "application/json");
        }
    }

    // --- Middleware ---

    void registerMiddleware(HTTPServerRequest req, HTTPServerResponse res) {
        try {
            auto j = req.json;
            if (j.type == Json.Type.undefined) {
                res.writeBody(`{"error":"Request body required"}`, cast(int) HTTPStatus.badRequest, "application/json");
                return;
            }

            string[string] cfg;
            if (j["config"].type == Json.Type.object) {
                foreach (string key, val; j["config"]) {
                    cfg[key] = val.get!string;
                }
            }

            auto dto = RegisterMiddlewareDTO(
                j["name"].get!string,
                j["type"].get!string,
                j["order"].type != Json.Type.undefined ? j["order"].get!uint : 0,
                j["enabled"].type != Json.Type.undefined ? j["enabled"].get!bool : true,
                cfg,
            );

            auto result = registerMiddlewareUC.execute(dto);
            res.writeBody(middlewareToJson(result).toString(), cast(int) HTTPStatus.created, "application/json");
        } catch (Exception e) {
            auto err = Json.emptyObject;
            err["error"] = e.msg;
            res.writeBody(err.toString(), cast(int) HTTPStatus.badRequest, "application/json");
        }
    }

    void listMiddleware(HTTPServerRequest req, HTTPServerResponse res) {
        auto results = listMiddlewareUC.execute();
        auto arr = Json.emptyArray;
        foreach (mw; results) arr ~= middlewareToJson(mw);
        res.writeBody(arr.toString(), cast(int) HTTPStatus.ok, "application/json");
    }

    void removeMiddleware(HTTPServerRequest req, HTTPServerResponse res) {
        auto name = extractLastSegment(req.requestURI);
        if (removeMiddlewareUC.execute(name)) {
            res.writeBody(`{"status":"removed"}`, cast(int) HTTPStatus.ok, "application/json");
        } else {
            res.writeBody(`{"error":"Middleware not found"}`, cast(int) HTTPStatus.notFound, "application/json");
        }
    }

    // --- Resources ---

    void uploadResource(HTTPServerRequest req, HTTPServerResponse res) {
        try {
            auto j = req.json;
            if (j.type == Json.Type.undefined) {
                res.writeBody(`{"error":"Request body required"}`, cast(int) HTTPStatus.badRequest, "application/json");
                return;
            }

            auto dto = UploadResourceDTO(
                j["path"].get!string,
                j["contentType"].type != Json.Type.undefined ? j["contentType"].get!string : "application/octet-stream",
                j["content"].type != Json.Type.undefined ? j["content"].get!string : "",
                j["isDirectory"].type != Json.Type.undefined ? j["isDirectory"].get!bool : false,
            );

            auto result = uploadResourceUC.execute(dto);
            auto rj = Json.emptyObject;
            rj["path"] = result.path;
            rj["contentType"] = result.contentType;
            rj["size"] = result.size;
            rj["isDirectory"] = result.isDirectory;
            res.writeBody(rj.toString(), cast(int) HTTPStatus.created, "application/json");
        } catch (Exception e) {
            auto err = Json.emptyObject;
            err["error"] = e.msg;
            res.writeBody(err.toString(), cast(int) HTTPStatus.badRequest, "application/json");
        }
    }

    void serveResource(HTTPServerRequest req, HTTPServerResponse res) {
        auto path = req.requestURI;
        // Strip /resources prefix
        auto prefix = "/resources";
        if (path.length > prefix.length && path[0 .. prefix.length] == prefix) {
            path = path[prefix.length .. $];
        }
        // Remove query string
        auto qIdx = path.indexOf('?');
        if (qIdx >= 0) path = path[0 .. qIdx];

        auto resource = serveResourceUC.execute(path);
        if (resource is null) {
            res.writeBody(`{"error":"Resource not found"}`, cast(int) HTTPStatus.notFound, "application/json");
            return;
        }
        res.writeBody(resource.content, cast(int) HTTPStatus.ok, resource.contentType);
    }

    void listResources(HTTPServerRequest req, HTTPServerResponse res) {
        string dir = "/";
        try {
            auto qp = req.queryParams();
            foreach (p; qp) {
                if (p[0] == "path") dir = p[1];
            }
        } catch (Exception e) {}

        auto result = listResourcesUC.execute(dir);
        auto j = Json.emptyObject;
        j["path"] = result.path;
        auto arr = Json.emptyArray;
        foreach (entry; result.entries) {
            auto ej = Json.emptyObject;
            ej["path"] = entry.path;
            ej["contentType"] = entry.contentType;
            ej["size"] = entry.size;
            ej["isDirectory"] = entry.isDirectory;
            arr ~= ej;
        }
        j["entries"] = arr;
        res.writeBody(j.toString(), cast(int) HTTPStatus.ok, "application/json");
    }

    void deleteResource(HTTPServerRequest req, HTTPServerResponse res) {
        auto path = extractPathAfterPrefix(req.requestURI, "/api/v1/resources/");
        if (deleteResourceUC.execute(path)) {
            res.writeBody(`{"status":"deleted"}`, cast(int) HTTPStatus.ok, "application/json");
        } else {
            res.writeBody(`{"error":"Resource not found"}`, cast(int) HTTPStatus.notFound, "application/json");
        }
    }

    // --- Projects ---

    void createProject(HTTPServerRequest req, HTTPServerResponse res) {
        try {
            auto j = req.json;
            if (j.type == Json.Type.undefined) {
                res.writeBody(`{"error":"Request body required"}`, cast(int) HTTPStatus.badRequest, "application/json");
                return;
            }

            DependencyDTO[] deps;
            if (j["dependencies"].type == Json.Type.array) {
                foreach (d; j["dependencies"]) {
                    deps ~= DependencyDTO(
                        d["name"].get!string,
                        d["version"].type != Json.Type.undefined ? d["version"].get!string : "",
                    );
                }
            }

            auto dto = CreateProjectDTO(
                j["name"].get!string,
                j["type"].type != Json.Type.undefined ? j["type"].get!string : "application",
                j["rootPath"].type != Json.Type.undefined ? j["rootPath"].get!string : "/",
                j["version"].type != Json.Type.undefined ? j["version"].get!string : "1.0.0",
                j["namespace"].type != Json.Type.undefined ? j["namespace"].get!string : "",
                deps,
            );

            auto result = createProjectUC.execute(dto);
            res.writeBody(projectToJson(result).toString(), cast(int) HTTPStatus.created, "application/json");
        } catch (Exception e) {
            auto err = Json.emptyObject;
            err["error"] = e.msg;
            res.writeBody(err.toString(), cast(int) HTTPStatus.badRequest, "application/json");
        }
    }

    void listProjects(HTTPServerRequest req, HTTPServerResponse res) {
        auto results = listProjectsUC.execute();
        auto arr = Json.emptyArray;
        foreach (p; results) arr ~= projectToJson(p);
        res.writeBody(arr.toString(), cast(int) HTTPStatus.ok, "application/json");
    }

    void deleteProject(HTTPServerRequest req, HTTPServerResponse res) {
        auto id = extractLastSegment(req.requestURI);
        if (deleteProjectUC.execute(id)) {
            res.writeBody(`{"status":"deleted"}`, cast(int) HTTPStatus.ok, "application/json");
        } else {
            res.writeBody(`{"error":"Project not found"}`, cast(int) HTTPStatus.notFound, "application/json");
        }
    }

    // --- CSP Reports ---

    void getCspReports(HTTPServerRequest req, HTTPServerResponse res) {
        auto result = getCspReportsUC.execute();
        auto j = Json.emptyObject;
        j["totalCount"] = result.totalCount;
        auto arr = Json.emptyArray;
        foreach (r; result.reports) {
            auto rj = Json.emptyObject;
            rj["id"] = r.id;
            rj["documentUri"] = r.documentUri;
            rj["violatedDirective"] = r.violatedDirective;
            rj["blockedUri"] = r.blockedUri;
            rj["originalPolicy"] = r.originalPolicy;
            rj["timestamp"] = r.timestamp;
            arr ~= rj;
        }
        j["reports"] = arr;
        res.writeBody(j.toString(), cast(int) HTTPStatus.ok, "application/json");
    }

    // --- Discovery ---

    void discoveryEndpoint(HTTPServerRequest req, HTTPServerResponse res) {
        auto servers = listServersUC.execute();
        auto mw = listMiddlewareUC.execute();
        auto projects = listProjectsUC.execute();

        auto j = Json.emptyObject;
        j["service"] = "uim-ui5-server-service";

        auto sArr = Json.emptyArray;
        foreach (s; servers) {
            auto sj = Json.emptyObject;
            sj["name"] = s.name;
            sj["port"] = s.port;
            sj["protocol"] = s.protocol;
            sj["status"] = s.status;
            sArr ~= sj;
        }
        j["servers"] = sArr;

        auto mArr = Json.emptyArray;
        foreach (m; mw) {
            auto mj = Json.emptyObject;
            mj["name"] = m.name;
            mj["type"] = m.type;
            mj["order"] = m.order;
            mj["enabled"] = m.enabled;
            mArr ~= mj;
        }
        j["middleware"] = mArr;

        auto pArr = Json.emptyArray;
        foreach (p; projects) {
            auto pj = Json.emptyObject;
            pj["name"] = p.name;
            pj["type"] = p.type;
            pj["version"] = p.version_;
            pArr ~= pj;
        }
        j["projects"] = pArr;

        res.writeBody(j.toString(), cast(int) HTTPStatus.ok, "application/json");
    }

    // --- Directory Index ---

    void directoryIndex(HTTPServerRequest req, HTTPServerResponse res) {
        auto path = extractPathAfterPrefix(req.requestURI, "/api/v1/directory/");
        if (path.length == 0) path = "/";
        auto result = listResourcesUC.execute(path);

        auto j = Json.emptyObject;
        j["directory"] = result.path;
        auto arr = Json.emptyArray;
        foreach (entry; result.entries) {
            auto ej = Json.emptyObject;
            ej["name"] = extractLastSegment(entry.path);
            ej["path"] = entry.path;
            ej["type"] = entry.isDirectory ? "directory" : "file";
            ej["size"] = entry.size;
            ej["contentType"] = entry.contentType;
            arr ~= ej;
        }
        j["entries"] = arr;
        res.writeBody(j.toString(), cast(int) HTTPStatus.ok, "application/json");
    }

    // --- Helpers ---

    private Json serverToJson(in ServerResponseDTO s) {
        auto j = Json.emptyObject;
        j["id"] = s.id;
        j["name"] = s.name;
        j["port"] = s.port;
        j["host"] = s.host;
        j["protocol"] = s.protocol;
        j["acceptRemoteConnections"] = s.acceptRemoteConnections;
        j["changePortIfInUse"] = s.changePortIfInUse;
        j["simpleIndex"] = s.simpleIndex;
        j["status"] = s.status;
        j["sslCertPath"] = s.sslCertPath;
        j["sslKeyPath"] = s.sslKeyPath;
        auto mArr = Json.emptyArray;
        foreach (m; s.middlewareNames) mArr ~= Json(m);
        j["middlewareNames"] = mArr;
        return j;
    }

    private Json middlewareToJson(in MiddlewareResponseDTO mw) {
        auto j = Json.emptyObject;
        j["name"] = mw.name;
        j["type"] = mw.type;
        j["order"] = mw.order;
        j["enabled"] = mw.enabled;
        auto cfgJ = Json.emptyObject;
        foreach (k, v; mw.config) {
            cfgJ[k] = v;
        }
        j["config"] = cfgJ;
        return j;
    }

    private Json projectToJson(in ProjectResponseDTO p) {
        auto j = Json.emptyObject;
        j["id"] = p.id;
        j["name"] = p.name;
        j["type"] = p.type;
        j["rootPath"] = p.rootPath;
        j["version"] = p.version_;
        j["namespace"] = p.namespace_;
        auto dArr = Json.emptyArray;
        foreach (d; p.dependencies) {
            auto dj = Json.emptyObject;
            dj["name"] = d.name;
            dj["version"] = d.version_;
            dArr ~= dj;
        }
        j["dependencies"] = dArr;
        return j;
    }

    private string extractLastSegment(string path) {
        auto qIdx = path.indexOf('?');
        if (qIdx >= 0) path = path[0 .. qIdx];
        if (path.length > 0 && path[$ - 1] == '/') path = path[0 .. $ - 1];
        for (long i = cast(long) path.length - 1; i >= 0; i--) {
            if (path[cast(size_t) i] == '/') return path[cast(size_t)(i + 1) .. $];
        }
        return path;
    }

    private string extractPathAfterPrefix(string uri, string prefix) {
        auto qIdx = uri.indexOf('?');
        if (qIdx >= 0) uri = uri[0 .. qIdx];
        if (uri.length > prefix.length && uri[0 .. prefix.length] == prefix) {
            return uri[prefix.length .. $];
        }
        return uri;
    }
}
