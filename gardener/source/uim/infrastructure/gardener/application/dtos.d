/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.infrastructure.gardener.application.dtos;

struct RootView {
    string service;
    string description;
}

struct HealthView {
    string status;
}

struct ErrorView {
    string error;
}

struct DiscoveryView {
    string service;
    string description;
    string[] resources;
    string[] capabilities;
}

struct ProjectCreateCommand {
    string name;
    string owner;
    string region;
    string description;
}

struct ProjectView {
    string id;
    string name;
    string owner;
    string region;
    string description;
    string state;
    string createdAt;
    string updatedAt;
}

struct SecretCreateCommand {
    string name;
    string namespace_;
    string type;
    string purpose;
}

struct SecretView {
    string id;
    string name;
    string namespace_;
    string type;
    string purpose;
    string state;
    string createdAt;
    string updatedAt;
}

struct CertificateCreateCommand {
    string name;
    string secretName;
    string commonName;
    string purpose;
}

struct CertificateView {
    string id;
    string name;
    string secretName;
    string commonName;
    string purpose;
    string state;
    string createdAt;
    string updatedAt;
}

struct GardenCreateCommand {
    string name;
    string purpose;
    string owner;
    string region;
}

struct GardenView {
    string id;
    string name;
    string purpose;
    string owner;
    string region;
    string state;
    string createdAt;
    string updatedAt;
}

struct SeedCreateCommand {
    string name;
    string provider;
    string region;
    string kubeconfigRef;
}

struct SeedView {
    string id;
    string name;
    string provider;
    string region;
    string kubeconfigRef;
    string state;
    string createdAt;
    string updatedAt;
}

struct ShootCreateCommand {
    string name;
    string projectName;
    string gardenName;
    string seedName;
    string region;
    string kubernetesVersion;
    string purpose;
}

struct ShootReconcileCommand {
    string reason;
}

struct ShootStatusCommand {
    string state;
}

struct ShootView {
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
