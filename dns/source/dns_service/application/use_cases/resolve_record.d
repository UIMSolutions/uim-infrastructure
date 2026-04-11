module dns_service.application.use_cases.resolve_record;

import dns_service.application.dto.record_command : ResolveRecordQuery;
import dns_service.domain.entities.dns_record : DNSRecord, parseRecordType;
import dns_service.domain.ports.dns_repository : IDNSRepository;

class ResolveRecordUseCase {
    private IDNSRepository repository;

    this(IDNSRepository repository) {
        this.repository = repository;
    }

    DNSRecord[] execute(in ResolveRecordQuery query) {
        if (query.zone.length == 0) {
            throw new Exception("zone must not be empty");
        }

        return repository.find(query.zone, query.name, parseRecordType(query.recordType));
    }
}
