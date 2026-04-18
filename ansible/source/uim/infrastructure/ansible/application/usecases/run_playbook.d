module uim.infrastructure.ansible.application.usecases.run_playbook;

import std.conv : to;
import std.digest : toHexString;
import std.digest.sha : sha256Of;
import std.datetime : Clock;
import uim.infrastructure.ansible.application.dto.commands : RunPlaybookCommand;
import uim.infrastructure.ansible.domain.entities.execution : Execution, ExecutionStatus, TaskResult;
import uim.infrastructure.ansible.domain.entities.inventory : Inventory;
import uim.infrastructure.ansible.domain.entities.playbook : Playbook;
import uim.infrastructure.ansible.domain.entities.host : Host;
import uim.infrastructure.ansible.domain.entities.task : Task;
import uim.infrastructure.ansible.domain.ports.repositories.execution : IExecutionRepository;
import uim.infrastructure.ansible.domain.ports.repositories.playbook : IPlaybookRepository;
import uim.infrastructure.ansible.domain.ports.repositories.inventory : IInventoryRepository;
import uim.infrastructure.ansible.domain.ports.repositories.host : IHostRepository;
import uim.infrastructure.ansible.domain.ports.repositories.task : ITaskRepository;

class RunPlaybookUseCase {
    private IPlaybookRepository playbookRepo;
    private IInventoryRepository inventoryRepo;
    private IHostRepository hostRepo;
    private ITaskRepository taskRepo;
    private IExecutionRepository executionRepo;

    this(
        IPlaybookRepository playbookRepo,
        IInventoryRepository inventoryRepo,
        IHostRepository hostRepo,
        ITaskRepository taskRepo,
        IExecutionRepository executionRepo
    ) {
        this.playbookRepo = playbookRepo;
        this.inventoryRepo = inventoryRepo;
        this.hostRepo = hostRepo;
        this.taskRepo = taskRepo;
        this.executionRepo = executionRepo;
    }

    Execution execute(in RunPlaybookCommand command) {
        if (command.playbookId.length == 0)
            throw new Exception("playbookId must not be empty");
        if (command.inventoryId.length == 0)
            throw new Exception("inventoryId must not be empty");

        auto pbPtr = playbookRepo.findById(command.playbookId);
        if (pbPtr is null)
            throw new Exception("playbook not found: " ~ command.playbookId);

        auto invPtr = inventoryRepo.findById(command.inventoryId);
        if (invPtr is null)
            throw new Exception("inventory not found: " ~ command.inventoryId);

        auto playbook = *pbPtr;
        auto inventory = *invPtr;
        auto startedAt = Clock.currTime.toISOExtString();
        auto execId = generateId(playbook.id ~ inventory.id ~ startedAt);

        TaskResult[] results;
        bool anyFailed = false;

        foreach (play; playbook.plays) {
            auto hostIds = resolveHosts(inventory, play.targetGroup);

            foreach (taskId; play.taskIds) {
                auto taskPtr = taskRepo.findById(taskId);
                string taskName = (taskPtr !is null) ? (*taskPtr).name : taskId;

                foreach (hostId; hostIds) {
                    auto hostPtr = hostRepo.findById(hostId);
                    string hostname = (hostPtr !is null) ? (*hostPtr).hostname : hostId;

                    auto result = simulateTask(taskId, taskName, hostId, hostname);
                    results ~= result;

                    if (result.failed)
                        anyFailed = true;
                }
            }
        }

        auto finishedAt = Clock.currTime.toISOExtString();
        auto status = anyFailed ? ExecutionStatus.FAILED : ExecutionStatus.SUCCESS;

        auto execution = Execution(execId, playbook.id, playbook.name, inventory.id, status, results, startedAt, finishedAt);
        executionRepo.save(execution);
        return execution;
    }

    private string[] resolveHosts(in Inventory inventory, string targetGroup) {
        foreach (group; inventory.groups) {
            if (group.name == targetGroup)
                return group.hostIds.dup;
        }
        return [];
    }

    private TaskResult simulateTask(string taskId, string taskName, string hostId, string hostname) {
        return TaskResult(taskId, taskName, hostId, hostname, true, false, "ok: [" ~ hostname ~ "]", "");
    }

    private string generateId(string seed) {
        auto hash = sha256Of(seed);
        return toHexString(hash[0 .. 8]).idup;
    }
}
