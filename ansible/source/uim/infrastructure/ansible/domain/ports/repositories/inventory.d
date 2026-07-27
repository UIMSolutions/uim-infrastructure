/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.infrastructure.ansible.domain.ports.repositories.inventory;

import uim.infrastructure.ansible.domain.entities.inventory : Inventory;

interface IInventoryRepository {
    void save(in Inventory inventory);
    void remove(string id);
    Inventory[] list();
    Inventory* findById(string id);
}
