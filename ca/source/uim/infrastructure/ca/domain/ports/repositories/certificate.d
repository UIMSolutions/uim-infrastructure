/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.infrastructure.ca.domain.ports.repositories.certificate;

import uim.infrastructure.ca.domain.entities.certificate : Certificate;

interface ICertificateRepository {
    void save(in Certificate certificate);
    Certificate[] list(string namespaceName = "");
    Certificate* findById(string id);
    bool revoke(string id, string reason, string revokedAt);
}
