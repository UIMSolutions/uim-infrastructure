module uim.infrastructure.gardener.domain.entities;

struct Garden {
    string id;
    string name;
    string purpose;
    string owner;
    string region;
    string state;
    string createdAt;
    string updatedAt;
}

struct Project {
    string id;
    string name;
    string owner;
    string region;
    string description;
    string state;
    string createdAt;
    string updatedAt;
}

struct Secret {
    string id;
    string name;
    string namespace_;
    string type;
    string purpose;
    string state;
    string createdAt;
    string updatedAt;
}

struct Certificate {
    string id;
    string name;
    string secretName;
    string commonName;
    string purpose;
    string state;
    string createdAt;
    string updatedAt;
}

struct Seed {
    string id;
    string name;
    string provider;
    string region;
    string kubeconfigRef;
    string state;
    string createdAt;
    string updatedAt;
}

struct Shoot {
    string id;
    string name;
    string projectName;
    string gardenName;
    string seedName;
    string region;
    string kubernetesVersion;
    string purpose;
    string state;
    string createdAt;
    string updatedAt;
}
