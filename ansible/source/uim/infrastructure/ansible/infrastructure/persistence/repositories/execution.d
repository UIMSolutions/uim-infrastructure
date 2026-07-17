module uim.infrastructure.ansible.infrastructure.persistence.memory.execution_repository;

import core.sync.mutex : Mutex;
import uim.infrastructure.ansible.domain.entities.execution : Execution, TaskResult;
import uim.infrastructure.ansible.domain.ports.repositories.execution : IExecutionRepository;

class InMemoryExecutionRepository : IExecutionRepository {
    private Execution[] executions;
    private Mutex mutex;

    this() {
        mutex = new Mutex;
    }

    private Execution copyExecution(in Execution e) {
        TaskResult[] results;
        foreach (r; e.results)
            results ~= TaskResult(r.taskId, r.taskName, r.hostId, r.hostname, r.changed, r.failed, r.output, r.error);
        return Execution(e.id, e.playbookId, e.playbookName, e.inventoryId, e.status, results, e.startedAt, e.finishedAt);
    }

    override void save(in Execution execution) {
        synchronized (mutex) {
            auto copy = copyExecution(execution);
            foreach (i, ref existing; executions) {
                if (existing.id == execution.id) {
                    executions[i] = copy;
                    return;
                }
            }
            executions ~= copy;
        }
    }

    override Execution[] list() {
        synchronized (mutex) {
            return executions.dup;
        }
    }

    override Execution* findById(string id) {
        synchronized (mutex) {
            foreach (ref e; executions) {
                if (e.id == id)
                    return &e;
            }
            return null;
        }
    }

    override Execution[] findByPlaybookId(string playbookId) {
        synchronized (mutex) {
            Execution[] result;
            foreach (e; executions) {
                if (e.playbookId == playbookId)
                    result ~= e;
            }
            return result;
        }
    }
}

unittest {
    import uim.infrastructure.ansible.domain.entities.execution : ExecutionStatus;

    auto repo = new InMemoryExecutionRepository();
    auto exec = Execution("e1", "pb1", "Deploy", "i1", ExecutionStatus.SUCCESS, [
        TaskResult("t1", "Install", "h1", "web01", true, false, "ok", "")
    ], "2026-04-18T10:00:00Z", "2026-04-18T10:05:00Z");
    repo.save(exec);

    assert(repo.list().length == 1);
    assert(repo.findById("e1") !is null);
    assert(repo.findByPlaybookId("pb1").length == 1);
}
