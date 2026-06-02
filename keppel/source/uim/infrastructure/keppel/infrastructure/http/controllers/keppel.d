module uim.infrastructure.keppel.infrastructure.http.controllers.keppel;

import std.algorithm.searching : canFind;
import std.conv : to;
import std.string : split, indexOf;
import vibe.http.router : URLRouter;
import vibe.http.server : HTTPServerRequest, HTTPServerResponse;
import vibe.http.common : HTTPStatus;
import vibe.data.json : Json, serializeToJsonString;
import vibe.stream.operations : readAll, readAllUTF8;
import uim.infrastructure.keppel.application.dto.commands : CreateRepositoryCommand, UpsertTagCommand;
import uim.infrastructure.keppel.application.usecases.create_repository : CreateRepositoryUseCase;
import uim.infrastructure.keppel.application.usecases.delete_repository : DeleteRepositoryUseCase;
import uim.infrastructure.keppel.application.usecases.get_repository : GetRepositoryUseCase;
import uim.infrastructure.keppel.application.usecases.list_repositories : ListRepositoriesUseCase;
import uim.infrastructure.keppel.application.usecases.upsert_tag : UpsertTagUseCase;
import uim.infrastructure.keppel.application.usecases.list_tags : ListTagsUseCase;
import uim.infrastructure.keppel.application.usecases.delete_tag : DeleteTagUseCase;
import uim.infrastructure.keppel.application.usecases.put_manifest : PutManifestUseCase;
import uim.infrastructure.keppel.application.usecases.get_manifest : GetManifestUseCase;
import uim.infrastructure.keppel.application.usecases.put_blob : PutBlobUseCase;
import uim.infrastructure.keppel.application.usecases.get_blob : GetBlobUseCase;
import uim.infrastructure.keppel.domain.entities.repository : Repository, RepositoryVisibility;
import uim.infrastructure.keppel.domain.entities.image_tag : ImageTag;
import uim.infrastructure.keppel.domain.entities.manifest : Manifest;

struct RepositoryView {
    string name;
    string projectId;
    string visibility;
    string createdAt;
    string updatedAt;
    string[] tags;
}

struct TagView {
    string name;
    string digest;
    long sizeBytes;
    string mediaType;
    string createdAt;
}

struct V2TagsListView {
    string name;
    string[] tags;
}

struct ErrorView {
    string error;
    int status;
}

class KeppelController {
    private CreateRepositoryUseCase createRepositoryUC;
    private DeleteRepositoryUseCase deleteRepositoryUC;
    private GetRepositoryUseCase getRepositoryUC;
    private ListRepositoriesUseCase listRepositoriesUC;
    private UpsertTagUseCase upsertTagUC;
    private ListTagsUseCase listTagsUC;
    private DeleteTagUseCase deleteTagUC;
    private PutManifestUseCase putManifestUC;
    private GetManifestUseCase getManifestUC;
    private PutBlobUseCase putBlobUC;
    private GetBlobUseCase getBlobUC;

    this(
        CreateRepositoryUseCase createRepositoryUC,
        DeleteRepositoryUseCase deleteRepositoryUC,
        GetRepositoryUseCase getRepositoryUC,
        ListRepositoriesUseCase listRepositoriesUC,
        UpsertTagUseCase upsertTagUC,
        ListTagsUseCase listTagsUC,
        DeleteTagUseCase deleteTagUC,
        PutManifestUseCase putManifestUC,
        GetManifestUseCase getManifestUC,
        PutBlobUseCase putBlobUC,
        GetBlobUseCase getBlobUC
    ) {
        this.createRepositoryUC = createRepositoryUC;
        this.deleteRepositoryUC = deleteRepositoryUC;
        this.getRepositoryUC = getRepositoryUC;
        this.listRepositoriesUC = listRepositoriesUC;
        this.upsertTagUC = upsertTagUC;
        this.listTagsUC = listTagsUC;
        this.deleteTagUC = deleteTagUC;
        this.putManifestUC = putManifestUC;
        this.getManifestUC = getManifestUC;
        this.putBlobUC = putBlobUC;
        this.getBlobUC = getBlobUC;
    }

    void registerRoutes(URLRouter router) {
        router.get("/health", &health);

        // OCI-ish registry discovery routes.
        router.get("/v2/", &v2Ping);
        router.get("/v2/_catalog", &catalog);
        router.get("/v2/*", &v2GetRoute);
        router.put("/v2/*", &v2PutRoute);

        // Explicit service management routes.
        router.get("/v1/repositories", &listRepositories);
        router.post("/v1/repositories", &createRepository);
        router.get("/v1/repositories/*", &getRepositoryOrTags);
        router.post("/v1/repositories/*", &upsertTag);
        router.delete_("/v1/repositories/*", &deleteRepositoryOrTag);
    }

