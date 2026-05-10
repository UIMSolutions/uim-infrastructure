module uim.infrastructure.barbican.application.usecases.create_container;

import std.digest : toHexString;
import std.digest.sha : sha256Of;
import std.datetime : Clock;
import uim.infrastructure.barbican.application.dto.commands : CreateContainerCommand;
import uim.infrastructure.barbican.domain.entities.secret_container : SecretContainer, SecretRef, parseContainerType;
import uim.infrastructure.barbican.domain.ports.repositories.secret_container : ISecretContainerRepository;

class CreateContainerUseCase {
    private ISecretContainerRepository repository;

    this(ISecretContainerRepository repository) {
        this.repository = repository;
    }

    SecretContainer execute(in CreateContainerCommand cmd) {
        if (cmd.name.length == 0)
            throw new Exception("name must not be empty");
        if (cmd.containerType.length == 0)
            throw new Exception("containerType must not be empty");

        auto id = generateId(cmd.name ~ cmd.containerType);
        auto now = Clock.currTime.toISOExtString();

        SecretRef[] refs;
        foreach (ref r; cmd.secretRefs) {
            SecretRef sr;
            sr.name = r.name;
            sr.secretId = r.secretId;
            refs ~= sr;
        }

        auto container = SecretContainer(
            id,
            cmd.name,
            parseContainerType(cmd.containerType),
            refs,
            now,
            now,
            cmd.projectId
        );

        repository.save(container);
        return container;
    }

    private string generateId(string seed) {
        auto ts = Clock.currTime.toISOExtString();
        auto hash = sha256Of(seed ~ ts);
        return toHexString(hash[0 .. 8]).idup;
    }
}
