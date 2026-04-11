module dns_service.application.use_cases.register_record;

import dns_service.application.dto.record_command : RegisterRecordCommand;
import dns_service.domain.entities.dns_record : DNSRecord, parseRecordType;
import dns_service.domain.ports.dns_repository : IDNSRepository;

class RegisterRecordUseCase {
    private IDNSRepository repository;

    this(IDNSRepository repository) {
        this.repository = repository;
    }

    DNSRecord execute(in RegisterRecordCommand command) {
        enforceCommand(command);

        auto record = DNSRecord(
            command.zone,
            command.name,
            parseRecordType(command.recordType),
            command.value,
            command.ttl
        );

        repository.save(record);
        return record;
    }

    private void enforceCommand(in RegisterRecordCommand command) {
        if (command.zone.length == 0) {
            throw new Exception("zone must not be empty");
        }
        if (command.value.length == 0) {
            throw new Exception("value must not be empty");
        }
        if (command.ttl == 0) {
            throw new Exception("ttl must be greater than zero");
        }
    }
}