    void health(HTTPServerRequest req, HTTPServerResponse res) {
        writeJson(res, `{"status":"ok","service":"uim-keppel-service"}`, HTTPStatus.ok);
    }

    void v2Ping(HTTPServerRequest req, HTTPServerResponse res) {
        res.headers["Docker-Distribution-Api-Version"] = "registry/2.0";
        writeJson(res, `{"service":"keppel","api":"registry/2.0"}`, HTTPStatus.ok);
    }

    void catalog(HTTPServerRequest req, HTTPServerResponse res) {
        auto repos = listRepositoriesUC.execute(queryValue(req, "project_id"));
        string[] names;
        foreach (ref repo; repos) names ~= repo.name;
        writeJson(res, serializeToJsonString(["repositories": names]), HTTPStatus.ok);
    }

    void v2GetRoute(HTTPServerRequest req, HTTPServerResponse res) {
        auto path = req.requestPath.to!string;
        auto rest = extractAfterPrefix(path, "/v2/");
        if (rest.length == 0) {
            writeError(res, "unsupported v2 route", HTTPStatus.notFound);
            return;
        }

        if (rest.length > "/tags/list".length && rest[$ - "/tags/list".length .. $] == "/tags/list") {
            v2TagsList(rest, res);
            return;
        }

        auto manifestIdx = rest.indexOf("/manifests/");
        if (manifestIdx >= 0) {
            auto repositoryName = rest[0 .. manifestIdx];
            auto reference = rest[manifestIdx + "/manifests/".length .. $];
            v2GetManifest(repositoryName, reference, res);
            return;
        }

        auto blobIdx = rest.indexOf("/blobs/");
        if (blobIdx >= 0) {
            auto repositoryName = rest[0 .. blobIdx];
            auto digest = rest[blobIdx + "/blobs/".length .. $];
            v2GetBlob(repositoryName, digest, res);
            return;
        }

        writeError(res, "unsupported v2 route", HTTPStatus.notFound);
    }

    void v2PutRoute(HTTPServerRequest req, HTTPServerResponse res) {
        auto path = req.requestPath.to!string;
        auto rest = extractAfterPrefix(path, "/v2/");
        if (rest.length == 0) {
            writeError(res, "unsupported v2 route", HTTPStatus.notFound);
            return;
        }

        auto manifestIdx = rest.indexOf("/manifests/");
        if (manifestIdx >= 0) {
            auto repositoryName = rest[0 .. manifestIdx];
            auto reference = rest[manifestIdx + "/manifests/".length .. $];
            v2PutManifest(repositoryName, reference, req, res);
            return;
        }

        auto blobIdx = rest.indexOf("/blobs/");
        if (blobIdx >= 0) {
            auto repositoryName = rest[0 .. blobIdx];
            auto digest = rest[blobIdx + "/blobs/".length .. $];
            v2PutBlob(repositoryName, digest, req, res);
            return;
        }

        writeError(res, "unsupported v2 route", HTTPStatus.notFound);
    }

    private void v2TagsList(string rest, HTTPServerResponse res) {
        auto suffix = "/tags/list";
        auto repositoryName = rest[0 .. $ - suffix.length];
        if (repositoryName.length == 0) {
            writeError(res, "missing repository name", HTTPStatus.badRequest);
            return;
        }

        auto tags = listTagsUC.execute(repositoryName);
        string[] tagNames;
        foreach (ref tag; tags) tagNames ~= tag.name;

        auto view = V2TagsListView(repositoryName, tagNames);
        writeJson(res, serializeToJsonString(view), HTTPStatus.ok);
    }

    private void v2GetManifest(string repositoryName, string reference, HTTPServerResponse res) {
        if (repositoryName.length == 0 || reference.length == 0) {
            writeError(res, "invalid manifest route", HTTPStatus.badRequest);
            return;
        }

        auto ptr = getManifestUC.execute(repositoryName, reference);
        if (ptr is null) {
            writeError(res, "manifest not found", HTTPStatus.notFound);
            return;
        }

        res.headers["Docker-Content-Digest"] = ptr.digest;
        res.writeBody(ptr.content, cast(int) HTTPStatus.ok, ptr.mediaType);
    }

