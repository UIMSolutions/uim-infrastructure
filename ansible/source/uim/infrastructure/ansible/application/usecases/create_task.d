module uim.infrastructure.ansible.application.usecases.create_task;

import std.digest : toHexString;
import std.digest.sha : sha256Of;
import std.datetime : Clock;
import uim.infrastructure.ansible.application.dto.commands : CreateTaskCommand;
import uim.infrastructure.ansible.domain.entities.task : Task, parseTaskModule;
import uim.infrastructure.ansible.domain.ports.repositories.task : ITaskRepository;

class CreateTaskUseCase {
    private ITaskRepository repository;

    this(ITaskRepository repository) {
        this.repository = repository;
    }

    Task execute(in CreateTaskCommand command) {
        enforceCommand(command);

        auto id = generateId(command.name);
        string[string] params;
        foreach (k, v; command.parameters)
            params[k] = v;

        auto task = Task(
            id,
            command.name,
            parseTaskModule(command.taskModule),
            params,
            command.ignoreErrors,
            command.when
        );

        repository.save(task);
        return task;
    }

    private void enforceCommand(in CreateTaskCommand command) {
        if (command.name.length == 0)
            throw new Exception("name must not be empty");
        if (command.taskModule.length == 0)
            throw new Exception("taskModule must not be empty");
    }

    private string generateId(string seed) {
        auto ts = Clock.currTime.toISOExtString();
        auto hash = sha256Of(seed ~ ts);
        return toHexString(hash[0 .. 8]).idup;
    }
}
