module uim.infrastructure.cinder.infrastructure.http.controllers.cinder;

import std.conv : to;
import std.exception : collectException;
import std.string : split;
import std.uuid : randomUUID;
import uim.infrastructure.cinder.application.dto.cinder_command :
    CreateSnapshotCommand,
    CreateVolumeCommand,
    VolumeAttachCommand,
    VolumeDetachCommand;
import uim.infrastructure.cinder.application.usecases.attach_volume : AttachVolumeUseCase;
import uim.infrastructure.cinder.application.usecases.create_snapshot : CreateSnapshotUseCase;
import uim.infrastructure.cinder.application.usecases.create_volume : CreateVolumeUseCase;
import uim.infrastructure.cinder.application.usecases.delete_snapshot : DeleteSnapshotUseCase;
import uim.infrastructure.cinder.application.usecases.delete_volume : DeleteVolumeUseCase;
import uim.infrastructure.cinder.application.usecases.detach_volume : DetachVolumeUseCase;
import uim.infrastructure.cinder.application.usecases.get_snapshot : GetSnapshotUseCase;
import uim.infrastructure.cinder.application.usecases.get_volume : GetVolumeUseCase;
import uim.infrastructure.cinder.application.usecases.list_snapshots : ListSnapshotsUseCase;
import uim.infrastructure.cinder.application.usecases.list_volume_types : ListVolumeTypesUseCase;
import uim.infrastructure.cinder.application.usecases.list_volumes : ListVolumesUseCase;
import uim.infrastructure.cinder.domain.entities.snapshot : Snapshot, snapshotStatusToString;
import uim.infrastructure.cinder.domain.entities.volume : Volume, volumeStatusToString;
import uim.infrastructure.cinder.domain.entities.volume_type : VolumeType;
import vibe.data.json : Json, serializeToJsonString;
import vibe.http.common : HTTPStatus;
import vibe.http.router : URLRouter;
import vibe.http.server : HTTPServerRequest, HTTPServerResponse;

class CinderController {
    private enum string openstackApiService = "volume";

    private ListVolumeTypesUseCase listVolumeTypesUseCase;
    private ListVolumesUseCase listVolumesUseCase;
    private GetVolumeUseCase getVolumeUseCase;
    private CreateVolumeUseCase createVolumeUseCase;
    private DeleteVolumeUseCase deleteVolumeUseCase;
    private AttachVolumeUseCase attachVolumeUseCase;
    private DetachVolumeUseCase detachVolumeUseCase;
    private ListSnapshotsUseCase listSnapshotsUseCase;
    private GetSnapshotUseCase getSnapshotUseCase;
    private CreateSnapshotUseCase createSnapshotUseCase;
    private DeleteSnapshotUseCase deleteSnapshotUseCase;
    private string microversionDefault;
    private string microversionMin;
    private string microversionMax;

    this(
        ListVolumeTypesUseCase listVolumeTypesUseCase,
        ListVolumesUseCase listVolumesUseCase,
        GetVolumeUseCase getVolumeUseCase,
        CreateVolumeUseCase createVolumeUseCase,
        DeleteVolumeUseCase deleteVolumeUseCase,
        AttachVolumeUseCase attachVolumeUseCase,
        DetachVolumeUseCase detachVolumeUseCase,
        ListSnapshotsUseCase listSnapshotsUseCase,
        GetSnapshotUseCase getSnapshotUseCase,
        CreateSnapshotUseCase createSnapshotUseCase,
        DeleteSnapshotUseCase deleteSnapshotUseCase,
        string microversionDefault,
        string microversionMin,
        string microversionMax
    ) {
        this.listVolumeTypesUseCase = listVolumeTypesUseCase;
        this.listVolumesUseCase = listVolumesUseCase;
        this.getVolumeUseCase = getVolumeUseCase;
        this.createVolumeUseCase = createVolumeUseCase;
        this.deleteVolumeUseCase = deleteVolumeUseCase;
        this.attachVolumeUseCase = attachVolumeUseCase;
        this.detachVolumeUseCase = detachVolumeUseCase;
        this.listSnapshotsUseCase = listSnapshotsUseCase;
        this.getSnapshotUseCase = getSnapshotUseCase;
        this.createSnapshotUseCase = createSnapshotUseCase;
        this.deleteSnapshotUseCase = deleteSnapshotUseCase;
        this.microversionDefault = microversionDefault;
        this.microversionMin = microversionMin;
        this.microversionMax = microversionMax;
    }

