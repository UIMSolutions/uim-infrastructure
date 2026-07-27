/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.infrastructure.barbican.application.usecases.create_secret;

import std.digest : toHexString;
import std.digest.sha : sha256Of;
import std.datetime : Clock;
import uim.infrastructure.barbican.application.dto.commands : CreateSecretCommand;
import uim.infrastructure.barbican.domain.entities.secret : Secret, SecretStatus,
    parseSecretType, parseSecretAlgorithm;
import uim.infrastructure.barbican.domain.ports.repositories.secret : ISecretRepository;

class CreateSecretUseCase {
    private ISecretRepository repository;

    this(ISecretRepository repository) {
        this.repository = repository;
    }

    Secret execute(in CreateSecretCommand cmd) {
        enforce(cmd.secretType.length > 0, "secretType must not be empty");

        auto id = generateId(cmd.name ~ cmd.secretType);
        auto now = Clock.currTime.toISOExtString();

        auto secret = Secret(
            id,
            cmd.name,
            parseSecretType(cmd.secretType),
            parseSecretAlgorithm(cmd.algorithm),
            cmd.bitLength,
            cmd.mode,
            cmd.payload,
            cmd.payloadContentType,
            cmd.expiration,
            SecretStatus.active,
            now,
            now,
            cmd.projectId
        );

        repository.save(secret);
        return secret;
    }

    private void enforce(bool condition, string message) {
        if (!condition) throw new Exception(message);
    }

    private string generateId(string seed) {
        import std.conv : to;
        auto ts = Clock.currTime.toISOExtString();
        auto hash = sha256Of(seed ~ ts);
        return toHexString(hash[0 .. 8]).idup;
    }
}
