module uim.infrastructure.gardener.domain.ports;

import uim.infrastructure.gardener.domain.entities :
    Garden,
    Project,
    Secret,
    Certificate,
    Seed,
    Shoot;

interface IGardenRepository {
    Garden create(Garden garden);
    Garden[] list();
    bool getByName(string name, out Garden garden);
    bool deleteByName(string name);
}

interface IProjectRepository {
    Project create(Project project);
    Project[] list();
    bool getByName(string name, out Project project);
    bool deleteByName(string name);
}

interface ISecretRepository {
    Secret create(Secret secret);
    Secret[] list();
    bool getByName(string name, out Secret secret);
    bool deleteByName(string name);
}

interface ICertificateRepository {
    Certificate create(Certificate certificate);
    Certificate[] list();
    bool getByName(string name, out Certificate certificate);
    bool deleteByName(string name);
}

interface ISeedRepository {
    Seed create(Seed seed);
    Seed[] list();
    bool getByName(string name, out Seed seed);
    bool deleteByName(string name);
}

interface IShootRepository {
    Shoot create(Shoot shoot);
    Shoot[] list();
    bool getByName(string name, out Shoot shoot);
    bool updateState(string name, string state, string updatedAt, out Shoot shoot);
    bool deleteByName(string name);
}
