module uim.infrastructure.manila.infrastructure.http.controllers.manila;

import std.conv : to;
import std.exception : collectException;
import std.string : split, startsWith, strip;
import std.uuid : randomUUID;
import uim.infrastructure.manila.application.dto.manila_command : CreateShareCommand, CreateSnapshotCommand;
import uim.infrastructure.manila.application.usecases.create_share : CreateShareUseCase;
import uim.infrastructure.manila.application.usecases.create_snapshot : CreateSnapshotUseCase;
import uim.infrastructure.manila.application.usecases.delete_share : DeleteShareUseCase;
import uim.infrastructure.manila.application.usecases.get_quota_set : GetQuotaSetUseCase;
import uim.infrastructure.manila.application.usecases.get_share : GetShareUseCase;
import uim.infrastructure.manila.application.usecases.list_share_types : ListShareTypesUseCase;
import uim.infrastructure.manila.application.usecases.list_shares : ListSharesUseCase;
import uim.infrastructure.manila.application.usecases.list_snapshots : ListSnapshotsUseCase;
import uim.infrastructure.manila.domain.entities.quota_set : QuotaSet;
import uim.infrastructure.manila.domain.entities.share : Share, shareStatusToString;
import uim.infrastructure.manila.domain.entities.share_snapshot : ShareSnapshot, snapshotStatusToString;
import uim.infrastructure.manila.domain.entities.share_type : ShareType, shareProtocolFromString, shareProtocolToString;
import uim.infrastructure.manila.infrastructure.auth.token_validator : ITokenValidator, TokenContext;
import vibe.data.json : Json, serializeToJsonString;
import vibe.http.common : HTTPStatus;
import vibe.http.router : URLRouter;
import vibe.http.server : HTTPServerRequest, HTTPServerResponse;

struct ShareTypeView {
    string id;
    string name;
    string description;
    string[string] extra_specs;
    bool is_public;
}

struct ShareView {
    string id;
    string project_id;
    string name;
    string description;
    ulong size;
    string share_proto;
    string share_type;
    string availability_zone;
    string status;
    string[] export_locations;
    string created_at;
}

struct SnapshotView {
    string id;
    string share_id;
    string project_id;
    string name;
    string description;
    ulong size;
    string status;
    string created_at;
}

struct QuotaSetView {
    string id;
    uint shares;
    ulong gigabytes;
    uint snapshots;
    uint shares_in_use;
    ulong gigabytes_in_use;
    uint snapshots_in_use;
}

struct ShareTypesEnvelope {
    ShareTypeView[] share_types;
    string[] share_type_links;
}

struct SharesEnvelope {
    ShareView[] shares;
    string[] shares_links;
}

struct ShareEnvelope {
    ShareView share;
}

struct SnapshotsEnvelope {
    SnapshotView[] snapshots;
    string[] snapshots_links;
}

struct SnapshotEnvelope {
    SnapshotView snapshot;
}

struct QuotaEnvelope {
    QuotaSetView quota_set;
}

class ManilaController {
    private enum string openstackApiService = "share";

    private ListShareTypesUseCase listShareTypesUseCase;
    private ListSharesUseCase listSharesUseCase;
    private CreateShareUseCase createShareUseCase;
    private GetShareUseCase getShareUseCase;
    private DeleteShareUseCase deleteShareUseCase;
    private ListSnapshotsUseCase listSnapshotsUseCase;
    private CreateSnapshotUseCase createSnapshotUseCase;
    private GetQuotaSetUseCase getQuotaSetUseCase;
    private ITokenValidator tokenValidator;
    private string microversionDefault;
    private string microversionMin;
    private string microversionMax;

