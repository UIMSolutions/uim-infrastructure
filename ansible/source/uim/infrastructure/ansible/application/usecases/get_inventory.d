module uim.infrastructure.ansible.application.usecases.get_inventory;

import uim.infrastructure.ansible.domain.entities.inventory : Inventory;
import uim.infrastructure.ansible.domain.ports.repositories.inventory : IInventoryRepository;

class GetInventoryUseCase {
    private IInventoryRepository repository;

    this(IInventoryRepository repository) {
        this.repository = repository;
    }

    Inventory* execute(string id) {
        if (id.length == 0)
            throw new Exception("inventory id must not be empty");
        return repository.findById(id);
    }
}