    void registerRoutes(URLRouter router) {
        router.get("/health", &health);
        router.get("/v3", &versionIndex);
        router.get("/v3/types", &listTypes);
        router.get("/v3/limits", &getLimits);

        router.get("/v3/volumes", &listVolumes);
        router.get("/v3/volumes/detail", &listVolumes);
        router.post("/v3/volumes", &createVolume);
        router.get("/v3/volumes/*", &getVolume);
        router.delete_("/v3/volumes/*", &deleteVolume);
        router.post("/v3/volumes/*/action", &volumeAction);

        router.get("/v3/snapshots", &listSnapshots);
        router.post("/v3/snapshots", &createSnapshot);
        router.get("/v3/snapshots/*", &getSnapshot);
        router.delete_("/v3/snapshots/*", &deleteSnapshot);
    }

    void health(HTTPServerRequest req, HTTPServerResponse res) {
        auto requestId = prepareResponseHeaders(req, res);

        Json payload = Json.emptyObject;
        payload["status"] = Json("ok");
        payload["request_id"] = Json(requestId);
        writeJson(res, payload, HTTPStatus.ok);
    }

    void versionIndex(HTTPServerRequest req, HTTPServerResponse res) {
        prepareResponseHeaders(req, res);

        Json versionObj = Json.emptyObject;
        versionObj["id"] = Json("v3.0");
        versionObj["status"] = Json("CURRENT");
        versionObj["min_version"] = Json(microversionMin);
        versionObj["version"] = Json(microversionMax);

        Json payload = Json.emptyObject;
        payload["version"] = versionObj;

        writeJson(res, payload, HTTPStatus.ok);
    }

    void listTypes(HTTPServerRequest req, HTTPServerResponse res) {
        prepareResponseHeaders(req, res);

        auto types = listVolumeTypesUseCase.execute();
        Json payload = Json.emptyObject;
        payload["volume_types"] = typesToJson(types);
        payload["volume_types_links"] = Json(cast(Json[]) []);
        writeJson(res, payload, HTTPStatus.ok);
    }

    void getLimits(HTTPServerRequest req, HTTPServerResponse res) {
        prepareResponseHeaders(req, res);

        Json absolute = Json.emptyObject;
        absolute["maxTotalVolumes"] = Json(1000);
        absolute["maxTotalSnapshots"] = Json(1000);
        absolute["maxTotalVolumeGigabytes"] = Json(100000);
        absolute["totalVolumesUsed"] = Json(cast(int) listVolumesUseCase.execute().length);
        absolute["totalSnapshotsUsed"] = Json(cast(int) listSnapshotsUseCase.execute().length);

        Json limits = Json.emptyObject;
        limits["absolute"] = absolute;

        Json payload = Json.emptyObject;
        payload["limits"] = limits;

        writeJson(res, payload, HTTPStatus.ok);
    }

    void listVolumes(HTTPServerRequest req, HTTPServerResponse res) {
        prepareResponseHeaders(req, res);

        auto volumes = listVolumesUseCase.execute(readQueryValue(req, "project_id"));
        Json payload = Json.emptyObject;
        payload["volumes"] = volumesToJson(volumes);
        payload["volumes_links"] = Json(cast(Json[]) []);
        writeJson(res, payload, HTTPStatus.ok);
    }

