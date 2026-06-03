module uim.infrastructure.manila.infrastructure.persistence.memory.share_type_repository;

import uim.infrastructure.manila.domain.entities.share_type : ShareProtocol, ShareType;
import uim.infrastructure.manila.domain.ports.repositories.share_type : IShareTypeRepository;

class InMemoryShareTypeRepository : IShareTypeRepository {
    private ShareType[] shareTypes;

    this() {
        shareTypes = [
            ShareType("gold", "gold", "High throughput NFS-backed tier", ShareProtocol.nfs, true, true),
            ShareType("silver", "silver", "General purpose CIFS-backed tier", ShareProtocol.cifs, false, true),
            ShareType("cephfs-premium", "cephfs-premium", "CephFS tier for container workloads", ShareProtocol.cephfs, true, true)
        ];
    }

    override ShareType[] list() {
        return shareTypes.dup;
    }

    override ShareType* findById(string id) {
        foreach (ref shareType; shareTypes) {
            if (shareType.id == id) {
                return new ShareType(
                    shareType.id,
                    shareType.name,
                    shareType.description,
                    shareType.protocol,
                    shareType.driverHandlesShareServers,
                    shareType.snapshotSupport
                );
            }
        }
        return null;
    }
}

unittest {
    auto repository = new InMemoryShareTypeRepository();
    assert(repository.list().length == 3);
    assert(repository.findById("gold") !is null);
}