/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
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
