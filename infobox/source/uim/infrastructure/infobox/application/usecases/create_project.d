module uim.infrastructure.infobox.application.usecases.create_project;

import uim.infrastructure.infobox.application.dto.commands : CreateProjectCommand;
import uim.infrastructure.infobox.domain.entities.project : Project, ProjectStatus;
import uim.infrastructure.infobox.domain.ports.repositories.project : IProjectRepository;
import std.conv : to;
import std.datetime : Clock;

class CreateProjectUseCase {
    private IProjectRepository repository;

    this(IProjectRepository repository) {
        this.repository = repository;
    }

    Project execute(in CreateProjectCommand command) {
        enforceCommand(command);

        auto project = Project(
            generateId(),
            command.name,
            command.description,
            command.repository,
            command.branch.length > 0 ? command.branch : "main",
            ProjectStatus.active,
            [],
            Clock.currTime.toUTC.toISOExtString,
            Clock.currTime.toUTC.toISOExtString,
        );

        repository.save(project);
        return project;
    }

    private void enforceCommand(in CreateProjectCommand command) {
        if (command.name.length == 0) {
            throw new Exception("project name must not be empty");
        }
        if (command.repository.length == 0) {
            throw new Exception("repository must not be empty");
        }
    }

    private static uint idCounter = 0;

    private string generateId() {
        idCounter++;
        return "proj-" ~ idCounter.to!string;
    }
}
