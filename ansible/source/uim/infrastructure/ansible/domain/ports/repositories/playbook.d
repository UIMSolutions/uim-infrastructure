module uim.infrastructure.ansible.domain.ports.repositories.playbook;

import uim.infrastructure.ansible.domain.entities.playbook : Playbook;

interface IPlaybookRepository {
    void save(in Playbook playbook);
    void remove(string id);
    Playbook[] list();
    Playbook* findById(string id);
}
