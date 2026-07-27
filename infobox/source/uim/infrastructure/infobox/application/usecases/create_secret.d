/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.infrastructure.infobox.application.usecases.create_secret;

import uim.infrastructure.infobox.application.dto.commands : CreateSecretCommand;
import uim.infrastructure.infobox.domain.entities.secret : Secret;
import uim.infrastructure.infobox.domain.ports.repositories.secret : ISecretRepository;
import uim.infrastructure.infobox.domain.ports.repositories.project : IProjectRepository;
import std.conv : to;
import std.datetime : Clock;

class CreateSecretUseCase {
    private ISecretRepository secretRepo;
    private IProjectRepository projectRepo;

    this(ISecretRepository secretRepo, IProjectRepository projectRepo) {
        this.secretRepo = secretRepo;
        this.projectRepo = projectRepo;
    }

    Secret execute(in CreateSecretCommand command) {
        if (command.projectId.length == 0) {
            throw new Exception("project id must not be empty");
        }
        if (command.name.length == 0) {
            throw new Exception("secret name must not be empty");
        }
        if (command.value.length == 0) {
            throw new Exception("secret value must not be empty");
        }

        auto projectPtr = projectRepo.findById(command.projectId);
        if (projectPtr is null) {
            throw new Exception("project not found: " ~ command.projectId);
        }

        auto existing = secretRepo.findByName(command.projectId, command.name);
        if (existing !is null) {
            throw new Exception("secret already exists: " ~ command.name);
        }

        auto secret = Secret(
            generateId(),
            command.projectId,
            command.name,
            "***encrypted:" ~ command.value ~ "***",
            Clock.currTime.toUTC.toISOExtString,
        );

        secretRepo.save(secret);
        return secret;
    }

    private static uint idCounter = 0;

    private string generateId() {
        idCounter++;
        return "sec-" ~ idCounter.to!string;
    }
}