    private void v2PutManifest(string repositoryName, string reference, HTTPServerRequest req, HTTPServerResponse res) {
        if (repositoryName.length == 0 || reference.length == 0) {
            writeError(res, "invalid manifest route", HTTPStatus.badRequest);
            return;
        }

        try {
            auto content = req.bodyReader.readAllUTF8();
            auto digest = req.headers.get("Docker-Content-Digest", "");
            if (digest.length == 0) {
                digest = "sha256:" ~ fakeDigest(content);
            }
            auto mediaType = req.contentType.length > 0 ? req.contentType : "application/vnd.oci.image.manifest.v1+json";

            auto stored = putManifestUC.execute(repositoryName, reference, digest, mediaType, content);
            res.headers["Docker-Content-Digest"] = stored.digest;
            res.headers["Location"] = "/v2/" ~ repositoryName ~ "/manifests/" ~ reference;
            res.writeBody("", cast(int) HTTPStatus.created, "application/json");
        } catch (Exception ex) {
            auto status = ex.msg.canFind("not found") ? HTTPStatus.notFound : HTTPStatus.badRequest;
            writeError(res, ex.msg, status);
        }
    }

    private void v2GetBlob(string repositoryName, string digest, HTTPServerResponse res) {
        if (repositoryName.length == 0 || digest.length == 0) {
            writeError(res, "invalid blob route", HTTPStatus.badRequest);
            return;
        }

        try {
            auto payload = getBlobUC.execute(repositoryName, digest);
            res.headers["Docker-Content-Digest"] = payload.meta.digest;
            res.writeBody(payload.payload, cast(int) HTTPStatus.ok, payload.meta.mediaType);
        } catch (Exception ex) {
            writeError(res, ex.msg, HTTPStatus.notFound);
        }
    }

    private void v2PutBlob(string repositoryName, string digest, HTTPServerRequest req, HTTPServerResponse res) {
        if (repositoryName.length == 0 || digest.length == 0) {
            writeError(res, "invalid blob route", HTTPStatus.badRequest);
            return;
        }

        try {
            auto payload = req.bodyReader.readAll();
            auto mediaType = req.contentType.length > 0 ? req.contentType : "application/octet-stream";
            auto stored = putBlobUC.execute(repositoryName, digest, mediaType, payload);
            res.headers["Docker-Content-Digest"] = stored.digest;
            res.headers["Location"] = "/v2/" ~ repositoryName ~ "/blobs/" ~ stored.digest;
            res.writeBody("", cast(int) HTTPStatus.created, "application/json");
        } catch (Exception ex) {
            auto status = ex.msg.canFind("not found") ? HTTPStatus.notFound : HTTPStatus.badRequest;
            writeError(res, ex.msg, status);
        }
    }

    void listRepositories(HTTPServerRequest req, HTTPServerResponse res) {
        auto repos = listRepositoriesUC.execute(queryValue(req, "project_id"));
        RepositoryView[] views;
        foreach (ref repo; repos) views ~= toRepositoryView(repo);
        writeJson(res, serializeToJsonString(views), HTTPStatus.ok);
    }

    void createRepository(HTTPServerRequest req, HTTPServerResponse res) {
        try {
            auto json = req.json;
            auto cmd = CreateRepositoryCommand(
                jsonString(json, "name"),
                jsonString(json, "project_id"),
                jsonString(json, "visibility")
            );
            auto created = createRepositoryUC.execute(cmd);
            writeJson(res, serializeToJsonString(toRepositoryView(created)), HTTPStatus.created);
        } catch (Exception ex) {
            if (ex.msg.canFind("already exists")) {
                writeError(res, ex.msg, HTTPStatus.conflict);
                return;
            }
            writeError(res, ex.msg, HTTPStatus.badRequest);
        }
    }

    void getRepositoryOrTags(HTTPServerRequest req, HTTPServerResponse res) {
        auto rest = extractAfterPrefix(req.requestPath.to!string, "/v1/repositories/");
        if (rest.length == 0) {
            writeError(res, "missing repository path", HTTPStatus.badRequest);
            return;
        }

        auto parts = rest.split("/");
        if (parts.length >= 2 && parts[$ - 1] == "tags") {
            auto repoName = rest[0 .. $ - "/tags".length];
            auto tags = listTagsUC.execute(repoName);
            TagView[] views;
            foreach (ref tag; tags) views ~= toTagView(tag);
            writeJson(res, serializeToJsonString(views), HTTPStatus.ok);
            return;
        }

        auto ptr = getRepositoryUC.execute(rest);
        if (ptr is null) {
            writeError(res, "repository not found", HTTPStatus.notFound);
            return;
        }

        writeJson(res, serializeToJsonString(toRepositoryView(*ptr)), HTTPStatus.ok);
    }

