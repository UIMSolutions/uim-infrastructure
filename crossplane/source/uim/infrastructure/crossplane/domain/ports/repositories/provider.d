module uim.infrastructure.crossplane.domain.ports.repositories.provider;

import uim.infrastructure.crossplane.domain.entities.provider : Provider;

interface IProviderRepository {
    void save(in Provider provider);
    void remove(string id);
    Provider[] list();
    Provider* findById(string id);
}