    this(
        ListShareTypesUseCase listShareTypesUseCase,
        ListSharesUseCase listSharesUseCase,
        CreateShareUseCase createShareUseCase,
        GetShareUseCase getShareUseCase,
        DeleteShareUseCase deleteShareUseCase,
        ListSnapshotsUseCase listSnapshotsUseCase,
        CreateSnapshotUseCase createSnapshotUseCase,
        GetQuotaSetUseCase getQuotaSetUseCase,
        ITokenValidator tokenValidator,
        string microversionDefault,
        string microversionMin,
        string microversionMax
    ) {
        this.listShareTypesUseCase = listShareTypesUseCase;
        this.listSharesUseCase = listSharesUseCase;
        this.createShareUseCase = createShareUseCase;
        this.getShareUseCase = getShareUseCase;
        this.deleteShareUseCase = deleteShareUseCase;
        this.listSnapshotsUseCase = listSnapshotsUseCase;
        this.createSnapshotUseCase = createSnapshotUseCase;
        this.getQuotaSetUseCase = getQuotaSetUseCase;
        this.tokenValidator = tokenValidator;
        this.microversionDefault = microversionDefault;
        this.microversionMin = microversionMin;
        this.microversionMax = microversionMax;
    }

    void registerRoutes(URLRouter router) {
        router.get("/health", &health);
        router.get("/v1/share-types", &listShareTypes);
        router.get("/v1/shares", &listShares);
        router.post("/v1/shares", &createShare);
        router.get("/v1/shares/*", &getShare);
        router.delete_("/v1/shares/*", &deleteShare);
        router.get("/v1/snapshots", &listSnapshots);
        router.post("/v1/snapshots", &createSnapshot);
        router.get("/v1/quotas/*", &getQuota);
    }

    void health(HTTPServerRequest req, HTTPServerResponse res) {
        auto requestId = prepareResponseHeaders(req, res);
        writeJson(res, `{ "status": "ok", "request_id": "` ~ requestId ~ `" }`, HTTPStatus.ok);
    }

    void listShareTypes(HTTPServerRequest req, HTTPServerResponse res) {
        auto auth = authenticate(req, res);
        if (auth is null) {
            return;
        }

        auto types = listShareTypesUseCase.execute();
        writeJson(res, serializeToJsonString(ShareTypesEnvelope(shareTypesToViews(types), [])), HTTPStatus.ok);
    }

    void listShares(HTTPServerRequest req, HTTPServerResponse res) {
        auto auth = authenticate(req, res);
        if (auth is null) {
            return;
        }

        auto requestedProjectId = readQueryValue(req, "project_id");
        auto effectiveProjectId = enforceProjectFilter(auth, requestedProjectId, res);
        if (effectiveProjectId is null) {
            return;
        }

        auto shares = listSharesUseCase.execute(*effectiveProjectId);
        writeJson(res, serializeToJsonString(SharesEnvelope(sharesToViews(shares), [])), HTTPStatus.ok);
    }

    void createShare(HTTPServerRequest req, HTTPServerResponse res) {
        auto auth = authenticate(req, res);
        if (auth is null) {
            return;
        }

        try {
            auto json = requestPayload(req, "share");
            auto projectId = requireString(json, "project_id");
            if (!allowProject(auth, projectId)) {
                writeError(res, HTTPStatus.forbidden, "policy does not allow access to requested project");
                return;
            }

            auto command = CreateShareCommand(
                projectId,
                requireString(json, "name"),
                optionalString(json, "description"),
                requireUnsignedLong(json, "size"),
                shareProtocolFromString(requireString(json, "share_proto")),
                requireString(json, "share_type"),
                optionalString(json, "availability_zone")
            );

            auto share = createShareUseCase.execute(command);
            writeJson(res, serializeToJsonString(ShareEnvelope(shareToView(share))), HTTPStatus.accepted);
        } catch (Exception ex) {
            writeError(res, HTTPStatus.badRequest, ex.msg);
        }
    }

    void getShare(HTTPServerRequest req, HTTPServerResponse res) {
        auto auth = authenticate(req, res);
        if (auth is null) {
            return;
        }

        auto id = readWildcardId(req.requestPath.to!string, "/v1/shares/");
        if (id.length == 0) {
            writeError(res, HTTPStatus.badRequest, "expected /v1/shares/<id>");
            return;
        }

        try {
            auto share = getShareUseCase.execute(id);
            if (share is null) {
                writeError(res, HTTPStatus.notFound, "share not found");
                return;
            }
            if (!allowProject(auth, share.projectId)) {
                writeError(res, HTTPStatus.forbidden, "policy does not allow access to this share");
                return;
            }

            writeJson(res, serializeToJsonString(ShareEnvelope(shareToView(*share))), HTTPStatus.ok);
        } catch (Exception ex) {
            writeError(res, HTTPStatus.badRequest, ex.msg);
        }
    }

