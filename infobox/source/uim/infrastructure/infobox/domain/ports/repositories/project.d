/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.infrastructure.infobox.domain.ports.repositories.project;

import uim.infrastructure.infobox.domain.entities.project : Project;

interface IProjectRepository {
    void save(in Project project);
    void update(in Project project);
    Project[] list();
    Project* findById(string id);
    void deleteById(string id);
}
