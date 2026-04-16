module bs_service.infrastructure.http.controllers.block_storage;

import bs_service.application.dto.volume_command : AttachVolumeCommand, CreateVolumeCommand,
    DeleteVolumeCommand, DetachVolumeCommand, GetVolumeQuery;
import bs_service.application.usecases.attach_volume : AttachVolumeUseCase;
import bs_service.application.usecases.create_volume : CreateVolumeUseCase;
import bs_service.application.usecases.delete_volume : DeleteVolumeUseCase;
import bs_service.application.usecases.detach_volume : DetachVolumeUseCase;
import bs_service.application.usecases.get_volume : GetVolumeUseCase;
import bs_service.application.usecases.list_volumes : ListVolumesUseCase;
import bs_service.domain.entities.block_volume : BlockVolume;
import std.conv : to;
import std.string : split, startsWith;
import vibe.data.json : Json, parseJsonString, serializeToJsonString;
import vibe.http.common : HTTPStatus;
import vibe.http.router : URLRouter;
import vibe.http.server : HTTPServerRequest, HTTPServerResponse;
import vibe.stream.operations : readAllUTF8;

/// JSON-serialisable view of a BlockVolume.
struct BlockVolumeView {
    string id;
    string name;
    ulong  sizeGiB;
    string state;
    string attachedToInstanceId;
    string createdAt;
}

class BlockStorageController {
    private CreateVolumeUseCase createUseCase;
    private DeleteVolumeUseCase deleteUseCase;
    private AttachVolumeUseCase attachUseCase;
    private DetachVolumeUseCase detachUseCase;
    private ListVolumesUseCase  listUseCase;
    private GetVolumeUseCase    getUseCase;

    this(
        CreateVolumeUseCase createUseCase,
        DeleteVolumeUseCase deleteUseCase,
        AttachVolumeUseCase attachUseCase,
        DetachVolumeUseCase detachUseCase,
        ListVolumesUseCase  listUseCase,
        GetVolumeUseCase    getUseCase
    ) {
        this.createUseCase = createUseCase;
        this.deleteUseCase = deleteUseCase;
        this.attachUseCase = attachUseCase;
        this.detachUseCase = detachUseCase;
        this.listUseCase   = listUseCase;
        this.getUseCase    = getUseCase;
    }

    void registerRoutes(URLRouter router) {
        router.get    ("/health",                  &health);
        router.get    ("/v1/volumes",              &listVolumes);
        router.post   ("/v1/volumes",              &createVolume);
        router.get    ("/v1/volumes/*",            &getVolume);
        router.delete_("/v1/volumes/*",            &deleteVolume);
        router.post   ("/v1/volumes/*/attach",     &attachVolume);
        router.post   ("/v1/volumes/*/detach",     &detachVolume);
    }

    // GET /health
    void health(HTTPServerRequest req, HTTPServerResponse res) {
        writeJson(res, `{ "status": "ok" }`, HTTPStatus.ok);
    }

    // GET /v1/volumes
    void listVolumes(HTTPServerRequest req, HTTPServerResponse res) {
        auto vols = listUseCase.execute();
        writeJson(res, serializeToJsonString(volumesToViews(vols)), HTTPStatus.ok);
    }

    // POST /v1/volumes
    // Body: { "name": "<name>", "sizeGiB": <number> }
    void createVolume(HTTPServerRequest req, HTTPServerResponse res) {
        try {
            auto body_ = req.bodyReader.readAllUTF8();
            auto json  = parseJsonString(body_);

            auto name    = json["name"].get!string;
            auto sizeGiB = json["sizeGiB"].get!ulong;

            auto vol = createUseCase.execute(CreateVolumeCommand(name, sizeGiB));
            writeJson(res, serializeToJsonString(volumeToView(vol)), HTTPStatus.created);
        } catch (Exception ex) {
            writeJson(res, `{ "error": "` ~ ex.msg ~ `" }`, HTTPStatus.badRequest);
        }
    }

