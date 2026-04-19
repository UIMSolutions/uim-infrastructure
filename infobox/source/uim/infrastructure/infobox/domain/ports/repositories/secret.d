module uim.infrastructure.infobox.domain.ports.repositories.secret;

import uim.infrastructure.infobox.domain.entities.secret : Secret;

interface ISecretRepository {
    void save(in Secret secret);
    Secret[] listByProject(string projectId);
    Secret* findById(string id);
    Secret* findByName(string projectId, string name);
    void deleteById(string id);
}
