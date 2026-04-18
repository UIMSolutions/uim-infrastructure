module uim.infrastructure.ansible.domain.ports.repositories.execution;

import uim.infrastructure.ansible.domain.entities.execution : Execution;

interface IExecutionRepository {
    void save(in Execution execution);
    Execution[] list();
    Execution* findById(string id);
    Execution[] findByPlaybookId(string playbookId);
}
