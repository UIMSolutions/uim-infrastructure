module uim.infrastructure.barbican.domain.ports.repositories.secret;

import uim.infrastructure.barbican.domain.entities.secret : Secret, SecretType, SecretStatus;

interface ISecretRepository {
    void save(in Secret secret);
    void remove(string id);
    Secret[] list(string projectId = "");
    Secret* findById(string id);
    Secret[] findByStatus(SecretStatus status);
    Secret[] findByType(SecretType secretType);
    bool setPayload(string id, string payload, string contentType);
}
