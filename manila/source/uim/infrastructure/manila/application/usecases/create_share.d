module uim.infrastructure.manila.application.usecases.create_share;

import std.datetime : Clock;
import std.uuid : randomUUID;
import uim.infrastructure.manila.application.dto.manila_command : CreateShareCommand;
import uim.infrastructure.manila.domain.entities.share : Share, ShareStatus;
import uim.infrastructure.manila.domain.entities.share_type : ShareType, ShareProtocol, shareProtocolToString;
import uim.infrastructure.manila.domain.ports.repositories.share : IShareRepository;
import uim.infrastructure.manila.domain.ports.repositories.share_type : IShareTypeRepository;

class CreateShareUseCase {
    private IShareRepository shareRepository;
    private IShareTypeRepository shareTypeRepository;

    this(IShareRepository shareRepository, IShareTypeRepository shareTypeRepository) {
        this.shareRepository = shareRepository;
        this.shareTypeRepository = shareTypeRepository;
    }

    Share execute(in CreateShareCommand command) {
        enforceCommand(command);

        auto shareType = shareTypeRepository.findById(command.shareTypeId);
        if (shareType is null) {
            throw new Exception("share_type_id not found");
        }
        if (shareType.protocol != command.protocol) {
            throw new Exception("protocol does not match share type");
        }

        auto id = randomUUID().toString();
        auto share = Share(
            id,
            command.projectId,
            command.name,
            command.description,
            command.sizeGiB,
            command.protocol,
            command.shareTypeId,
            command.availabilityZone.length == 0 ? "zone-a" : command.availabilityZone,
            ShareStatus.available,
            buildExportLocations(id, command.protocol),
            Clock.currTime()
        );

        shareRepository.save(share);
        return share;
    }

    private void enforceCommand(in CreateShareCommand command) {
        if (command.projectId.length == 0) {
            throw new Exception("project_id must not be empty");
        }
        if (command.name.length == 0) {
            throw new Exception("name must not be empty");
        }
        if (command.sizeGiB == 0) {
            throw new Exception("size_gib must be greater than zero");
        }
        if (command.shareTypeId.length == 0) {
            throw new Exception("share_type_id must not be empty");
        }
    }

    private string[] buildExportLocations(string shareId, ShareProtocol protocol) {
        final switch (protocol) {
            case ShareProtocol.nfs:
                return ["nfs://manila-gateway.local/shares/" ~ shareId];
            case ShareProtocol.cifs:
                return ["//manila-gateway.local/" ~ shareId];
            case ShareProtocol.cephfs:
                return ["cephfs://manila-gateway.local/fs/" ~ shareId];
        }
    }
}

unittest {
    import uim.infrastructure.manila.application.dto.manila_command : CreateShareCommand;
    import uim.infrastructure.manila.infrastructure.persistence.memory.share_repository : InMemoryShareRepository;
    import uim.infrastructure.manila.infrastructure.persistence.memory.share_type_repository : InMemoryShareTypeRepository;

    auto useCase = new CreateShareUseCase(new InMemoryShareRepository(), new InMemoryShareTypeRepository());
    auto share = useCase.execute(CreateShareCommand("project-a", "eng", "", 20, ShareProtocol.nfs, "gold", "zone-a"));
    assert(share.protocol == ShareProtocol.nfs);
    assert(share.exportLocations.length == 1);
}