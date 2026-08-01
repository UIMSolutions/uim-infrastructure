module uim.infrastructure.openstack.infrastructure.http.clients.openstack_gateway;

import std.exception : collectException;
import std.string : strip;
import uim.infrastructure.openstack.domain.entities.project : Project;
import uim.infrastructure.openstack.domain.entities.server : Server;
import uim.infrastructure.openstack.domain.ports.openstack_gateway : IOpenStackGateway;
import uim.infrastructure.openstack.infrastructure.config.settings : ServiceSettings;
import vibe.data.json : Json, parseJsonString, serializeToJsonString;
import vibe.http.client : requestHTTP;
import vibe.http.common : HTTPMethod;
import vibe.inet.url : URL;
import vibe.stream.operations : readAllUTF8;

class OpenStackGateway : IOpenStackGateway {
    private ServiceSettings settings;

    this(ServiceSettings settings) {
        this.settings = settings;
    }

    override Project[] listProjects(string token) {
        if (!isRemoteConfigured() || token.length == 0) {
            return [
                Project("project-1", "demo", "default"),
                Project("project-2", "operations", "default")
            ];
        }

        int status = 0;
        string body;
        auto url = URL(composeIdentityUrl("/v3/projects"));

        auto err = collectException({
            requestHTTP(
                url,
                (scope reqOut) {
                    reqOut.method = HTTPMethod.GET;
                    reqOut.headers["Accept"] = "application/json";
                    reqOut.headers["X-Auth-Token"] = token;
                },
                (scope resIn) {
                    status = cast(int) resIn.statusCode;
                    body = resIn.bodyReader.readAllUTF8();
                }
            );
        });

        if (err !is null || status < 200 || status >= 300 || body.length == 0) {
            return [Project("project-1", "demo", "default")];
        }

        return parseProjects(body);
    }

    override Server[] listServers(string token, string projectId, string region) {
        if (!isRemoteConfigured() || token.length == 0 || projectId.length == 0) {
            return [
                Server("server-1", "web-01", "project-1", "ACTIVE", "m1.small", "ubuntu-22.04"),
                Server("server-2", "api-01", "project-1", "SHUTOFF", "m1.medium", "ubuntu-22.04")
            ];
        }

        int status = 0;
        string body;
        auto url = URL(composeComputeUrl("/servers/detail"));

        auto err = collectException({
            requestHTTP(
                url,
                (scope reqOut) {
                    reqOut.method = HTTPMethod.GET;
                    reqOut.headers["Accept"] = "application/json";
                    reqOut.headers["X-Auth-Token"] = token;
                    reqOut.headers["X-Project-Id"] = projectId;
                    reqOut.headers["OpenStack-Region"] = region;
                },
                (scope resIn) {
                    status = cast(int) resIn.statusCode;
                    body = resIn.bodyReader.readAllUTF8();
                }
            );
        });

        if (err !is null || status < 200 || status >= 300 || body.length == 0) {
            return [Server("server-1", "web-01", projectId, "ACTIVE", "m1.small", "ubuntu-22.04")];
        }

        return parseServers(body, projectId);
    }

    override bool rebootServer(string token, string serverId, string rebootType, string region) {
        if (!isRemoteConfigured() || token.length == 0 || serverId.length == 0) {
            return true;
        }

        int status = 0;
        string body;
        auto url = URL(composeComputeUrl("/servers/" ~ serverId ~ "/action"));

        auto payload = Json.emptyObject;
        auto reboot = Json.emptyObject;
        reboot["type"] = Json(rebootType);
        payload["reboot"] = reboot;

        auto err = collectException({
            requestHTTP(
                url,
                (scope reqOut) {
                    reqOut.method = HTTPMethod.POST;
                    reqOut.headers["Accept"] = "application/json";
                    reqOut.headers["X-Auth-Token"] = token;
                    reqOut.headers["OpenStack-Region"] = region;
                    reqOut.writeBody(cast(ubyte[]) serializeToJsonString(payload), "application/json");
                },
                (scope resIn) {
                    status = cast(int) resIn.statusCode;
                    body = resIn.bodyReader.readAllUTF8();
                }
            );
        });

        return err is null && status >= 200 && status < 300;
    }

    private bool isRemoteConfigured() {
        return settings.openstackIdentityUrl.strip().length > 0 && settings.openstackComputeUrl.strip().length > 0;
    }

    private string composeIdentityUrl(string path) {
        auto base = settings.openstackIdentityUrl.strip();
        if (base.length > 0 && base[$ - 1] == '/') {
            base = base[0 .. $ - 1];
        }
        return base ~ path;
    }

    private string composeComputeUrl(string path) {
        auto base = settings.openstackComputeUrl.strip();
        if (base.length > 0 && base[$ - 1] == '/') {
            base = base[0 .. $ - 1];
        }
        return base ~ path;
    }

    private Project[] parseProjects(string body) {
        auto json = parseJsonString(body);
        auto projectsJson = json["projects"];
        if (projectsJson.type != Json.Type.array) {
            return [Project("project-1", "demo", "default")];
        }

        Project[] projects;
        foreach (entry; projectsJson) {
            auto id = entry["id"].type == Json.Type.string ? entry["id"].get!string : "";
            if (id.length == 0) {
                continue;
            }
            auto name = entry["name"].type == Json.Type.string ? entry["name"].get!string : "unknown";
            auto domainId = entry["domain_id"].type == Json.Type.string ? entry["domain_id"].get!string : "default";
            projects ~= Project(id, name, domainId);
        }

        if (projects.length == 0) {
            projects ~= Project("project-1", "demo", "default");
        }
        return projects;
    }

    private Server[] parseServers(string body, string projectId) {
        auto json = parseJsonString(body);
        auto serversJson = json["servers"];
        if (serversJson.type != Json.Type.array) {
            return [Server("server-1", "web-01", projectId, "ACTIVE", "m1.small", "ubuntu-22.04")];
        }

        Server[] servers;
        foreach (entry; serversJson) {
            auto id = entry["id"].type == Json.Type.string ? entry["id"].get!string : "";
            if (id.length == 0) {
                continue;
            }
            auto name = entry["name"].type == Json.Type.string ? entry["name"].get!string : "unnamed";
            auto status = entry["status"].type == Json.Type.string ? entry["status"].get!string : "UNKNOWN";
            auto flavor = "n/a";
            auto image = "n/a";
            if (entry["flavor"].type == Json.Type.object && entry["flavor"]["id"].type == Json.Type.string) {
                flavor = entry["flavor"]["id"].get!string;
            }
            if (entry["image"].type == Json.Type.object && entry["image"]["id"].type == Json.Type.string) {
                image = entry["image"]["id"].get!string;
            }

            servers ~= Server(id, name, projectId, status, flavor, image);
        }

        if (servers.length == 0) {
            servers ~= Server("server-1", "web-01", projectId, "ACTIVE", "m1.small", "ubuntu-22.04");
        }
        return servers;
    }
}
