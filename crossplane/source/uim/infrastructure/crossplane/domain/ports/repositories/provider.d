/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.infrastructure.crossplane.domain.ports.repositories.provider;

import uim.infrastructure.crossplane.domain.entities.provider : Provider;

interface IProviderRepository {
    void save(in Provider provider);
    void remove(string id);
    Provider[] list();
    Provider* findById(string id);
}
