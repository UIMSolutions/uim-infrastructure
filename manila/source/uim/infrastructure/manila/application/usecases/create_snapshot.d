module uim.infrastructure.manila.application.usecases.create_snapshot;

import std.datetime : Clock;
import std.uuid : randomUUID;
import uim.infrastructure.manila.application.dto.manila_command : CreateSnapshotCommand;
import uim.infrastructure.manila.domain.entities.share_snapshot : ShareSnapshot, SnapshotStatus;
import uim.infrastructure.manila.domain.ports.repositories.share : IShareRepository;
import uim.infrastructure.manila.domain.ports.repositories.snapshot : ISnapshotRepository;

class CreateSnapshotUseCase {
    private ISnapshotRepository snapshotRepository;
    private IShareRepository shareRepository;

    this(ISnapshotRepository snapshotRepository, IShareRepository shareRepository) {
        this.snapshotRepository = snapshotRepository;
        this.shareRepository = shareRepository;
    }

    ShareSnapshot execute(in CreateSnapshotCommand command) {
        enforceCommand(command);

        auto share = shareRepository.findById(command.shareId);
        if (share is null) {
            throw new Exception("share_id not found");
        }
        if (share.projectId != command.projectId) {
            throw new Exception("project_id does not own the share");
        }

        auto snapshot = ShareSnapshot(
            randomUUID().toString(),
            command.shareId,
            command.projectId,
            command.name,
            command.description,
            share.sizeGiB,
            SnapshotStatus.available,
            Clock.currTime()
        );

        snapshotRepository.save(snapshot);
        return snapshot;
    }

    private void enforceCommand(in CreateSnapshotCommand command) {
        if (command.projectId.length == 0) {
            throw new Exception("project_id must not be empty");
        }
        if (command.shareId.length == 0) {
            throw new Exception("share_id must not be empty");
        }
        if (command.name.length == 0) {
            throw new Exception("name must not be empty");
        }
    }
}