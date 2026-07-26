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
