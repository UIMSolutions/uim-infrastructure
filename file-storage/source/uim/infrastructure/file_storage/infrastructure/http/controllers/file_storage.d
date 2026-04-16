module fs_service.infrastructure.http.controllers.file_storage;

import fs_service.application.dto.file_command : DeleteFileCommand, DownloadFileQuery, UploadFileCommand;
import fs_service.application.usecases.delete_file : DeleteFileUseCase;
import fs_service.application.usecases.download_file : DownloadFileUseCase;
import fs_service.application.usecases.list_files : ListFilesUseCase;
import fs_service.application.usecases.upload_file : UploadFileUseCase;
import fs_service.domain.entities.stored_file : StoredFile;
import std.conv : to;
import std.string : split, startsWith;
import vibe.data.json : serializeToJsonString;
import vibe.http.common : HTTPStatus;
import vibe.http.router : URLRouter;
import vibe.http.server : HTTPServerRequest, HTTPServerResponse;
import vibe.stream.operations : readAll;

/// JSON-serialisable metadata view (no binary data).
struct StoredFileView {
    string id;
    string name;
    string contentType;
    ulong  size;
    string createdAt;
}

class FileStorageController {
    private UploadFileUseCase   uploadUseCase;
    private DownloadFileUseCase downloadUseCase;
    private DeleteFileUseCase   deleteUseCase;
    private ListFilesUseCase    listUseCase;

    this(
        UploadFileUseCase   uploadUseCase,
        DownloadFileUseCase downloadUseCase,
        DeleteFileUseCase   deleteUseCase,
        ListFilesUseCase    listUseCase
    ) {
        this.uploadUseCase   = uploadUseCase;
        this.downloadUseCase = downloadUseCase;
        this.deleteUseCase   = deleteUseCase;
        this.listUseCase     = listUseCase;
    }

    void registerRoutes(URLRouter router) {
        router.get    ("/health",    &health);
        router.get    ("/v1/files",  &listFiles);
        router.post   ("/v1/files",  &uploadFile);
        router.get    ("/v1/files/*", &downloadFile);
        router.delete_("/v1/files/*", &deleteFile);
    }

    // GET /health
    void health(HTTPServerRequest req, HTTPServerResponse res) {
        writeJson(res, `{ "status": "ok" }`, HTTPStatus.ok);
    }

    // GET /v1/files
    void listFiles(HTTPServerRequest req, HTTPServerResponse res) {
        auto files = listUseCase.execute();
        writeJson(res, serializeToJsonString(filesToViews(files)), HTTPStatus.ok);
    }

    // POST /v1/files?name=<filename>
    // Body: raw file bytes; Content-Type header: MIME type of the file.
    void uploadFile(HTTPServerRequest req, HTTPServerResponse res) {
        auto namePtr = "name" in req.query;
        if (namePtr is null || (*namePtr).length == 0) {
            writeJson(res, `{ "error": "query parameter 'name' is required" }`, HTTPStatus.badRequest);
            return;
        }

        auto contentType = req.contentType;
        if (contentType.length == 0) {
            contentType = "application/octet-stream";
        }

        try {
            auto data    = req.bodyReader.readAll();
            auto command = UploadFileCommand(*namePtr, contentType, data);
            auto stored  = uploadUseCase.execute(command);
            writeJson(res, serializeToJsonString(fileToView(stored)), HTTPStatus.created);
        } catch (Exception ex) {
            writeJson(res, `{ "error": "` ~ ex.msg ~ `" }`, HTTPStatus.badRequest);
        }
    }

    // GET /v1/files/<id>
    void downloadFile(HTTPServerRequest req, HTTPServerResponse res) {
        auto segments = splitPathAfterPrefix(req.requestPath.to!string, "/v1/files/");
        if (segments.length == 0 || segments[0].length == 0) {
            writeJson(res, `{ "error": "expected /v1/files/<id>" }`, HTTPStatus.badRequest);
            return;
        }

        try {
            auto file = downloadUseCase.execute(DownloadFileQuery(segments[0]));
            if (file is null) {
                writeJson(res, `{ "error": "file not found" }`, HTTPStatus.notFound);
                return;
            }
            res.headers["Content-Disposition"] = "attachment; filename=\"" ~ file.name ~ "\"";
            res.writeBody(file.data, cast(int) HTTPStatus.ok, file.contentType);
        } catch (Exception ex) {
            writeJson(res, `{ "error": "` ~ ex.msg ~ `" }`, HTTPStatus.badRequest);
        }
    }

    // DELETE /v1/files/<id>
    void deleteFile(HTTPServerRequest req, HTTPServerResponse res) {
        auto segments = splitPathAfterPrefix(req.requestPath.to!string, "/v1/files/");
        if (segments.length == 0 || segments[0].length == 0) {
            writeJson(res, `{ "error": "expected /v1/files/<id>" }`, HTTPStatus.badRequest);
            return;
        }

        try {
            deleteUseCase.execute(DeleteFileCommand(segments[0]));
            res.writeBody("", cast(int) HTTPStatus.noContent, "application/json");
        } catch (Exception ex) {
            writeJson(res, `{ "error": "` ~ ex.msg ~ `" }`, HTTPStatus.badRequest);
        }
    }

    private StoredFileView[] filesToViews(scope const StoredFile[] files) {
        StoredFileView[] views;
        foreach (f; files) {
            views ~= fileToView(f);
        }
        return views;
    }

    private StoredFileView fileToView(in StoredFile f) {
        return StoredFileView(f.id, f.name, f.contentType, f.size, f.createdAt.toISOExtString());
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
