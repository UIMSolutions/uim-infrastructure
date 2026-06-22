module app;

module app;

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
import uim.infrastructure.cinder.infrastructure.http.controllers.cinder : CinderController;
import uim.infrastructure.cinder.infrastructure.persistence.memory.snapshot_repository : InMemorySnapshotRepository;
import uim.infrastructure.cinder.infrastructure.persistence.memory.volume_repository : InMemoryVolumeRepository;
import uim.infrastructure.cinder.infrastructure.persistence.memory.volume_type_repository : InMemoryVolumeTypeRepository;
import std.conv : to;
import std.exception : collectException;
import std.string : fromStringz, toStringz;
import core.stdc.stdlib : getenv;
import vibe.vibe;

void main() {
    auto settings = new HTTPServerSettings;
    settings.port = readPort();
    settings.bindAddresses = [readBindAddress()];

    auto volumeRepo = new InMemoryVolumeRepository();
    auto snapshotRepo = new InMemorySnapshotRepository();
    auto volumeTypeRepo = new InMemoryVolumeTypeRepository();

    auto controller = new CinderController(
        new ListVolumeTypesUseCase(volumeTypeRepo),
        new ListVolumesUseCase(volumeRepo),
        new GetVolumeUseCase(volumeRepo),
        new CreateVolumeUseCase(volumeRepo),
        new DeleteVolumeUseCase(volumeRepo),
        new AttachVolumeUseCase(volumeRepo),
        new DetachVolumeUseCase(volumeRepo),
        new ListSnapshotsUseCase(snapshotRepo),
        new GetSnapshotUseCase(snapshotRepo),
        new CreateSnapshotUseCase(snapshotRepo, volumeRepo),
        new DeleteSnapshotUseCase(snapshotRepo),
        readEnv("CINDER_MICROVERSION_DEFAULT", "3.70"),
        readEnv("CINDER_MICROVERSION_MIN", "3.0"),
        readEnv("CINDER_MICROVERSION_MAX", "3.70")
    );

    auto router = new URLRouter;
    controller.registerRoutes(router);

    logInfo("Cinder service starting on %s:%d", settings.bindAddresses[0], settings.port);
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

private string readEnv(string key, string fallback) {
    auto raw = getenv(key.toStringz());
    return raw is null ? fallback.idup : fromStringz(raw).idup;
}
