module uim.infrastructure.ansible.infrastructure.persistence.memory.task_repository;

import core.sync.mutex : Mutex;
import uim.infrastructure.ansible.domain.entities.task : Task;
import uim.infrastructure.ansible.domain.ports.repositories.task : ITaskRepository;

class InMemoryTaskRepository : ITaskRepository {
    private Task[] tasks;
    private Mutex mutex;

    this() {
        mutex = new Mutex;
    }

    private Task copyTask(in Task t) {
        string[string] params;
        foreach (k, v; t.parameters)
            params[k] = v;
        return Task(t.id, t.name, t.taskModule, params, t.ignoreErrors, t.when);
    }

    override void save(in Task task) {
        synchronized (mutex) {
            auto copy = copyTask(task);
            foreach (i, ref existing; tasks) {
                if (existing.id == task.id) {
                    tasks[i] = copy;
                    return;
                }
            }
            tasks ~= copy;
        }
    }

    override void remove(string id) {
        synchronized (mutex) {
            Task[] filtered;
            foreach (t; tasks) {
                if (t.id != id)
                    filtered ~= t;
            }
            tasks = filtered;
        }
    }

    override Task[] list() {
        synchronized (mutex) {
            return tasks.dup;
        }
    }

    override Task* findById(string id) {
        synchronized (mutex) {
            foreach (ref t; tasks) {
                if (t.id == id)
                    return &t;
            }
            return null;
        }
    }
}

unittest {
    import uim.infrastructure.ansible.domain.entities.task : TaskModule;

    auto repo = new InMemoryTaskRepository();
    string[string] params;
    params["cmd"] = "ls";
    auto task = Task("t1", "List files", TaskModule.COMMAND, params, false, "");
    repo.save(task);

    assert(repo.list().length == 1);
    assert(repo.findById("t1") !is null);
    assert(repo.findById("t1").name == "List files");

    repo.remove("t1");
    assert(repo.list().length == 0);
}
