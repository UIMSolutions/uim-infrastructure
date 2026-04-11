module dns_service.domain.ports.dns_repository;

import dns_service.domain.entities.dns_record : DNSRecord, RecordType;

interface IDNSRepository {
    void save(in DNSRecord record);
    DNSRecord[] list();
    DNSRecord[] find(string zone, string name, RecordType recordType);
}
