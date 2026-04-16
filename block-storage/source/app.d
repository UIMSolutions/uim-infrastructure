module app;

import bs_service.application.usecases.attach_volume : AttachVolumeUseCase;
import bs_service.application.usecases.create_volume : CreateVolumeUseCase;
import bs_service.application.usecases.delete_volume : DeleteVolumeUseCase;
import bs_service.application.usecases.detach_volume : DetachVolumeUseCase;
import bs_service.application.usecases.get_volume : GetVolumeUseCase;
import bs_service.application.usecases.list_volumes : ListVolumesUseCase;
import bs_service.infrastructure.http.controllers.block_storage : BlockStorageController;
import bs_service.infrastructure.persistence.memory.block_volume_repository : InMemoryBlockVolumeRepository;
import std.conv : to;
import std.exception : collectException;
import std.file : write;
import std.string : fromStringz;
import core.stdc.stdlib : getenv;
import core.stdc.unistd : getpid;
import vibe.vibe;

void main() {
    writePidFile();

    auto settings = new HTTPServerSettings;
    settings.port = readPort();
    settings.bindAddresses = [readBindAddress()];

    auto repository = new InMemoryBlockVolumeRepository();

    auto controller = new BlockStorageController(
        new CreateVolumeUseCase(repository),
        new DeleteVolumeUseCase(repository),
        new AttachVolumeUseCase(repository),
        new DetachVolumeUseCase(repository),
        new ListVolumesUseCase(repository),
        new GetVolumeUseCase(repository)
    );

    auto router = new URLRouter;
    controller.registerRoutes(router);

    logInfo("Block-storage service starting on %s:%d", settings.bindAddresses[0], settings.port);
    listenHTTP(settings, router);
    runApplication();
}

private void writePidFile() {
    auto raw = getenv("PID_FILE");
    string path = raw is null ? "/var/run/uim-block-storage-service.pid" : fromStringz(raw).idup;
    try {
        write(path, to!string(getpid()));
    } catch (Exception) {
        // PID file is best-effort; do not abort startup on failure.
    }
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
