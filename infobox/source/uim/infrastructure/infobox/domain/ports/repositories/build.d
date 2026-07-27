/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.infrastructure.infobox.domain.ports.repositories.build;

import uim.infrastructure.infobox.domain.entities.build : Build;

interface IBuildRepository {
    void save(in Build build);
    void update(in Build build);
    Build[] listByProject(string projectId);
    Build* findById(string id);
    uint nextBuildNumber(string projectId);
}
