module uim.infrastructure.jenkins.application.usecases.trigger_build;

import jenkins_service.application.dto.commands : TriggerBuildCommand;
import jenkins_service.domain.entities.build : Build, BuildStatus, StageResult;
import jenkins_service.domain.entities.pipeline : Pipeline;
import jenkins_service.domain.ports.build_repository : IBuildRepository;
import jenkins_service.domain.ports.pipeline_repository : IPipelineRepository;
import std.conv : to;
import std.datetime : Clock;

class TriggerBuildUseCase {
    private IPipelineRepository pipelineRepo;
    private IBuildRepository buildRepo;

    this(IPipelineRepository pipelineRepo, IBuildRepository buildRepo) {
        this.pipelineRepo = pipelineRepo;
        this.buildRepo = buildRepo;
    }

    Build execute(in TriggerBuildCommand command) {
        if (command.pipelineId.length == 0) {
            throw new Exception("pipeline id must not be empty");
        }

        auto pipelinePtr = pipelineRepo.findById(command.pipelineId);
        if (pipelinePtr is null) {
            throw new Exception("pipeline not found: " ~ command.pipelineId);
        }
        auto pipeline = *pipelinePtr;

        auto buildNumber = buildRepo.nextBuildNumber(command.pipelineId);
        auto now = Clock.currTime.toUTC.toISOExtString;

        StageResult[] stageResults;
        foreach (stage; pipeline.stages) {
            stageResults ~= StageResult(stage.name, BuildStatus.pending, "", 0);
        }

        auto build = Build(
            "b-" ~ command.pipelineId ~ "-" ~ buildNumber.to!string,
            command.pipelineId,
            buildNumber,
            BuildStatus.pending,
            stageResults,
            command.triggeredBy.length > 0 ? command.triggeredBy : "system",
            now,
            ""
        );

        buildRepo.save(build);
        return build;
    }
}
