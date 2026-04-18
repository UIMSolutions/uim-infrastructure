module uim.infrastructure.ansible.domain.ports.repositories.task;

import uim.infrastructure.ansible.domain.entities.task : Task;

interface ITaskRepository {
    void save(in Task task);
    void remove(string id);
    Task[] list();
    Task* findById(string id);
}
