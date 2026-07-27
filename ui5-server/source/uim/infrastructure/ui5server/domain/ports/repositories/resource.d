/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.infrastructure.ui5server.domain.ports.repositories.resource;

import uim.infrastructure.ui5server.domain.entities.resource : Resource;

interface IResourceRepository {
    bool save(Resource resource);
    Resource* findByPath(string path);
    Resource[] findByDirectory(string directoryPath);
    Resource[] findAll();
    bool remove(string path);
    bool exists(string path);
}
