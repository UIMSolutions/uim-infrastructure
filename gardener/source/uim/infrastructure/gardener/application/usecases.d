/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.infrastructure.gardener.application.usecases;

import std.exception : enforce;
import std.uuid : randomUUID;

import uim.infrastructure.gardener.application.dtos :
    GardenCreateCommand,
    ProjectCreateCommand,
    SecretCreateCommand,
    CertificateCreateCommand,
    SeedCreateCommand,
    ShootCreateCommand,
    ShootReconcileCommand,
    ShootStatusCommand;
import uim.infrastructure.gardener.domain.entities :
    Garden,
    Project,
    Secret,
    Certificate,
    Seed,
    Shoot;
import uim.infrastructure.gardener.domain.ports :
    IGardenRepository,
    IProjectRepository,
    ISecretRepository,
    ICertificateRepository,
    ISeedRepository,
    IShootRepository;

private string timestamp() {
    import std.datetime : Clock;

    return Clock.currTime().toString();
}

private string newId() {
    return randomUUID().toString();
}

final class CreateGardenUseCase {
    private IGardenRepository repository;

    this(IGardenRepository repository) {
        this.repository = repository;
    }

    Garden execute(GardenCreateCommand command) {
        enforce(command.name.length != 0, "name is required");
        enforce(command.owner.length != 0, "owner is required");
        enforce(command.region.length != 0, "region is required");

        auto created = Garden(
            newId(),
            command.name,
            command.purpose,
            command.owner,
            command.region,
            "ready",
            timestamp(),
            timestamp(),
        );

        return repository.create(created);
    }
}

final class ListGardensUseCase {
    private IGardenRepository repository;

    this(IGardenRepository repository) {
        this.repository = repository;
    }

    Garden[] execute() {
        return repository.list();
    }
}

final class CreateProjectUseCase {
    private IProjectRepository repository;

    this(IProjectRepository repository) {
        this.repository = repository;
    }

    Project execute(ProjectCreateCommand command) {
        enforce(command.name.length != 0, "name is required");
        enforce(command.owner.length != 0, "owner is required");
        enforce(command.region.length != 0, "region is required");

        auto created = Project(
            newId(),
            command.name,
            command.owner,
            command.region,
            command.description,
            "active",
            timestamp(),
            timestamp(),
        );

        return repository.create(created);
    }
}

final class ListProjectsUseCase {
    private IProjectRepository repository;

    this(IProjectRepository repository) {
        this.repository = repository;
    }

    Project[] execute() {
        return repository.list();
    }
}

final class GetProjectUseCase {
    private IProjectRepository repository;

    this(IProjectRepository repository) {
        this.repository = repository;
    }

    Project execute(string name) {
        Project project;
        enforce(repository.getByName(name, project), "project not found");
        return project;
    }
}

final class DeleteProjectUseCase {
    private IProjectRepository repository;

    this(IProjectRepository repository) {
        this.repository = repository;
    }

    void execute(string name) {
        enforce(repository.deleteByName(name), "project not found");
    }
}

final class CreateSecretUseCase {
    private ISecretRepository repository;

    this(ISecretRepository repository) {
        this.repository = repository;
    }

    Secret execute(SecretCreateCommand command) {
        enforce(command.name.length != 0, "name is required");
        enforce(command.namespace_.length != 0, "namespace is required");
        enforce(command.type.length != 0, "type is required");

        auto created = Secret(
            newId(),
            command.name,
            command.namespace_,
            command.type,
            command.purpose,
            "available",
            timestamp(),
            timestamp(),
        );

        return repository.create(created);
    }
}

final class ListSecretsUseCase {
    private ISecretRepository repository;

    this(ISecretRepository repository) {
        this.repository = repository;
    }

    Secret[] execute() {
        return repository.list();
    }
}

final class GetSecretUseCase {
    private ISecretRepository repository;

    this(ISecretRepository repository) {
        this.repository = repository;
    }

    Secret execute(string name) {
        Secret secret;
        enforce(repository.getByName(name, secret), "secret not found");
        return secret;
    }
}

final class DeleteSecretUseCase {
    private ISecretRepository repository;

    this(ISecretRepository repository) {
        this.repository = repository;
    }

    void execute(string name) {
        enforce(repository.deleteByName(name), "secret not found");
    }
}

final class CreateCertificateUseCase {
    private ICertificateRepository repository;

    this(ICertificateRepository repository) {
        this.repository = repository;
    }

    Certificate execute(CertificateCreateCommand command) {
        enforce(command.name.length != 0, "name is required");
        enforce(command.secretName.length != 0, "secretName is required");
        enforce(command.commonName.length != 0, "commonName is required");

        auto created = Certificate(
            newId(),
            command.name,
            command.secretName,
            command.commonName,
            command.purpose,
            "issued",
            timestamp(),
            timestamp(),
        );

        return repository.create(created);
    }
}

