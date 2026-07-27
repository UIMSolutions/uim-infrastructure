/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.infrastructure.barbican.domain.ports.repositories.secret_container;

import uim.infrastructure.barbican.domain.entities.secret_container : SecretContainer;

interface ISecretContainerRepository {
    void save(in SecretContainer container);
    void remove(string id);
    SecretContainer[] list(string projectId = "");
    SecretContainer* findById(string id);
}
