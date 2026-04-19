module uim.infrastructure.infobox.application.usecases.trigger_build;

import uim.infrastructure.infobox.application.dto.commands : TriggerBuildCommand;
import uim.infrastructure.infobox.domain.entities.build : Build, BuildStatus, BuildTrigger;
import uim.infrastructure.infobox.domain.ports.repositories.build : IBuildRepository;
import uim.infrastructure.infobox.domain.ports.repositories.project : IProjectRepository;
import std.conv : to;
import std.datetime : Clock;

class TriggerBuildUseCase {
    private IProjectRepository projectRepo;
    private IBuildRepository buildRepo;

    this(IProjectRepository projectRepo, IBuildRepository buildRepo) {
        this.projectRepo = projectRepo;
        this.buildRepo = buildRepo;
    }

    Build execute(in TriggerBuildCommand command) {
        if (command.projectId.length == 0) {
            throw new Exception("project id must not be empty");
        }

        auto projectPtr = projectRepo.findById(command.projectId);
        if (projectPtr is null) {
            throw new Exception("project not found: " ~ command.projectId);
        }

        auto buildNumber = buildRepo.nextBuildNumber(command.projectId);
        auto now = Clock.currTime.toUTC.toISOExtString;

        auto build = Build(
            "build-" ~ command.projectId ~ "-" ~ buildNumber.to!string,
            command.projectId,
            buildNumber,
            BuildStatus.queued,
            parseTrigger(command.triggerType),
            command.commitSha,
            command.branch.length > 0 ? command.branch : projectPtr.branch,
            command.triggeredBy.length > 0 ? command.triggeredBy : "system",
            0,
            0,
            now,
            "",
        );

        buildRepo.save(build);
        return build;
    }

    private BuildTrigger parseTrigger(string triggerStr) {
        switch (triggerStr) {
            case "push": return BuildTrigger.push;
            case "pull_request": return BuildTrigger.pull_request;
            case "schedule": return BuildTrigger.schedule;
            case "api": return BuildTrigger.api;
            default: return BuildTrigger.manual;
        }
    }
}