    void upsertTag(HTTPServerRequest req, HTTPServerResponse res) {
        auto rest = extractAfterPrefix(req.requestPath.to!string, "/v1/repositories/");
        if (!(rest.length > 5 && rest[$ - 5 .. $] == "/tags")) {
            writeError(res, "route must end with /tags", HTTPStatus.badRequest);
            return;
        }

        auto repoName = rest[0 .. $ - 5];
        if (repoName.length == 0) {
            writeError(res, "missing repository name", HTTPStatus.badRequest);
            return;
        }

        try {
            auto json = req.json;
            auto cmd = UpsertTagCommand(
                repoName,
                jsonString(json, "tag"),
                jsonString(json, "digest"),
                jsonLong(json, "size_bytes"),
                jsonString(json, "media_type")
            );
            auto created = upsertTagUC.execute(cmd);
            writeJson(res, serializeToJsonString(toTagView(created)), HTTPStatus.created);
        } catch (Exception ex) {
            if (ex.msg.canFind("not found")) {
                writeError(res, ex.msg, HTTPStatus.notFound);
                return;
            }
            writeError(res, ex.msg, HTTPStatus.badRequest);
        }
    }

    void deleteRepositoryOrTag(HTTPServerRequest req, HTTPServerResponse res) {
        auto rest = extractAfterPrefix(req.requestPath.to!string, "/v1/repositories/");
        if (rest.length == 0) {
            writeError(res, "missing repository path", HTTPStatus.badRequest);
            return;
        }

        auto marker = "/tags/";
        auto idx = rest.indexOf(marker);
        if (idx >= 0) {
            auto repositoryName = rest[0 .. idx];
            auto tagName = rest[idx + marker.length .. $];
            if (repositoryName.length == 0 || tagName.length == 0) {
                writeError(res, "invalid tag delete path", HTTPStatus.badRequest);
                return;
            }

            try {
                deleteTagUC.execute(repositoryName, tagName);
                res.writeBody("", cast(int) HTTPStatus.noContent, "application/json");
            } catch (Exception ex) {
                writeError(res, ex.msg, HTTPStatus.notFound);
            }
            return;
        }

        try {
            deleteRepositoryUC.execute(rest);
            res.writeBody("", cast(int) HTTPStatus.noContent, "application/json");
        } catch (Exception ex) {
            writeError(res, ex.msg, HTTPStatus.notFound);
        }
    }

    private RepositoryView toRepositoryView(in Repository repository) {
        string[] tagNames;
        foreach (ref tag; repository.tags) tagNames ~= tag.name;

        return RepositoryView(
            repository.name,
            repository.projectId,
            repository.visibility == RepositoryVisibility.public_ ? "public" : "private",
            repository.createdAt,
            repository.updatedAt,
            tagNames
        );
    }

    private TagView toTagView(in ImageTag tag) {
        return TagView(tag.name, tag.digest, tag.sizeBytes, tag.mediaType, tag.createdAt);
    }

    private string extractAfterPrefix(string value, string prefix) {
        if (value.length <= prefix.length) return "";
        if (value[0 .. prefix.length] != prefix) return "";
        return value[prefix.length .. $];
    }

    private string queryValue(HTTPServerRequest req, string key) {
        foreach (kv; req.query.byKeyValue()) {
            if (kv.key == key) return kv.value;
        }
        return "";
    }

    private string jsonString(ref const(Json) json, string key) {
        if (json[key].type == Json.Type.undefined || json[key].type == Json.Type.null_) return "";
        return json[key].to!string;
    }

    private long jsonLong(ref const(Json) json, string key) {
        if (json[key].type == Json.Type.undefined || json[key].type == Json.Type.null_) return 0;
        try return json[key].to!long;
        catch (Exception) return 0;
    }

    private string fakeDigest(string content) {
        import std.digest.sha : sha256Of;
        import std.digest : toHexString;
        auto hash = sha256Of(content);
        return toHexString(hash).idup;
    }

    private void writeJson(HTTPServerResponse res, string body, HTTPStatus status) {
        res.headers["Content-Type"] = "application/json";
        res.writeBody(body, cast(int) status, "application/json");
    }

    private void writeError(HTTPServerResponse res, string message, HTTPStatus status) {
        auto body = ErrorView(message, cast(int) status);
        writeJson(res, serializeToJsonString(body), status);
    }
}
