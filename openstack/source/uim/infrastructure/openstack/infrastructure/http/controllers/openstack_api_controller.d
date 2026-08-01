module uim.infrastructure.openstack.infrastructure.http.controllers.openstack_api_controller;

import std.string : toLower;
import uim.infrastructure.openstack.application.dto.reboot_server_command : RebootServerCommand;
import uim.infrastructure.openstack.application.usecases.list_projects : ListProjectsUseCase;
import uim.infrastructure.openstack.application.usecases.list_servers : ListServersUseCase;
import uim.infrastructure.openstack.application.usecases.reboot_server : RebootServerUseCase;
import vibe.data.json : Json, serializeToJsonString;
import vibe.http.common : HTTPStatus;
import vibe.http.router : URLRouter;
import vibe.http.server : HTTPServerRequest, HTTPServerResponse;

class OpenStackApiController {
    private ListProjectsUseCase listProjectsUseCase;
    private ListServersUseCase listServersUseCase;
    private RebootServerUseCase rebootServerUseCase;
    private string defaultRegion;

    this(
        ListProjectsUseCase listProjectsUseCase,
        ListServersUseCase listServersUseCase,
        RebootServerUseCase rebootServerUseCase,
        string defaultRegion
    ) {
        this.listProjectsUseCase = listProjectsUseCase;
        this.listServersUseCase = listServersUseCase;
        this.rebootServerUseCase = rebootServerUseCase;
        this.defaultRegion = defaultRegion;
    }

    void registerRoutes(URLRouter router) {
        router.get("/health", &health);
        router.get("/api/v1/projects", &listProjects);
        router.get("/api/v1/servers", &listServers);
        router.post("/api/v1/server-actions", &serverAction);
    }

    void health(HTTPServerRequest req, HTTPServerResponse res) {
        auto body = Json.emptyObject;
        body["status"] = Json("ok");
        body["service"] = Json("uim-openstack-service");
        writeJson(res, body, HTTPStatus.ok);
    }

    void listProjects(HTTPServerRequest req, HTTPServerResponse res) {
        auto token = resolveToken(req);
        auto projects = listProjectsUseCase.execute(token);

        auto data = Json.emptyArray;
        foreach (p; projects) {
            auto item = Json.emptyObject;
            item["id"] = Json(p.id);
            item["name"] = Json(p.name);
            item["domainId"] = Json(p.domainId);
            data ~= item;
        }

        auto payload = Json.emptyObject;
        payload["count"] = Json(cast(int) projects.length);
        payload["data"] = data;
        writeJson(res, payload, HTTPStatus.ok);
    }

    void listServers(HTTPServerRequest req, HTTPServerResponse res) {
        auto token = resolveToken(req);
        auto projectId = readQuery(req, "projectId", "project-1");
        auto region = readQuery(req, "region", defaultRegion);
        auto servers = listServersUseCase.execute(token, projectId, region);

        auto data = Json.emptyArray;
        foreach (s; servers) {
            auto item = Json.emptyObject;
            item["id"] = Json(s.id);
            item["name"] = Json(s.name);
            item["projectId"] = Json(s.projectId);
            item["status"] = Json(s.status);
            item["flavor"] = Json(s.flavor);
            item["image"] = Json(s.image);
            data ~= item;
        }

        auto payload = Json.emptyObject;
        payload["count"] = Json(cast(int) servers.length);
        payload["data"] = data;
        writeJson(res, payload, HTTPStatus.ok);
    }

    void serverAction(HTTPServerRequest req, HTTPServerResponse res) {
        try {
            auto payload = req.json;
            auto action = optionalString(payload, "action", "reboot").toLower();
            if (action != "reboot") {
                writeError(res, HTTPStatus.badRequest, "only reboot action is supported");
                return;
            }

            auto serverId = optionalString(payload, "serverId", "");
            if (serverId.length == 0) {
                writeError(res, HTTPStatus.badRequest, "serverId is required");
                return;
            }

            auto command = RebootServerCommand(
                resolveToken(req),
                serverId,
                optionalString(payload, "rebootType", "SOFT"),
                optionalString(payload, "region", defaultRegion)
            );
            auto accepted = rebootServerUseCase.execute(command);

            auto body = Json.emptyObject;
            body["accepted"] = Json(accepted);
            body["serverId"] = Json(serverId);
            body["action"] = Json("reboot");
            body["rebootType"] = Json(command.rebootType);
            writeJson(res, body, accepted ? HTTPStatus.accepted : HTTPStatus.badGateway);
        } catch (Exception ex) {
            writeError(res, HTTPStatus.badRequest, ex.msg);
        }
    }

    private string resolveToken(HTTPServerRequest req) {
        auto headerToken = req.headers.get("X-Auth-Token", "");
        if (headerToken.length > 0) {
            return headerToken;
        }

        auto auth = req.headers.get("Authorization", "");
        if (auth.length > 7 && auth[0 .. 7].toLower() == "bearer ") {
            return auth[7 .. $];
        }

        return readQuery(req, "token", "");
    }

    private string readQuery(HTTPServerRequest req, string key, string fallback) {
        foreach (kv; req.query.byKeyValue()) {
            if (kv.key == key && kv.value.length > 0) {
                return kv.value;
            }
        }
        return fallback;
    }

    private string optionalString(Json json, string key, string fallback) {
        auto value = json[key];
        return value.type == Json.Type.string ? value.get!string : fallback;
    }

    private void writeError(HTTPServerResponse res, HTTPStatus status, string message) {
        auto body = Json.emptyObject;
        body["error"] = Json(message);
        writeJson(res, body, status);
    }

    private void writeJson(HTTPServerResponse res, Json payload, HTTPStatus status) {
        res.writeBody(serializeToJsonString(payload), cast(int) status, "application/json");
    }
}