    void createVolume(HTTPServerRequest req, HTTPServerResponse res) {
        prepareResponseHeaders(req, res);

        auto body = requestPayload(req, "volume");

        auto projectId = requireString(body, "project_id");
        auto name = requireString(body, "name");
        auto sizeGiB = requireUlong(body, "size");
        auto description = optionalString(body, "description");
        auto volumeTypeId = optionalString(body, "volume_type", "general-hdd");
        auto availabilityZone = optionalString(body, "availability_zone", "nova");

        auto created = createVolumeUseCase.execute(
            CreateVolumeCommand(projectId, name, description, sizeGiB, volumeTypeId, availabilityZone)
        );

        Json payload = Json.emptyObject;
        payload["volume"] = volumeToJson(created);
        writeJson(res, payload, HTTPStatus.accepted);
    }

    void getVolume(HTTPServerRequest req, HTTPServerResponse res) {
        prepareResponseHeaders(req, res);

        auto id = readWildcardId(req.requestPath.to!string, "/v3/volumes/");
        if (id.length == 0 || hasSuffix(id, "/action")) {
            writeError(res, HTTPStatus.badRequest, "expected /v3/volumes/<id>");
            return;
        }

        auto volume = getVolumeUseCase.execute(id);
        if (volume is null) {
            writeError(res, HTTPStatus.notFound, "volume not found");
            return;
        }

        Json payload = Json.emptyObject;
        payload["volume"] = volumeToJson(*volume);
        writeJson(res, payload, HTTPStatus.ok);
    }

    void deleteVolume(HTTPServerRequest req, HTTPServerResponse res) {
        prepareResponseHeaders(req, res);

        auto id = readWildcardId(req.requestPath.to!string, "/v3/volumes/");
        if (id.length == 0) {
            writeError(res, HTTPStatus.badRequest, "expected /v3/volumes/<id>");
            return;
        }

        auto ok = deleteVolumeUseCase.execute(id);
        if (!ok) {
            writeError(res, HTTPStatus.notFound, "volume not found");
            return;
        }

        res.writeBody("", cast(int) HTTPStatus.accepted, "application/json");
    }

    void volumeAction(HTTPServerRequest req, HTTPServerResponse res) {
        prepareResponseHeaders(req, res);

        auto pathId = readWildcardId(req.requestPath.to!string, "/v3/volumes/");
        auto id = stripActionSuffix(pathId);
        if (id.length == 0) {
            writeError(res, HTTPStatus.badRequest, "expected /v3/volumes/<id>/action");
            return;
        }

        auto body = req.json;

        if (body["os-attach"].type == Json.Type.object) {
            auto attachObj = body["os-attach"];
            auto instanceUuid = requireString(attachObj, "instance_uuid");
            auto mountpoint = optionalString(attachObj, "mountpoint", "/dev/vdb");

            auto ok = attachVolumeUseCase.execute(VolumeAttachCommand(id, instanceUuid, mountpoint));
            if (!ok) {
                writeError(res, HTTPStatus.notFound, "volume not found");
                return;
            }

            res.writeBody("", cast(int) HTTPStatus.accepted, "application/json");
            return;
        }

        if (body["os-detach"].type == Json.Type.object) {
            auto detachObj = body["os-detach"];
            auto attachmentRef = optionalString(detachObj, "attachment_id", "");
            if (attachmentRef.length == 0) {
                auto vol = getVolumeUseCase.execute(id);
                if (vol !is null && vol.attachments.length > 0) {
                    attachmentRef = vol.attachments[0];
                }
            }

            auto ok = detachVolumeUseCase.execute(VolumeDetachCommand(id, attachmentRef));
            if (!ok) {
                writeError(res, HTTPStatus.notFound, "volume or attachment not found");
                return;
            }

            res.writeBody("", cast(int) HTTPStatus.accepted, "application/json");
            return;
        }

        writeError(res, HTTPStatus.badRequest, "expected os-attach or os-detach action body");
    }

    void listSnapshots(HTTPServerRequest req, HTTPServerResponse res) {
        prepareResponseHeaders(req, res);

        auto snapshots = listSnapshotsUseCase.execute(readQueryValue(req, "project_id"));
        Json payload = Json.emptyObject;
        payload["snapshots"] = snapshotsToJson(snapshots);
        payload["snapshots_links"] = Json(cast(Json[]) []);
        writeJson(res, payload, HTTPStatus.ok);
    }