    void deleteShare(HTTPServerRequest req, HTTPServerResponse res) {
        auto auth = authenticate(req, res);
        if (auth is null) {
            return;
        }

        auto id = readWildcardId(req.requestPath.to!string, "/v1/shares/");
        if (id.length == 0) {
            writeError(res, HTTPStatus.badRequest, "expected /v1/shares/<id>");
            return;
        }

        try {
            auto share = getShareUseCase.execute(id);
            if (share is null) {
                writeError(res, HTTPStatus.notFound, "share not found");
                return;
            }
            if (!allowProject(auth, share.projectId)) {
                writeError(res, HTTPStatus.forbidden, "policy does not allow deleting this share");
                return;
            }

            deleteShareUseCase.execute(id);
            res.writeBody("", cast(int) HTTPStatus.accepted, "application/json");
        } catch (Exception ex) {
            writeError(res, HTTPStatus.badRequest, ex.msg);
        }
    }

    void listSnapshots(HTTPServerRequest req, HTTPServerResponse res) {
        auto auth = authenticate(req, res);
        if (auth is null) {
            return;
        }

        auto requestedProjectId = readQueryValue(req, "project_id");
        auto effectiveProjectId = enforceProjectFilter(auth, requestedProjectId, res);
        if (effectiveProjectId is null) {
            return;
        }

        auto snapshots = listSnapshotsUseCase.execute(*effectiveProjectId);
        writeJson(res, serializeToJsonString(SnapshotsEnvelope(snapshotsToViews(snapshots), [])), HTTPStatus.ok);
    }

    void createSnapshot(HTTPServerRequest req, HTTPServerResponse res) {
        auto auth = authenticate(req, res);
        if (auth is null) {
            return;
        }

        try {
            auto json = requestPayload(req, "snapshot");
            auto projectId = requireString(json, "project_id");
            if (!allowProject(auth, projectId)) {
                writeError(res, HTTPStatus.forbidden, "policy does not allow access to requested project");
                return;
            }

            auto command = CreateSnapshotCommand(
                projectId,
                requireString(json, "share_id"),
                requireString(json, "name"),
                optionalString(json, "description")
            );

            auto snapshot = createSnapshotUseCase.execute(command);
            writeJson(res, serializeToJsonString(SnapshotEnvelope(snapshotToView(snapshot))), HTTPStatus.accepted);
        } catch (Exception ex) {
            writeError(res, HTTPStatus.badRequest, ex.msg);
        }
    }

    void getQuota(HTTPServerRequest req, HTTPServerResponse res) {
        auto auth = authenticate(req, res);
        if (auth is null) {
            return;
        }

        auto projectId = readWildcardId(req.requestPath.to!string, "/v1/quotas/");
        if (projectId.length == 0) {
            writeError(res, HTTPStatus.badRequest, "expected /v1/quotas/<project_id>");
            return;
        }
        if (!allowProject(auth, projectId)) {
            writeError(res, HTTPStatus.forbidden, "policy does not allow access to requested project");
            return;
        }

        try {
            auto quota = getQuotaSetUseCase.execute(projectId);
            writeJson(res, serializeToJsonString(QuotaEnvelope(quotaToView(quota))), HTTPStatus.ok);
        } catch (Exception ex) {
            writeError(res, HTTPStatus.badRequest, ex.msg);
        }
    }

    private TokenContext* authenticate(HTTPServerRequest req, HTTPServerResponse res) {
        if (!prepareAndValidateMicroversion(req, res)) {
            return null;
        }

        auto token = req.headers.get("X-Auth-Token", "");
        if (token.length == 0) {
            writeError(res, HTTPStatus.unauthorized, "missing X-Auth-Token header");
            return null;
        }

        auto context = tokenValidator.validateToken(token);
        if (context is null) {
            writeError(res, HTTPStatus.unauthorized, "invalid Keystone token");
            return null;
        }
        return context;
    }

