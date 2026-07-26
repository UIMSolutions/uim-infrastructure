module uim.infrastructure.ca.domain.ports.repositories.ca_state;

import uim.infrastructure.ca.domain.entities.ca_state : CaState;

interface ICaStateRepository {
    void save(in CaState state);
    CaState* get();
    bool isInitialized();
}
