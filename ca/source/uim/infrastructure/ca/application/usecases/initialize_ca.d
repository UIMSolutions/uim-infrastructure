module uim.infrastructure.ca.application.usecases.initialize_ca;

import std.datetime : Clock;
import std.digest : toHexString;
import std.digest.sha : sha256Of;
import uim.infrastructure.ca.application.dto.commands : InitializeCaCommand;
import uim.infrastructure.ca.domain.entities.ca_state : CaState;
import uim.infrastructure.ca.domain.ports.repositories.ca_state : ICaStateRepository;
import uim.infrastructure.ca.domain.ports.crypto.ca_engine : ICaCryptoEngine;

class InitializeCaUseCase {
    private ICaStateRepository repository;
    private ICaCryptoEngine engine;

    this(ICaStateRepository repository, ICaCryptoEngine engine) {
        this.repository = repository;
        this.engine = engine;
    }

    CaState execute(in InitializeCaCommand cmd) {
        enforce(cmd.commonName.length > 0, "commonName must not be empty");

        if (repository.isInitialized()) {
            throw new Exception("CA is already initialized");
        }

        auto effectiveDays = cmd.validDays > 0 ? cmd.validDays : 3650;
        auto material = engine.createRootCa(cmd.commonName, effectiveDays);
        auto now = Clock.currTime.toISOExtString();

        auto state = CaState(
            generateId(cmd.commonName),
            cmd.name.length > 0 ? cmd.name : "cluster-root-ca",
            cmd.commonName,
            material.certPem,
            material.keyPem,
            material.serialNumber,
            now,
            effectiveDays
        );

        repository.save(state);
        return state;
    }

    private void enforce(bool condition, string message) {
        if (!condition) throw new Exception(message);
    }

    private string generateId(string seed) {
        auto ts = Clock.currTime.toISOExtString();
        auto hash = sha256Of(seed ~ ts);
        return toHexString(hash[0 .. 8]).idup;
    }
}
