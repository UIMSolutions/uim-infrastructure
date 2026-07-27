/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.infrastructure.barbican.domain.ports.repositories.secret;

import uim.infrastructure.barbican.domain.entities.secret : Secret, SecretType, SecretStatus;

interface ISecretRepository {
    void save(in Secret secret);
    void remove(string id);
    Secret[] list(string projectId = "");
    Secret* findById(string id);
    Secret[] findByStatus(SecretStatus status);
    Secret[] findByType(SecretType secretType);
    bool setPayload(string id, string payload, string contentType);
}
