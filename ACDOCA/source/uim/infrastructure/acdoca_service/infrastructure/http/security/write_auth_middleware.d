module uim.infrastructure.acdoca_service.infrastructure.http.security.write_auth_middleware;

import std.string : split, startsWith, strip, toLower;
import std.conv : to;
import vibe.http.server : HTTPServerRequest, HTTPServerResponse;

class WriteAuthMiddleware {
    private string mode;
    private string staticToken;
    private string jwtToken;
    private string requiredScope;
    private string[][string] oauthScopesByToken;

    this(
        string mode,
        string staticToken,
        string jwtToken,
        string requiredScope,
        string oauthTokenMap
    ) {
        this.mode = mode.toLower.strip;
        this.staticToken = staticToken.strip;
        this.jwtToken = jwtToken.strip;
        this.requiredScope = requiredScope.strip.length == 0 ? "acdoca.write" : requiredScope.strip;
        this.oauthScopesByToken = parseOauthTokenMap(oauthTokenMap);
    }

    bool authorizeWrite(HTTPServerRequest req, HTTPServerResponse res) {
        if (mode == "none" || mode.length == 0) {
            return true;
        }

        auto authHeader = req.headers.get("Authorization", "");
        if (isAuthorizedHeader(authHeader)) {
            return true;
        }

        writeUnauthorized(req, res);
        return false;
    }

    bool isAuthorizedHeader(string authHeader) {
        auto token = extractBearerToken(authHeader);
        if (token.length == 0) {
            return false;
        }

        if (mode == "bearer") {
            return staticToken.length > 0 && token == staticToken;
        }

        if (mode == "jwt") {
            if (!looksLikeJwt(token)) {
                return false;
            }
            if (jwtToken.length == 0) {
                return false;
            }
            return token == jwtToken;
        }

        if (mode == "oauth2") {
            if (auto scopes = token in oauthScopesByToken) {
                foreach (item; *scopes) {
                    if (item == requiredScope) {
                        return true;
                    }
                }
            }
            return false;
        }

        return false;
    }

    private string extractBearerToken(string authHeader) {
        auto header = authHeader.strip;
        if (!header.startsWith("Bearer ")) {
            return "";
        }
        return header[7 .. $].strip;
    }

    private bool looksLikeJwt(string token) {
        auto parts = split(token, ".");
        return parts.length == 3 && parts[0].length > 0 && parts[1].length > 0 && parts[2].length > 0;
    }

    private string[][string] parseOauthTokenMap(string source) {
        string[][string] map;

        foreach (entry; split(source, ";")) {
            auto trimmed = entry.strip;
            if (trimmed.length == 0) {
                continue;
            }

            auto kv = split(trimmed, "=");
            if (kv.length != 2) {
                continue;
            }

            auto token = kv[0].strip;
            auto scopeText = kv[1].strip;
            if (token.length == 0 || scopeText.length == 0) {
                continue;
            }

            string[] scopes;
            foreach (item; split(scopeText, "|")) {
                auto cleaned = item.strip;
                if (cleaned.length > 0) {
                    scopes ~= cleaned;
                }
            }
            if (scopes.length > 0) {
                map[token] = scopes;
            }
        }

        return map;
    }

    private void writeUnauthorized(HTTPServerRequest req, HTTPServerResponse res) {
        auto path = req.requestPath.to!string;
        if (path.length >= 4 && path[0 .. 4] == "/v1/") {
            res.writeBody("{ \"error\": \"unauthorized\" }", 401, "application/json");
            return;
        }

        res.writeBody("<h1>401 Unauthorized</h1>", 401, "text/html; charset=utf-8");
    }
}

unittest {
    auto middleware = new WriteAuthMiddleware("bearer", "abc", "", "acdoca.write", "");
    assert(middleware.isAuthorizedHeader("Bearer abc"));
    assert(!middleware.isAuthorizedHeader("Bearer xyz"));
}

unittest {
    auto middleware = new WriteAuthMiddleware(
        "oauth2",
        "",
        "",
        "acdoca.write",
        "tokenA=acdoca.read|acdoca.write;tokenB=acdoca.read"
    );

    assert(middleware.isAuthorizedHeader("Bearer tokenA"));
    assert(!middleware.isAuthorizedHeader("Bearer tokenB"));
}
