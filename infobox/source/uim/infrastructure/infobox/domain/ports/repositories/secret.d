/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.infrastructure.infobox.domain.ports.repositories.secret;

import uim.infrastructure.infobox.domain.entities.secret : Secret;

interface ISecretRepository {
    void save(in Secret secret);
    Secret[] listByProject(string projectId);
    Secret* findById(string id);
    Secret* findByName(string projectId, string name);
    void deleteById(string id);
}
