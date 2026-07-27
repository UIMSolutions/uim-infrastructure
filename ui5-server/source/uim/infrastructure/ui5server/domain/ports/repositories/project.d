/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.infrastructure.ui5server.domain.ports.repositories.project;

import uim.infrastructure.ui5server.domain.entities.project : Project;

interface IProjectRepository {
    bool save(Project project);
    Project* findById(string id);
    Project* findByName(string name);
    Project[] findAll();
    bool remove(string id);
}