    void createSnapshot(HTTPServerRequest req, HTTPServerResponse res) {
        prepareResponseHeaders(req, res);

        auto body = requestPayload(req, "snapshot");

        auto projectId = requireString(body, "project_id");
        auto volumeId = requireString(body, "volume_id");
        auto name = requireString(body, "name");
        auto description = optionalString(body, "description");

        try {
            auto created = createSnapshotUseCase.execute(
                CreateSnapshotCommand(projectId, volumeId, name, description)
            );

            Json payload = Json.emptyObject;
            payload["snapshot"] = snapshotToJson(created);
            writeJson(res, payload, HTTPStatus.accepted);
        } catch (Exception ex) {
            writeError(res, HTTPStatus.badRequest, ex.msg);
        }
    }

    void getSnapshot(HTTPServerRequest req, HTTPServerResponse res) {
        prepareResponseHeaders(req, res);

        auto id = readWildcardId(req.requestPath.to!string, "/v3/snapshots/");
        if (id.length == 0) {
            writeError(res, HTTPStatus.badRequest, "expected /v3/snapshots/<id>");
            return;
        }

        auto snapshot = getSnapshotUseCase.execute(id);
        if (snapshot is null) {
            writeError(res, HTTPStatus.notFound, "snapshot not found");
            return;
        }

        Json payload = Json.emptyObject;
        payload["snapshot"] = snapshotToJson(*snapshot);
        writeJson(res, payload, HTTPStatus.ok);
    }

    void deleteSnapshot(HTTPServerRequest req, HTTPServerResponse res) {
        prepareResponseHeaders(req, res);

        auto id = readWildcardId(req.requestPath.to!string, "/v3/snapshots/");
        if (id.length == 0) {
            writeError(res, HTTPStatus.badRequest, "expected /v3/snapshots/<id>");
            return;
        }

        auto ok = deleteSnapshotUseCase.execute(id);
        if (!ok) {
            writeError(res, HTTPStatus.notFound, "snapshot not found");
            return;
        }

        res.writeBody("", cast(int) HTTPStatus.accepted, "application/json");
    }

    private string prepareResponseHeaders(HTTPServerRequest req, HTTPServerResponse res) {
        auto requestedMicroversion = requestMicroversion(req);
        auto requestId = "req-" ~ randomUUID().toString();

        res.headers["OpenStack-API-Version"] = openstackApiService ~ " " ~ requestedMicroversion;
        res.headers["X-Openstack-Request-Id"] = requestId;
        res.headers["X-OpenStack-Volume-API-Version"] = requestedMicroversion;

        return requestId;
    }

    private string requestMicroversion(HTTPServerRequest req) {
        auto raw = req.headers.get("OpenStack-API-Version", "");
        if (raw.length == 0) {
            return microversionDefault;
        }

        auto parts = split(raw, " ");
        if (parts.length == 2 && parts[0] == openstackApiService) {
            return parts[1];
        }

        return microversionDefault;
    }

    private Json requestPayload(HTTPServerRequest req, string envelopeKey) {
        auto json = req.json;
        if (json[envelopeKey].type == Json.Type.object) {
            return json[envelopeKey];
        }
        return json;
    }

    private string readWildcardId(string requestPath, string prefix) {
        if (requestPath.length <= prefix.length || requestPath[0 .. prefix.length] != prefix) {
            return "";
        }
        return requestPath[prefix.length .. $];
    }

    private string stripActionSuffix(string value) {
        auto suffix = "/action";
        if (hasSuffix(value, suffix)) {
            return value[0 .. $ - suffix.length];
        }
        return value;
    }

    private bool hasSuffix(string value, string suffix) {
        return value.length >= suffix.length && value[$ - suffix.length .. $] == suffix;
    }

    private string readQueryValue(HTTPServerRequest req, string key) {
        auto value = req.query.get(key, "");
        return value.idup;
    }

