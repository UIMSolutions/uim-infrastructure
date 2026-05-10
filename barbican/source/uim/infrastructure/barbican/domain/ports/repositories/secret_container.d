module uim.infrastructure.barbican.domain.ports.repositories.secret_container;

import uim.infrastructure.barbican.domain.entities.secret_container : SecretContainer;

interface ISecretContainerRepository {
    void save(in SecretContainer container);
    void remove(string id);
    SecretContainer[] list(string projectId = "");
    SecretContainer* findById(string id);
}
