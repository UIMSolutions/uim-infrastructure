/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.infrastructure.manila.domain.ports.repositories.share;

import uim.infrastructure.manila.domain.entities.share : Share;

interface IShareRepository {
    void save(Share share);
    Share[] list();
    Share[] listByProject(string projectId);
    Share* findById(string id);
    void remove(string id);
}