/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module dns_service.application.use_cases.list_records;

import dns_service.domain.entities.dns_record : DNSRecord;
import dns_service.domain.ports.dns_repository : IDNSRepository;

class ListRecordsUseCase {
    private IDNSRepository repository;

    this(IDNSRepository repository) {
        this.repository = repository;
    }

    DNSRecord[] execute() {
        return repository.list();
    }
}
