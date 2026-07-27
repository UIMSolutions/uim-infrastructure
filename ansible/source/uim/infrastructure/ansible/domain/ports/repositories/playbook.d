/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.infrastructure.ansible.domain.ports.repositories.playbook;

import uim.infrastructure.ansible.domain.entities.playbook : Playbook;

interface IPlaybookRepository {
    void save(in Playbook playbook);
    void remove(string id);
    Playbook[] list();
    Playbook* findById(string id);
}
