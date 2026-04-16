module redis_service.infrastructure.http.controllers.redis;

import redis_service.application.dto.cache_command : DeleteValueCommand, GetValueCommand, SetValueCommand;
import redis_service.application.usecases.delete_value : DeleteValueUseCase;
import redis_service.application.usecases.get_value : GetValueUseCase;
import redis_service.application.usecases.list_keys : ListKeysUseCase;
import redis_service.application.usecases.set_value : SetValueUseCase;
import redis_service.domain.entities.cache_entry : CacheEntry;
import std.conv : to;
import std.string : split, startsWith;
import vibe.data.json : serializeToJsonString;
import vibe.http.common : HTTPStatus;
import vibe.http.router : URLRouter;
import vibe.http.server : HTTPServerRequest, HTTPServerResponse;

struct CacheEntryView {
    string key;
    string value;
    long expiresAtUnixMs;
}

class RedisController {
    private SetValueUseCase setUseCase;
    private GetValueUseCase getUseCase;
    private DeleteValueUseCase deleteUseCase;
    private ListKeysUseCase listUseCase;

    this(
        SetValueUseCase setUseCase,
        GetValueUseCase getUseCase,
        DeleteValueUseCase deleteUseCase,
        ListKeysUseCase listUseCase
    ) {
        this.setUseCase    = setUseCase;
        this.getUseCase    = getUseCase;
        this.deleteUseCase = deleteUseCase;
        this.listUseCase   = listUseCase;
    }

    void registerRoutes(URLRouter router) {
        router.get   ("/health",      &health);
        router.get   ("/v1/keys",     &listKeys);
        router.get   ("/v1/keys/*",   &getValue);
        router.post  ("/v1/keys/*",   &setValue);
        router.delete_("/v1/keys/*",  &deleteValue);
    }

    // GET /health
    void health(HTTPServerRequest req, HTTPServerResponse res) {
        writeJson(res, `{ "status": "ok" }`, HTTPStatus.ok);
    }

    // GET /v1/keys
    void listKeys(HTTPServerRequest req, HTTPServerResponse res) {
        auto keys = listUseCase.execute();
        writeJson(res, serializeToJsonString(keys), HTTPStatus.ok);
    }

    // GET /v1/keys/<key>
    void getValue(HTTPServerRequest req, HTTPServerResponse res) {
        auto key = extractPathSegment(req.requestPath.to!string, "/v1/keys/");
        if (key.length == 0) {
            writeJson(res, `{ "error": "expected /v1/keys/<key>" }`, HTTPStatus.badRequest);
            return;
        }

        try {
            auto entry = getUseCase.execute(GetValueCommand(key));
            if (entry.isNull) {
                writeJson(res, `{ "error": "key not found" }`, HTTPStatus.notFound);
                return;
            }
            writeJson(res, serializeToJsonString(CacheEntryView(entry.get.key, entry.get.value, entry.get.expiresAtUnixMs)), HTTPStatus.ok);
        } catch (Exception ex) {
            writeJson(res, `{ "error": "` ~ ex.msg ~ `" }`, HTTPStatus.badRequest);
        }
    }

    // POST /v1/keys/<key>/<value>[/<ttl_seconds>]
    void setValue(HTTPServerRequest req, HTTPServerResponse res) {
        auto segments = splitPathAfterPrefix(req.requestPath.to!string, "/v1/keys/");
        if (segments.length < 2) {
            writeJson(res, `{ "error": "expected /v1/keys/<key>/<value>[/<ttl_seconds>]" }`, HTTPStatus.badRequest);
            return;
        }

        try {
            uint ttl = segments.length >= 3 ? segments[2].to!uint : 0;
            auto command = SetValueCommand(segments[0], segments[1], ttl);
            auto entry = setUseCase.execute(command);
            writeJson(res, serializeToJsonString(CacheEntryView(entry.key, entry.value, entry.expiresAtUnixMs)), HTTPStatus.created);
        } catch (Exception ex) {
            writeJson(res, `{ "error": "` ~ ex.msg ~ `" }`, HTTPStatus.badRequest);
        }
    }

    // DELETE /v1/keys/<key>
    void deleteValue(HTTPServerRequest req, HTTPServerResponse res) {
        auto key = extractPathSegment(req.requestPath.to!string, "/v1/keys/");
        if (key.length == 0) {
            writeJson(res, `{ "error": "expected /v1/keys/<key>" }`, HTTPStatus.badRequest);
            return;
        }

        try {
            deleteUseCase.execute(DeleteValueCommand(key));
            res.writeBody("", cast(int) HTTPStatus.noContent, "application/json");
        } catch (Exception ex) {
            writeJson(res, `{ "error": "` ~ ex.msg ~ `" }`, HTTPStatus.badRequest);
        }
    }

    private string extractPathSegment(string requestPath, string prefix) {
        if (!requestPath.startsWith(prefix)) {
            return "";
        }
        return requestPath[prefix.length .. $];
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
