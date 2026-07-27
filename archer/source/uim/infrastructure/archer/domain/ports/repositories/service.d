/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.infrastructure.archer.domain.ports.repositories.service;

import uim.infrastructure.archer.domain.entities.service : ArcherService;

interface IServiceRepository {
    void save(in ArcherService service);
    ArcherService[] list();
    ArcherService* findById(string id);
    void remove(string id);
}
