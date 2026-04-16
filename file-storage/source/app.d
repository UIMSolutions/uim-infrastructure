module app;

import fs_service.application.usecases.delete_file : DeleteFileUseCase;
import fs_service.application.usecases.download_file : DownloadFileUseCase;
import fs_service.application.usecases.list_files : ListFilesUseCase;
import fs_service.application.usecases.upload_file : UploadFileUseCase;
import fs_service.infrastructure.http.controllers.file_storage : FileStorageController;
import fs_service.infrastructure.persistence.memory.file_repository : InMemoryFileRepository;
import std.conv : to;
import std.exception : collectException;
import std.string : fromStringz;
import core.stdc.stdlib : getenv;
import vibe.vibe;

void main() {
    auto settings = new HTTPServerSettings;
    settings.port = readPort();
    settings.bindAddresses = [readBindAddress()];

    auto repository = new InMemoryFileRepository();

    auto controller = new FileStorageController(
        new UploadFileUseCase(repository),
        new DownloadFileUseCase(repository),
        new DeleteFileUseCase(repository),
        new ListFilesUseCase(repository)
    );

    auto router = new URLRouter;
    controller.registerRoutes(router);

    logInfo("File-storage service starting on %s:%d", settings.bindAddresses[0], settings.port);
    listenHTTP(settings, router);
    runApplication();
}

private ushort readPort() {
    auto raw = getenv("PORT");
    if (raw is null) {
        return 8080;
    }

    ushort parsed;
    auto err = collectException(parsed = fromStringz(raw).to!ushort);
    return err is null ? parsed : cast(ushort) 8080;
}

private string readBindAddress() {
    auto raw = getenv("BIND_ADDRESS");
    return raw is null ? "0.0.0.0".idup : fromStringz(raw).idup;
}
