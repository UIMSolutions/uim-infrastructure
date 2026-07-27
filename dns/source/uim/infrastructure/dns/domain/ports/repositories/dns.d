/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module dns_service.domain.ports.repositories.dns;

import dns_service.domain.entities.dns_record : DNSRecord, RecordType;

interface IDNSRepository {
    void save(in DNSRecord record);
    DNSRecord[] list();
    DNSRecord[] find(string zone, string name, RecordType recordType);
}
