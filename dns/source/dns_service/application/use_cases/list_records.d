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