    // GET /v1/volumes/<id>
    void getVolume(HTTPServerRequest req, HTTPServerResponse res) {
        auto id = extractId(req.requestPath.to!string, "/v1/volumes/");
        if (id.length == 0) {
            writeJson(res, `{ "error": "expected /v1/volumes/<id>" }`, HTTPStatus.badRequest);
            return;
        }

        try {
            auto vol = getUseCase.execute(GetVolumeQuery(id));
            if (vol is null) {
                writeJson(res, `{ "error": "volume not found" }`, HTTPStatus.notFound);
                return;
            }
            writeJson(res, serializeToJsonString(volumeToView(*vol)), HTTPStatus.ok);
        } catch (Exception ex) {
            writeJson(res, `{ "error": "` ~ ex.msg ~ `" }`, HTTPStatus.badRequest);
        }
    }

    // DELETE /v1/volumes/<id>
    void deleteVolume(HTTPServerRequest req, HTTPServerResponse res) {
        auto id = extractId(req.requestPath.to!string, "/v1/volumes/");
        if (id.length == 0) {
            writeJson(res, `{ "error": "expected /v1/volumes/<id>" }`, HTTPStatus.badRequest);
            return;
        }

        try {
            deleteUseCase.execute(DeleteVolumeCommand(id));
            res.writeBody("", cast(int) HTTPStatus.noContent, "application/json");
        } catch (Exception ex) {
            writeJson(res, `{ "error": "` ~ ex.msg ~ `" }`, HTTPStatus.badRequest);
        }
    }

    // POST /v1/volumes/<id>/attach
    // Body: { "instanceId": "<instance-id>" }
    void attachVolume(HTTPServerRequest req, HTTPServerResponse res) {
        auto id = extractIdBeforeSuffix(req.requestPath.to!string, "/v1/volumes/", "/attach");
        if (id.length == 0) {
            writeJson(res, `{ "error": "expected /v1/volumes/<id>/attach" }`, HTTPStatus.badRequest);
            return;
        }

        try {
            auto body_      = req.bodyReader.readAllUTF8();
            auto json       = parseJsonString(body_);
            auto instanceId = json["instanceId"].get!string;

            auto vol = attachUseCase.execute(AttachVolumeCommand(id, instanceId));
            writeJson(res, serializeToJsonString(volumeToView(vol)), HTTPStatus.ok);
        } catch (Exception ex) {
            writeJson(res, `{ "error": "` ~ ex.msg ~ `" }`, HTTPStatus.badRequest);
        }
    }

    // POST /v1/volumes/<id>/detach
    void detachVolume(HTTPServerRequest req, HTTPServerResponse res) {
        auto id = extractIdBeforeSuffix(req.requestPath.to!string, "/v1/volumes/", "/detach");
        if (id.length == 0) {
            writeJson(res, `{ "error": "expected /v1/volumes/<id>/detach" }`, HTTPStatus.badRequest);
            return;
        }

        try {
            auto vol = detachUseCase.execute(DetachVolumeCommand(id));
            writeJson(res, serializeToJsonString(volumeToView(vol)), HTTPStatus.ok);
        } catch (Exception ex) {
            writeJson(res, `{ "error": "` ~ ex.msg ~ `" }`, HTTPStatus.badRequest);
        }
    }

    private BlockVolumeView[] volumesToViews(scope const BlockVolume[] vols) {
        BlockVolumeView[] views;
        foreach (v; vols) {
            views ~= volumeToView(v);
        }
        return views;
    }

    private BlockVolumeView volumeToView(in BlockVolume v) {
        return BlockVolumeView(
            v.id,
            v.name,
            v.sizeGiB,
            cast(string) v.state,
            v.attachedToInstanceId,
            v.createdAt.toISOExtString()
        );
    }

    /// Extract the first path segment after `prefix`.
    private string extractId(string requestPath, string prefix) {
        if (!requestPath.startsWith(prefix)) {
            return "";
        }
        auto segments = split(requestPath[prefix.length .. $], "/");
        return segments.length > 0 ? segments[0] : "";
    }

    /// Extract the segment between `prefix` and `suffix`.
    private string extractIdBeforeSuffix(string requestPath, string prefix, string suffix) {
        if (!requestPath.startsWith(prefix)) {
            return "";
        }
        auto rest = requestPath[prefix.length .. $];
        auto suffixPos = rest.length >= suffix.length
            ? rest[$ - suffix.length .. $]
            : "";
        if (suffixPos != suffix) {
            return "";
        }
        return rest[0 .. $ - suffix.length];
    }

    private void writeJson(HTTPServerResponse res, string body_, HTTPStatus status) {
        res.writeBody(body_, cast(int) status, "application/json");
    }
}