    private bool prepareAndValidateMicroversion(HTTPServerRequest req, HTTPServerResponse res) {
        prepareResponseHeaders(req, res);
        auto requested = readMicroversionRequest(req);
        if (requested.length == 0) {
            return true;
        }

        if (!isVersionInRange(requested, microversionMin, microversionMax)) {
            writeError(res, HTTPStatus.notAcceptable, "requested microversion is outside the supported range " ~ microversionMin ~ " - " ~ microversionMax);
            return false;
        }

        applyMicroversionHeaders(res, requested);
        return true;
    }

    private string prepareResponseHeaders(HTTPServerRequest req, HTTPServerResponse res) {
        auto requestId = req.headers.get("X-Openstack-Request-Id", "");
        if (requestId.length == 0) {
            requestId = "req-" ~ randomUUID().toString();
        }
        res.headers["X-Openstack-Request-Id"] = requestId;
        applyMicroversionHeaders(res, microversionDefault);
        return requestId;
    }

    private void applyMicroversionHeaders(HTTPServerResponse res, string microversion) {
        res.headers["OpenStack-API-Version"] = openstackApiService ~ " " ~ microversion;
        res.headers["X-OpenStack-Manila-API-Version"] = microversion;
        res.headers["Vary"] = "OpenStack-API-Version, X-OpenStack-Manila-API-Version";
    }

    private string readMicroversionRequest(HTTPServerRequest req) {
        auto openstackHeader = req.headers.get("OpenStack-API-Version", "").strip();
        if (openstackHeader.length > 0) {
            auto pieces = split(openstackHeader, " ");
            if (pieces.length == 2 && pieces[0] == openstackApiService) {
                return pieces[1].strip();
            }
        }

        return req.headers.get("X-OpenStack-Manila-API-Version", "").strip();
    }

    private bool isVersionInRange(string candidate, string minVersion, string maxVersion) {
        auto parsedCandidate = parseVersion(candidate);
        auto parsedMin = parseVersion(minVersion);
        auto parsedMax = parseVersion(maxVersion);
        if (parsedCandidate is null || parsedMin is null || parsedMax is null) {
            return false;
        }

        return compareVersion(*parsedCandidate, *parsedMin) >= 0 && compareVersion(*parsedCandidate, *parsedMax) <= 0;
    }

    private int compareVersion(int[2] left, int[2] right) {
        if (left[0] < right[0]) return -1;
        if (left[0] > right[0]) return 1;
        if (left[1] < right[1]) return -1;
        if (left[1] > right[1]) return 1;
        return 0;
    }

    private int[2]* parseVersion(string value) {
        auto parts = split(value, ".");
        if (parts.length != 2) {
            return null;
        }

        int major;
        int minor;
        auto err = collectException({
            major = parts[0].to!int;
            minor = parts[1].to!int;
        });
        if (err !is null || major < 0 || minor < 0) {
            return null;
        }

        auto parsed = new int[2];
        (*parsed)[0] = major;
        (*parsed)[1] = minor;
        return parsed;
    }

    private string* enforceProjectFilter(TokenContext* auth, string requestedProjectId, HTTPServerResponse res) {
        if (auth.isAdmin()) {
            return new string(requestedProjectId);
        }

        if (requestedProjectId.length == 0) {
            return new string(auth.projectId);
        }
        if (requestedProjectId != auth.projectId) {
            writeError(res, HTTPStatus.forbidden, "policy does not allow project_id=" ~ requestedProjectId);
            return null;
        }
        return new string(requestedProjectId);
    }

    private bool allowProject(TokenContext* auth, string projectId) {
        return auth.isAdmin() || auth.projectId == projectId;
    }

    private Json requestPayload(HTTPServerRequest req, string envelopeKey) {
        auto json = req.json;
        if (json.type == Json.Type.undefined) {
            throw new Exception("request body must be valid JSON");
        }

        if (json[envelopeKey].type == Json.Type.object) {
            return json[envelopeKey];
        }
        return json;
    }