final class ListCertificatesUseCase {
    private ICertificateRepository repository;

    this(ICertificateRepository repository) {
        this.repository = repository;
    }

    Certificate[] execute() {
        return repository.list();
    }
}

final class GetCertificateUseCase {
    private ICertificateRepository repository;

    this(ICertificateRepository repository) {
        this.repository = repository;
    }

    Certificate execute(string name) {
        Certificate certificate;
        enforce(repository.getByName(name, certificate), "certificate not found");
        return certificate;
    }
}

final class DeleteCertificateUseCase {
    private ICertificateRepository repository;

    this(ICertificateRepository repository) {
        this.repository = repository;
    }

    void execute(string name) {
        enforce(repository.deleteByName(name), "certificate not found");
    }
}

final class GetGardenUseCase {
    private IGardenRepository repository;

    this(IGardenRepository repository) {
        this.repository = repository;
    }

    Garden execute(string name) {
        Garden garden;
        enforce(repository.getByName(name, garden), "garden not found");
        return garden;
    }
}

final class DeleteGardenUseCase {
    private IGardenRepository repository;

    this(IGardenRepository repository) {
        this.repository = repository;
    }

    void execute(string name) {
        enforce(repository.deleteByName(name), "garden not found");
    }
}

final class CreateSeedUseCase {
    private ISeedRepository repository;

    this(ISeedRepository repository) {
        this.repository = repository;
    }

    Seed execute(SeedCreateCommand command) {
        enforce(command.name.length != 0, "name is required");
        enforce(command.provider.length != 0, "provider is required");
        enforce(command.region.length != 0, "region is required");

        auto created = Seed(
            newId(),
            command.name,
            command.provider,
            command.region,
            command.kubeconfigRef,
            "registered",
            timestamp(),
            timestamp(),
        );

        return repository.create(created);
    }
}

final class ListSeedsUseCase {
    private ISeedRepository repository;

    this(ISeedRepository repository) {
        this.repository = repository;
    }

    Seed[] execute() {
        return repository.list();
    }
}

final class GetSeedUseCase {
    private ISeedRepository repository;

    this(ISeedRepository repository) {
        this.repository = repository;
    }

    Seed execute(string name) {
        Seed seed;
        enforce(repository.getByName(name, seed), "seed not found");
        return seed;
    }
}

final class DeleteSeedUseCase {
    private ISeedRepository repository;

    this(ISeedRepository repository) {
        this.repository = repository;
    }

    void execute(string name) {
        enforce(repository.deleteByName(name), "seed not found");
    }
}

final class CreateShootUseCase {
    private IShootRepository repository;

    this(IShootRepository repository) {
        this.repository = repository;
    }

    Shoot execute(ShootCreateCommand command) {
        enforce(command.name.length != 0, "name is required");
        enforce(command.projectName.length != 0, "projectName is required");
        enforce(command.gardenName.length != 0, "gardenName is required");
        enforce(command.seedName.length != 0, "seedName is required");
        enforce(command.region.length != 0, "region is required");
        enforce(command.kubernetesVersion.length != 0, "kubernetesVersion is required");

        auto created = Shoot(
            newId(),
            command.name,
            command.projectName,
            command.gardenName,
            command.seedName,
            command.region,
            command.kubernetesVersion,
            command.purpose,
            "pending",
            timestamp(),
            timestamp(),
        );

        return repository.create(created);
    }
}

final class ReconcileShootUseCase {
    private IShootRepository repository;

    this(IShootRepository repository) {
        this.repository = repository;
    }

    Shoot execute(string name, ShootReconcileCommand command) {
        auto reason = command.reason.length == 0 ? "manual-reconcile" : command.reason;
        Shoot updated;
        enforce(repository.updateState(name, "reconciling: " ~ reason, timestamp(), updated), "shoot not found");
        return updated;
    }
}

final class ListShootsUseCase {
    private IShootRepository repository;

    this(IShootRepository repository) {
        this.repository = repository;
    }

    Shoot[] execute() {
        return repository.list();
    }
}

final class GetShootUseCase {
    private IShootRepository repository;

    this(IShootRepository repository) {
        this.repository = repository;
    }

    Shoot execute(string name) {
        Shoot shoot;
        enforce(repository.getByName(name, shoot), "shoot not found");
        return shoot;
    }
}

final class UpdateShootStatusUseCase {
    private IShootRepository repository;

    this(IShootRepository repository) {
        this.repository = repository;
    }

    Shoot execute(string name, ShootStatusCommand command) {
        enforce(command.state.length != 0, "state is required");

        Shoot updated;
        enforce(repository.updateState(name, command.state, timestamp(), updated), "shoot not found");
        return updated;
    }
}

final class DeleteShootUseCase {
    private IShootRepository repository;

    this(IShootRepository repository) {
        this.repository = repository;
    }

    void execute(string name) {
        enforce(repository.deleteByName(name), "shoot not found");
    }
}
