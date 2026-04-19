module uim.infrastructure.infobox.application.usecases.create_job;

import uim.infrastructure.infobox.application.dto.commands : CreateJobCommand;
import uim.infrastructure.infobox.domain.entities.job : Job, JobType, JobStatus, ResourceLimits, Dependency, EnvironmentVar;
import uim.infrastructure.infobox.domain.ports.repositories.job : IJobRepository;
import uim.infrastructure.infobox.domain.ports.repositories.build : IBuildRepository;
import std.conv : to;
import std.datetime : Clock;

class CreateJobUseCase {
    private IJobRepository jobRepo;
    private IBuildRepository buildRepo;

    this(IJobRepository jobRepo, IBuildRepository buildRepo) {
        this.jobRepo = jobRepo;
        this.buildRepo = buildRepo;
    }

    Job execute(in CreateJobCommand command) {
        enforceCommand(command);

        Dependency[] deps;
        foreach (depName; command.dependencyNames) {
            deps ~= Dependency(depName, true, false);
        }

        EnvironmentVar[] envVars;
        foreach (i; 0 .. command.envNames.length) {
            envVars ~= EnvironmentVar(
                command.envNames[i],
                command.envValues[i],
                command.envIsSecret[i],
            );
        }

        auto job = Job(
            generateId(),
            command.projectId,
            command.buildId,
            command.name,
            parseJobType(command.jobType),
            JobStatus.queued,
            command.dockerFile,
            command.image,
            command.command,
            command.buildContext.length > 0 ? command.buildContext : ".",
            ResourceLimits(
                command.cpuMillis > 0 ? command.cpuMillis : 1000,
                command.memoryMb > 0 ? command.memoryMb : 2048,
                command.timeoutSeconds > 0 ? command.timeoutSeconds : 600,
            ),
            deps,
            envVars,
            "",
            0,
            "",
            "",
        );

        jobRepo.save(job);
        return job;
    }

    private void enforceCommand(in CreateJobCommand command) {
        if (command.name.length == 0) {
            throw new Exception("job name must not be empty");
        }
        if (command.buildId.length == 0) {
            throw new Exception("build id must not be empty");
        }
        if (command.projectId.length == 0) {
            throw new Exception("project id must not be empty");
        }
        if (command.envNames.length != command.envValues.length ||
            command.envNames.length != command.envIsSecret.length) {
            throw new Exception("env names, values, and isSecret must have the same length");
        }
    }

    private JobType parseJobType(string typeStr) {
        switch (typeStr) {
            case "docker_compose": return JobType.docker_compose;
            case "docker_image": return JobType.docker_image;
            case "git": return JobType.git;
            case "workflow": return JobType.workflow;
            default: return JobType.docker;
        }
    }

    private static uint idCounter = 0;

    private string generateId() {
        idCounter++;
        return "job-" ~ idCounter.to!string;
    }
}
