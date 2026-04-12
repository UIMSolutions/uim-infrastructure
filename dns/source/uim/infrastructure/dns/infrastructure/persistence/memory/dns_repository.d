module dns_service.infrastructure.persistence.in_memory_dns_repository;

import core.sync.mutex : Mutex;
import dns_service.domain.entities.dns_record : DNSRecord, RecordType;
import dns_service.domain.ports.dns_repository : IDNSRepository;

class InMemoryDNSRepository : IDNSRepository {
    private DNSRecord[] records;
    private Mutex mutex;

    this() {
        mutex = new Mutex;
    }

    override void save(in DNSRecord record) {
        synchronized (mutex) {
            records ~= record;
        }
    }

    override DNSRecord[] list() {
        synchronized (mutex) {
            return records.dup;
        }
    }

    override DNSRecord[] find(string zone, string name, RecordType recordType) {
        synchronized (mutex) {
            DNSRecord[] result;
            foreach (record; records) {
                if (record.zone == zone && record.name == name && record.type == recordType) {
                    result ~= record;
                }
            }
            return result;
        }
    }
}

unittest {
    auto repository = new InMemoryDNSRepository();
    repository.save(DNSRecord("example.local", "api", RecordType.A, "10.0.0.5", 60));

    auto records = repository.find("example.local", "api", RecordType.A);
    assert(records.length == 1);
    assert(records[0].value == "10.0.0.5");
}
