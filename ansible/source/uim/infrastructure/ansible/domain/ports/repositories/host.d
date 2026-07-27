/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.infrastructure.ansible.domain.ports.repositories.host;

import uim.infrastructure.ansible.domain.entities.host : Host;

interface IHostRepository {
    void save(in Host host);
    void remove(string id);
    Host[] list();
    Host* findById(string id);
    Host[] findByGroup(string groupName);
}
