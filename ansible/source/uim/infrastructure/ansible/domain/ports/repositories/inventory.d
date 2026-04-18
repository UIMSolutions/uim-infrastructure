module uim.infrastructure.ansible.domain.ports.repositories.inventory;

import uim.infrastructure.ansible.domain.entities.inventory : Inventory;

interface IInventoryRepository {
    void save(in Inventory inventory);
    void remove(string id);
    Inventory[] list();
    Inventory* findById(string id);
}
