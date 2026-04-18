module uim.infrastructure.ansible.application.usecases.list_inventories;

import uim.infrastructure.ansible.domain.entities.inventory : Inventory;
import uim.infrastructure.ansible.domain.ports.repositories.inventory : IInventoryRepository;

class ListInventoriesUseCase {
    private IInventoryRepository repository;

    this(IInventoryRepository repository) {
        this.repository = repository;
    }

    Inventory[] execute() {
        return repository.list();
    }
}
