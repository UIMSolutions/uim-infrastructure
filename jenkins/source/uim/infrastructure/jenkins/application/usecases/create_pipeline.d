module uim.infrastructure.jenkins.application.usecases.create_pipeline;

import jenkins_service.application.dto.commands : CreatePipelineCommand;
import jenkins_service.domain.entities.pipeline : Pipeline, PipelineStatus, Stage;
import jenkins_service.domain.ports.pipeline_repository : IPipelineRepository;
import std.conv : to;
import std.datetime : Clock;

class CreatePipelineUseCase {
    private IPipelineRepository repository;

    this(IPipelineRepository repository) {
        this.repository = repository;
    }

    Pipeline execute(in CreatePipelineCommand command) {
        enforceCommand(command);

        Stage[] stages;
        foreach (i; 0 .. command.stageNames.length) {
            stages ~= Stage(
                command.stageNames[i],
                command.stageCommands[i],
                command.stageTimeouts[i]
            );
        }

        auto pipeline = Pipeline(
            generateId(),
            command.name,
            command.description,
            command.repository,
            command.branch.length > 0 ? command.branch : "main",
            PipelineStatus.active,
            stages,
            Clock.currTime.toUTC.toISOExtString
        );

        repository.save(pipeline);
        return pipeline;
    }

    private void enforceCommand(in CreatePipelineCommand command) {
        if (command.name.length == 0) {
            throw new Exception("pipeline name must not be empty");
        }
        if (command.repository.length == 0) {
            throw new Exception("repository must not be empty");
        }
        if (command.stageNames.length == 0) {
            throw new Exception("pipeline must have at least one stage");
        }
        if (command.stageNames.length != command.stageCommands.length ||
            command.stageNames.length != command.stageTimeouts.length) {
            throw new Exception("stage names, commands, and timeouts must have the same length");
        }
    }

    private static uint idCounter = 0;

    private string generateId() {
        idCounter++;
        return "p-" ~ idCounter.to!string;
    }
}
