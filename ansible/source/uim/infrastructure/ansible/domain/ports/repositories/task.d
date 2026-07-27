/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.infrastructure.ansible.domain.ports.repositories.task;

import uim.infrastructure.ansible.domain.entities.task : Task;

interface ITaskRepository {
    void save(in Task task);
    void remove(string id);
    Task[] list();
    Task* findById(string id);
}
