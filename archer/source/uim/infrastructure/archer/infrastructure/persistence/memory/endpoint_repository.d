module uim.infrastructure.archer.infrastructure.persistence.memory.endpoint_repository;

import core.sync.mutex : Mutex;
import uim.infrastructure.archer.domain.entities.endpoint : ArcherEndpoint;
import uim.infrastructure.archer.domain.ports.repositories.endpoint : IEndpointRepository;

class InMemoryEndpointRepository : IEndpointRepository {
    private ArcherEndpoint[] endpoints;
    private Mutex mutex;

    this() {
        mutex = new Mutex;
    }

    override void save(in ArcherEndpoint endpoint) {
        synchronized (mutex) {
            foreach (i, ref existing; endpoints) {
                if (existing.id == endpoint.id) {
                    endpoints[i] = copyEndpoint(endpoint);
                    return;
                }
            }
            endpoints ~= copyEndpoint(endpoint);
        }
    }

    override ArcherEndpoint[] list() {
        synchronized (mutex) {
            return endpoints.dup;
        }
    }

    override ArcherEndpoint[] listByService(string serviceId) {
        synchronized (mutex) {
            ArcherEndpoint[] result;
            foreach (endpoint; endpoints) {
                if (endpoint.serviceId == serviceId) {
                    result ~= endpoint;
                }
            }
            return result;
        }
    }

    override ArcherEndpoint* findById(string id) {
        synchronized (mutex) {
            foreach (ref endpoint; endpoints) {
                if (endpoint.id == id) {
                    return &endpoint;
                }
            }
            return null;
        }
    }

    override void remove(string id) {
        synchronized (mutex) {
            ArcherEndpoint[] filtered;
            foreach (endpoint; endpoints) {
                if (endpoint.id != id) {
                    filtered ~= endpoint;
                }
            }
            endpoints = filtered;
        }
    }

    override void removeByService(string serviceId) {
        synchronized (mutex) {
            ArcherEndpoint[] filtered;
            foreach (endpoint; endpoints) {
                if (endpoint.serviceId != serviceId) {
                    filtered ~= endpoint;
                }
            }
            endpoints = filtered;
        }
    }

    private ArcherEndpoint copyEndpoint(in ArcherEndpoint src) {
        ArcherEndpoint dst;
        dst.id = src.id;
        dst.serviceId = src.serviceId;
        dst.name = src.name;
        dst.description = src.description;
        dst.target = src.target;
        dst.ipAddress = src.ipAddress;
        dst.tags = src.tags.dup;
        dst.status = src.status;
        dst.connectionMirroring = src.connectionMirroring;
        dst.createdAt = src.createdAt;
        dst.updatedAt = src.updatedAt;
        dst.projectId = src.projectId;
        return dst;
    }
}
