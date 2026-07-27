/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module lb_service.domain.ports.repositories.backend;

import lb_service.domain.entities.backend : Backend;

interface IBackendRepository {
    void save(in Backend backend);
    void remove(string id);
    Backend[] list();
    Backend* findById(string id);
}
