module app;

import uim.infrastructure.ansible.application.usecases.create_host : CreateHostUseCase;
import uim.infrastructure.ansible.application.usecases.list_hosts : ListHostsUseCase;
import uim.infrastructure.ansible.application.usecases.get_host : GetHostUseCase;
import uim.infrastructure.ansible.application.usecases.delete_host : DeleteHostUseCase;
import uim.infrastructure.ansible.application.usecases.create_inventory : CreateInventoryUseCase;
import uim.infrastructure.ansible.application.usecases.list_inventories : ListInventoriesUseCase;
import uim.infrastructure.ansible.application.usecases.get_inventory : GetInventoryUseCase;
import uim.infrastructure.ansible.application.usecases.delete_inventory : DeleteInventoryUseCase;
import uim.infrastructure.ansible.application.usecases.create_task : CreateTaskUseCase;
import uim.infrastructure.ansible.application.usecases.list_tasks : ListTasksUseCase;
import uim.infrastructure.ansible.application.usecases.get_task : GetTaskUseCase;
import uim.infrastructure.ansible.application.usecases.delete_task : DeleteTaskUseCase;
import uim.infrastructure.ansible.application.usecases.create_playbook : CreatePlaybookUseCase;
import uim.infrastructure.ansible.application.usecases.list_playbooks : ListPlaybooksUseCase;
import uim.infrastructure.ansible.application.usecases.get_playbook : GetPlaybookUseCase;
import uim.infrastructure.ansible.application.usecases.delete_playbook : DeletePlaybookUseCase;
import uim.infrastructure.ansible.application.usecases.run_playbook : RunPlaybookUseCase;
import uim.infrastructure.ansible.application.usecases.list_executions : ListExecutionsUseCase;
import uim.infrastructure.ansible.application.usecases.get_execution : GetExecutionUseCase;
import uim.infrastructure.ansible.infrastructure.http.controllers.ansible : AnsibleController;
import uim.infrastructure.ansible.infrastructure.persistence.memory.host_repository : InMemoryHostRepository;
import uim.infrastructure.ansible.infrastructure.persistence.memory.inventory_repository : InMemoryInventoryRepository;
import uim.infrastructure.ansible.infrastructure.persistence.memory.task_repository : InMemoryTaskRepository;
import uim.infrastructure.ansible.infrastructure.persistence.memory.playbook_repository : InMemoryPlaybookRepository;
import uim.infrastructure.ansible.infrastructure.persistence.memory.execution_repository : InMemoryExecutionRepository;
import std.conv : to;
import std.exception : collectException;
import std.string : fromStringz;
import core.stdc.stdlib : getenv;
import vibe.vibe;

void main() {
    auto settings = new HTTPServerSettings;
    settings.port = readPort();
    settings.bindAddresses = [readBindAddress()];

    // --- Outbound adapters (repositories) ---
    auto hostRepo = new InMemoryHostRepository();
    auto inventoryRepo = new InMemoryInventoryRepository();
    auto taskRepo = new InMemoryTaskRepository();
    auto playbookRepo = new InMemoryPlaybookRepository();
    auto executionRepo = new InMemoryExecutionRepository();

    // --- Use cases ---
    auto createHostUC = new CreateHostUseCase(hostRepo);
    auto listHostsUC = new ListHostsUseCase(hostRepo);
    auto getHostUC = new GetHostUseCase(hostRepo);
    auto deleteHostUC = new DeleteHostUseCase(hostRepo);
    auto createInventoryUC = new CreateInventoryUseCase(inventoryRepo);
    auto listInventoriesUC = new ListInventoriesUseCase(inventoryRepo);
    auto getInventoryUC = new GetInventoryUseCase(inventoryRepo);
    auto deleteInventoryUC = new DeleteInventoryUseCase(inventoryRepo);
    auto createTaskUC = new CreateTaskUseCase(taskRepo);
    auto listTasksUC = new ListTasksUseCase(taskRepo);
    auto getTaskUC = new GetTaskUseCase(taskRepo);
    auto deleteTaskUC = new DeleteTaskUseCase(taskRepo);
    auto createPlaybookUC = new CreatePlaybookUseCase(playbookRepo);
    auto listPlaybooksUC = new ListPlaybooksUseCase(playbookRepo);
    auto getPlaybookUC = new GetPlaybookUseCase(playbookRepo);
    auto deletePlaybookUC = new DeletePlaybookUseCase(playbookRepo);
    auto runPlaybookUC = new RunPlaybookUseCase(playbookRepo, inventoryRepo, hostRepo, taskRepo, executionRepo);
    auto listExecutionsUC = new ListExecutionsUseCase(executionRepo);
    auto getExecutionUC = new GetExecutionUseCase(executionRepo);

    // --- Inbound adapter (HTTP controller) ---
    auto controller = new AnsibleController(
        createHostUC, listHostsUC, getHostUC, deleteHostUC,
        createInventoryUC, listInventoriesUC, getInventoryUC, deleteInventoryUC,
        createTaskUC, listTasksUC, getTaskUC, deleteTaskUC,
        createPlaybookUC, listPlaybooksUC, getPlaybookUC, deletePlaybookUC,
        runPlaybookUC, listExecutionsUC, getExecutionUC
    );

    auto router = new URLRouter;
    controller.registerRoutes(router);

    logInfo("Ansible automation service starting on %s:%d", settings.bindAddresses[0], settings.port);
    listenHTTP(settings, router);
    runApplication();
}

private ushort readPort() {
    auto raw = getenv("PORT");
    if (raw is null) {
        return 8080;
    }

    ushort parsed;
    auto err = collectException(parsed = fromStringz(raw).to!ushort);
    return err is null ? parsed : cast(ushort) 8080;
}

private string readBindAddress() {
    auto raw = getenv("BIND_ADDRESS");
    return raw is null ? "0.0.0.0".idup : fromStringz(raw).idup;
}