    private string requireString(Json json, string key) {
        if (json[key].type != Json.Type.string || json[key].get!string.length == 0) {
            throw new Exception(key ~ " must not be empty");
        }
        return json[key].get!string;
    }

    private string optionalString(Json json, string key) {
        return json[key].type == Json.Type.string ? json[key].get!string : "";
    }

    private ulong requireUnsignedLong(Json json, string key) {
        if (json[key].type == Json.Type.int_ || json[key].type == Json.Type.bigInt) {
            auto value = json[key].get!long;
            if (value <= 0) {
                throw new Exception(key ~ " must be greater than zero");
            }
            return cast(ulong) value;
        }
        throw new Exception(key ~ " must be a positive integer");
    }

    private string readQueryValue(HTTPServerRequest req, string key) {
        auto value = key in req.query;
        return value is null ? "" : *value;
    }

    private string readWildcardId(string path, string prefix) {
        if (!path.startsWith(prefix)) {
            return "";
        }

        auto segments = split(path[prefix.length .. $], "/");
        return segments.length == 0 ? "" : segments[0];
    }

    private ShareTypeView[] shareTypesToViews(ShareType[] shareTypes) {
        ShareTypeView[] views;
        foreach (shareType; shareTypes) {
            views ~= ShareTypeView(
                shareType.id,
                shareType.name,
                shareType.description,
                [
                    "snapshot_support": shareType.snapshotSupport ? "true" : "false",
                    "driver_handles_share_servers": shareType.driverHandlesShareServers ? "true" : "false",
                    "storage_protocol": shareProtocolToString(shareType.protocol)
                ],
                true
            );
        }
        return views;
    }

    private ShareView[] sharesToViews(Share[] shares) {
        ShareView[] views;
        foreach (share; shares) {
            views ~= shareToView(share);
        }
        return views;
    }

    private ShareView shareToView(Share share) {
        return ShareView(
            share.id,
            share.projectId,
            share.name,
            share.description,
            share.sizeGiB,
            shareProtocolToString(share.protocol),
            share.shareTypeId,
            share.availabilityZone,
            shareStatusToString(share.status),
            share.exportLocations.dup,
            share.createdAt.toISOExtString()
        );
    }

    private SnapshotView[] snapshotsToViews(ShareSnapshot[] snapshots) {
        SnapshotView[] views;
        foreach (snapshot; snapshots) {
            views ~= snapshotToView(snapshot);
        }
        return views;
    }

    private SnapshotView snapshotToView(ShareSnapshot snapshot) {
        return SnapshotView(
            snapshot.id,
            snapshot.shareId,
            snapshot.projectId,
            snapshot.name,
            snapshot.description,
            snapshot.sizeGiB,
            snapshotStatusToString(snapshot.status),
            snapshot.createdAt.toISOExtString()
        );
    }

    private QuotaSetView quotaToView(QuotaSet quota) {
        return QuotaSetView(
            quota.projectId,
            quota.maxShares,
            quota.maxShareGigabytes,
            quota.maxSnapshots,
            quota.usedShares,
            quota.usedShareGigabytes,
            quota.usedSnapshots
        );
    }

    private void writeJson(HTTPServerResponse res, string body, HTTPStatus status) {
        res.writeBody(body, cast(int) status, "application/json");
    }

    private void writeError(HTTPServerResponse res, HTTPStatus status, string message) {
        string key;
        switch (status) {
            case HTTPStatus.badRequest: key = "badRequest"; break;
            case HTTPStatus.unauthorized: key = "unauthorized"; break;
            case HTTPStatus.forbidden: key = "forbidden"; break;
            case HTTPStatus.notFound: key = "itemNotFound"; break;
            case HTTPStatus.notAcceptable: key = "notAcceptable"; break;
            default: key = "error"; break;
        }

        auto payload = "{ \"" ~ key ~ "\": { \"message\": \"" ~ message ~ "\", \"code\": " ~ (cast(int) status).to!string ~ " } }";
        writeJson(res, payload, status);
    }
}
