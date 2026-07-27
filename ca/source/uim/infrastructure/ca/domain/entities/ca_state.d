/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.infrastructure.ca.domain.entities.ca_state;

struct CaState {
    string id;
    string name;
    string commonName;
    string certPem;
    string keyPem;
    string serialNumber;
    string createdAt;
    uint validDays;
}
