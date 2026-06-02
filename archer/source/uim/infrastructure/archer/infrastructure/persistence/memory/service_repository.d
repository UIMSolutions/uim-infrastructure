module uim.infrastructure.archer.infrastructure.persistence.memory.service_repository;

import core.sync.mutex : Mutex;
import uim.infrastructure.archer.domain.entities.service : ArcherService;
import uim.infrastructure.archer.domain.ports.repositories.service : IServiceRepository;

class InMemoryServiceRepository : IServiceRepository {
    private ArcherService[] services;
    private Mutex mutex;

    this() {
        mutex = new Mutex;
    }

    override void save(in ArcherService service) {
        synchronized (mutex) {
            foreach (i, ref existing; services) {
                if (existing.id == service.id) {
                    services[i] = copyService(service);
                    return;
                }
            }
            services ~= copyService(service);
        }
    }

    override ArcherService[] list() {
        synchronized (mutex) {
            return services.dup;
        }
    }

    override ArcherService* findById(string id) {
        synchronized (mutex) {
            foreach (ref service; services) {
                if (service.id == id) {
                    return &service;
                }
            }
            return null;
        }
    }

    override void remove(string id) {
        synchronized (mutex) {
            ArcherService[] filtered;
            foreach (service; services) {
                if (service.id != id) {
                    filtered ~= service;
                }
            }
            services = filtered;
        }
    }

    private ArcherService copyService(in ArcherService src) {
        ArcherService dst;
        dst.id = src.id;
        dst.enabled = src.enabled;
        dst.name = src.name;
        dst.description = src.description;
        dst.ports = src.ports.dup;
        dst.networkId = src.networkId;
        dst.ipAddresses = src.ipAddresses.dup;
        dst.status = src.status;
        dst.requireApproval = src.requireApproval;
        dst.visibility = src.visibility;
        dst.availabilityZone = src.availabilityZone;
        dst.host = src.host;
        dst.proxyProtocol = src.proxyProtocol;
        dst.tags = src.tags.dup;
        dst.provider = src.provider;
        dst.protocol = src.protocol;
        dst.createdAt = src.createdAt;
        dst.updatedAt = src.updatedAt;
        dst.projectId = src.projectId;
        dst.healthStatus = src.healthStatus;
        return dst;
    }
}
