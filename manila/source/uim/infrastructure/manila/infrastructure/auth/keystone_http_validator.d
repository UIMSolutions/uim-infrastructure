module uim.infrastructure.manila.infrastructure.auth.keystone_http_validator;

import std.exception : collectException;
import std.string : strip, toLower;
import uim.infrastructure.manila.infrastructure.auth.token_validator : ITokenValidator, TokenContext;
import vibe.data.json : Json, parseJsonString;
import vibe.http.client : requestHTTP;
import vibe.http.common : HTTPStatus;

/// Keystone-backed token validator with optional fallback validator.
class KeystoneHttpTokenValidator : ITokenValidator {
    private string keystoneUrl;
    private string adminToken;
    private ITokenValidator fallback;

    this(string keystoneUrl, string adminToken, ITokenValidator fallback = null) {
        this.keystoneUrl = stripTrailingSlash(keystoneUrl.strip());
        this.adminToken = adminToken.strip();
        this.fallback = fallback;
    }

    override TokenContext* validateToken(string token) {
        auto remote = validateRemote(token);
        if (remote !is null) {
            return remote;
        }
        return fallback is null ? null : fallback.validateToken(token);
    }

    private TokenContext* validateRemote(string token) {
        if (token.length == 0 || keystoneUrl.length == 0 || adminToken.length == 0) {
            return null;
        }

        int status = 0;
        string body;

        auto err = collectException({
            requestHTTP(
                keystoneUrl ~ "/v3/auth/tokens",
                (scope reqOut) {
                    reqOut.method = "GET";
                    reqOut.headers["X-Auth-Token"] = adminToken;
                    reqOut.headers["X-Subject-Token"] = token;
                    reqOut.headers["Accept"] = "application/json";
                },
                (scope resIn) {
                    status = cast(int) resIn.statusCode;
                    body = resIn.bodyReader.readAllUTF8();
                }
            );
        });

        if (err !is null || status != cast(int) HTTPStatus.ok || body.length == 0) {
            return null;
        }

        TokenContext* parsed;
        auto parseErr = collectException(parsed = parseContext(body));
        return parseErr is null ? parsed : null;
    }

    private TokenContext* parseContext(string body) {
        auto json = parseJsonString(body);
        if (json.type == Json.Type.undefined || json["token"].type != Json.Type.object) {
            return null;
        }

        auto projectId = jsonPathString(json, ["token", "project", "id"]);
        auto userId = jsonPathString(json, ["token", "user", "id"]);
        auto rolesJson = json["token"]["roles"];

        string[] roles;
        if (rolesJson.type == Json.Type.array) {
            foreach (item; rolesJson) {
                if (item.type == Json.Type.object && item["name"].type == Json.Type.string) {
                    roles ~= item["name"].get!string.toLower();
                }
            }
        }
        if (roles.length == 0) {
            roles = ["member"];
        }
        if (projectId.length == 0) {
            return null;
        }
        if (userId.length == 0) {
            userId = "keystone-user";
        }

        auto context = new TokenContext(userId, projectId, roles);
        return context;
    }

    private string jsonPathString(Json root, string[] path) {
        auto current = root;
        foreach (segment; path) {
            current = current[segment];
            if (current.type == Json.Type.undefined) {
                return "";
            }
        }
        return current.type == Json.Type.string ? current.get!string : "";
    }

    private string stripTrailingSlash(string value) {
        if (value.length > 0 && value[$ - 1] == '/') {
            return value[0 .. $ - 1];
        }
        return value;
    }
}