    private string requireString(Json json, string key) {
        auto value = json[key];
        if (value.type != Json.Type.string) {
            throw new Exception("missing or invalid field: " ~ key);
        }
        auto str = value.get!string;
        if (str.length == 0) {
            throw new Exception("missing or invalid field: " ~ key);
        }
        return str;
    }

    private string optionalString(Json json, string key, string fallback = "") {
        auto value = json[key];
        if (value.type == Json.Type.string) {
            return value.get!string;
        }
        return fallback;
    }

    private ulong requireUlong(Json json, string key) {
        auto value = json[key];
        final switch (value.type) {
            case Json.Type.int_:
                auto num = value.get!long;
                if (num <= 0) {
                    throw new Exception("field must be > 0: " ~ key);
                }
                return cast(ulong) num;
            case Json.Type.float_:
                auto dbl = value.get!double;
                if (dbl <= 0) {
                    throw new Exception("field must be > 0: " ~ key);
                }
                return cast(ulong) dbl;
            case Json.Type.string:
                ulong parsed;
                auto err = collectException(parsed = value.get!string.to!ulong);
                if (err !is null || parsed == 0) {
                    throw new Exception("field must be > 0: " ~ key);
                }
                return parsed;
            case Json.Type.undefined:
            case Json.Type.null_:
            case Json.Type.bigInt:
            case Json.Type.bool_:
            case Json.Type.array:
            case Json.Type.object:
                throw new Exception("missing or invalid field: " ~ key);
        }
    }

    private Json volumesToJson(Volume[] records) {
        Json[] items;
        foreach (record; records) {
            items ~= volumeToJson(record);
        }
        return Json(items);
    }

    private Json volumeToJson(Volume record) {
        Json json = Json.emptyObject;
        json["id"] = Json(record.id);
        json["name"] = Json(record.name);
        json["description"] = Json(record.description);
        json["project_id"] = Json(record.projectId);
        json["size"] = Json(cast(long) record.sizeGiB);
        json["volume_type"] = Json(record.volumeTypeId);
        json["availability_zone"] = Json(record.availabilityZone);
        json["status"] = Json(volumeStatusToString(record.status));
        json["created_at"] = Json(record.createdAt);
        json["attachments"] = attachmentsToJson(record.attachments);
        return json;
    }

    private Json attachmentsToJson(string[] values) {
        Json[] items;
        foreach (value; values) {
            Json item = Json.emptyObject;
            item["attachment_ref"] = Json(value);
            items ~= item;
        }
        return Json(items);
    }

    private Json snapshotsToJson(Snapshot[] records) {
        Json[] items;
        foreach (record; records) {
            items ~= snapshotToJson(record);
        }
        return Json(items);
    }

    private Json snapshotToJson(Snapshot record) {
        Json json = Json.emptyObject;
        json["id"] = Json(record.id);
        json["name"] = Json(record.name);
        json["description"] = Json(record.description);
        json["project_id"] = Json(record.projectId);
        json["volume_id"] = Json(record.volumeId);
        json["size"] = Json(cast(long) record.sizeGiB);
        json["status"] = Json(snapshotStatusToString(record.status));
        json["created_at"] = Json(record.createdAt);
        return json;
    }

    private Json typesToJson(VolumeType[] records) {
        Json[] items;
        foreach (record; records) {
            Json item = Json.emptyObject;
            item["id"] = Json(record.id);
            item["name"] = Json(record.name);
            item["description"] = Json(record.description);
            item["is_public"] = Json(record.isPublic);
            items ~= item;
        }
        return Json(items);
    }

    private void writeError(HTTPServerResponse res, HTTPStatus status, string message) {
        Json payload = Json.emptyObject;
        payload["error"] = Json.emptyObject;
        payload["error"]["message"] = Json(message);
        writeJson(res, payload, status);
    }

    private void writeJson(HTTPServerResponse res, Json body, HTTPStatus status) {
        res.writeBody(serializeToJsonString(body), cast(int) status, "application/json");
    }
}
