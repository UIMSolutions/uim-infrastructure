module uim.infrastructure.ansible.infrastructure.http.controllers.ansible;

import uim.infrastructure.ansible.application.dto.commands;
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
import uim.infrastructure.ansible.domain.entities.host : Host;
import uim.infrastructure.ansible.domain.entities.inventory : Inventory, HostGroup;
import uim.infrastructure.ansible.domain.entities.task : Task;
import uim.infrastructure.ansible.domain.entities.playbook : Playbook, Play;
import uim.infrastructure.ansible.domain.entities.execution : Execution, TaskResult;
import std.conv : to;
import std.string : startsWith;
import vibe.http.router : URLRouter;
import vibe.http.server : HTTPServerRequest, HTTPServerResponse;
import vibe.http.common : HTTPStatus;
import vibe.data.json : Json, serializeToJsonString;

// --- View structs ---

struct HostView {
    string id;
    string hostname;
    string ipAddress;
    ushort port;
    string user;
    string status;
}

struct InventoryView {
    string id;
    string name;
    string description;
    uint groupCount;
}

struct TaskView {
    string id;
    string name;
    string taskModule;
    bool ignoreErrors;
    string when;
}

struct PlaybookView {
    string id;
    string name;
    string description;
    uint playCount;
}

struct TaskResultView {
    string taskId;
    string taskName;
    string hostId;
    string hostname;
    bool changed;
    bool failed;
    string output;
    string error;
}

struct ExecutionView {
    string id;
    string playbookId;
    string playbookName;
    string inventoryId;
    string status;
    uint okCount;
    uint failedCount;
    uint changedCount;
    string startedAt;
    string finishedAt;
}

struct ExecutionDetailView {
    string id;
    string playbookId;
    string playbookName;
    string inventoryId;
    string status;
    TaskResultView[] results;
    string startedAt;
    string finishedAt;
}

class AnsibleController {
    private CreateHostUseCase createHostUC;
    private ListHostsUseCase listHostsUC;
    private GetHostUseCase getHostUC;
    private DeleteHostUseCase deleteHostUC;
    private CreateInventoryUseCase createInventoryUC;
    private ListInventoriesUseCase listInventoriesUC;
    private GetInventoryUseCase getInventoryUC;
    private DeleteInventoryUseCase deleteInventoryUC;
    private CreateTaskUseCase createTaskUC;
    private ListTasksUseCase listTasksUC;
    private GetTaskUseCase getTaskUC;
    private DeleteTaskUseCase deleteTaskUC;
    private CreatePlaybookUseCase createPlaybookUC;
    private ListPlaybooksUseCase listPlaybooksUC;
    private GetPlaybookUseCase getPlaybookUC;
    private DeletePlaybookUseCase deletePlaybookUC;
    private RunPlaybookUseCase runPlaybookUC;
    private ListExecutionsUseCase listExecutionsUC;
    private GetExecutionUseCase getExecutionUC;

    this(
        CreateHostUseCase createHostUC,
        ListHostsUseCase listHostsUC,
        GetHostUseCase getHostUC,
        DeleteHostUseCase deleteHostUC,
        CreateInventoryUseCase createInventoryUC,
        ListInventoriesUseCase listInventoriesUC,
        GetInventoryUseCase getInventoryUC,
        DeleteInventoryUseCase deleteInventoryUC,
        CreateTaskUseCase createTaskUC,
        ListTasksUseCase listTasksUC,
        GetTaskUseCase getTaskUC,
        DeleteTaskUseCase deleteTaskUC,
        CreatePlaybookUseCase createPlaybookUC,
        ListPlaybooksUseCase listPlaybooksUC,
        GetPlaybookUseCase getPlaybookUC,
        DeletePlaybookUseCase deletePlaybookUC,
        RunPlaybookUseCase runPlaybookUC,
        ListExecutionsUseCase listExecutionsUC,
        GetExecutionUseCase getExecutionUC
    ) {
        this.createHostUC = createHostUC;
        this.listHostsUC = listHostsUC;
        this.getHostUC = getHostUC;
        this.deleteHostUC = deleteHostUC;
        this.createInventoryUC = createInventoryUC;
        this.listInventoriesUC = listInventoriesUC;
        this.getInventoryUC = getInventoryUC;
        this.deleteInventoryUC = deleteInventoryUC;
        this.createTaskUC = createTaskUC;
        this.listTasksUC = listTasksUC;
        this.getTaskUC = getTaskUC;
        this.deleteTaskUC = deleteTaskUC;
        this.createPlaybookUC = createPlaybookUC;
        this.listPlaybooksUC = listPlaybooksUC;
        this.getPlaybookUC = getPlaybookUC;
        this.deletePlaybookUC = deletePlaybookUC;
        this.runPlaybookUC = runPlaybookUC;
        this.listExecutionsUC = listExecutionsUC;
        this.getExecutionUC = getExecutionUC;
    }

    void registerRoutes(URLRouter router) {
        router.get("/health", &health);

        // Hosts
        router.get("/v1/hosts", &listHosts);
        router.post("/v1/hosts", &createHost);
        router.get("/v1/hosts/*", &getHost);
        router.delete_("/v1/hosts/*", &deleteHost);

        // Inventories
        router.get("/v1/inventories", &listInventories);
        router.post("/v1/inventories", &createInventory);
        router.get("/v1/inventories/*", &getInventory);
        router.delete_("/v1/inventories/*", &deleteInventory);

        // Tasks
        router.get("/v1/tasks", &listTasks);
        router.post("/v1/tasks", &createTask);
        router.get("/v1/tasks/*", &getTask);
        router.delete_("/v1/tasks/*", &deleteTask);

        // Playbooks
        router.get("/v1/playbooks", &listPlaybooks);
        router.post("/v1/playbooks", &createPlaybook);
        router.get("/v1/playbooks/*", &getPlaybook);
        router.delete_("/v1/playbooks/*", &deletePlaybook);

        // Run playbook
        router.post("/v1/run", &runPlaybook);

        // Executions
        router.get("/v1/executions", &listExecutions);
        router.get("/v1/executions/*", &getExecution);
    }

    // --- Health ---

    void health(HTTPServerRequest req, HTTPServerResponse res) {
        writeJson(res, `{ "status": "ok", "service": "uim-ansible-service" }`, HTTPStatus.ok);
    }

    // --- Hosts ---

    void listHosts(HTTPServerRequest req, HTTPServerResponse res) {
        auto hosts = listHostsUC.execute();
        writeJson(res, serializeToJsonString(hostsToViews(hosts)), HTTPStatus.ok);
    }

    void createHost(HTTPServerRequest req, HTTPServerResponse res) {
        try {
            auto json = req.json;
            string[string] vars;
            if ("variables" in json) {
                foreach (string k, v; json["variables"])
                    vars[k] = v.get!string;
            }
            auto command = CreateHostCommand(
                json["hostname"].get!string,
                json["ipAddress"].get!string,
                ("port" in json) ? json["port"].get!ushort : cast(ushort) 22,
                ("user" in json) ? json["user"].get!string : "root",
                vars
            );
            auto created = createHostUC.execute(command);
            writeJson(res, serializeToJsonString(hostToView(created)), HTTPStatus.created);
        } catch (Exception ex) {
            writeJson(res, `{ "error": "` ~ ex.msg ~ `" }`, HTTPStatus.badRequest);
        }
    }

    void getHost(HTTPServerRequest req, HTTPServerResponse res) {
        auto id = extractId(req.requestPath.to!string, "/v1/hosts/");
        if (id.length == 0) { writeJson(res, `{ "error": "missing host id" }`, HTTPStatus.badRequest); return; }
        try {
            auto ptr = getHostUC.execute(id);
            if (ptr is null) { writeJson(res, `{ "error": "host not found" }`, HTTPStatus.notFound); return; }
            writeJson(res, serializeToJsonString(hostToView(*ptr)), HTTPStatus.ok);
        } catch (Exception ex) { writeJson(res, `{ "error": "` ~ ex.msg ~ `" }`, HTTPStatus.badRequest); }
    }

    void deleteHost(HTTPServerRequest req, HTTPServerResponse res) {
        auto id = extractId(req.requestPath.to!string, "/v1/hosts/");
        if (id.length == 0) { writeJson(res, `{ "error": "missing host id" }`, HTTPStatus.badRequest); return; }
        try { deleteHostUC.execute(id); writeJson(res, `{ "status": "deleted" }`, HTTPStatus.ok); }
        catch (Exception ex) { writeJson(res, `{ "error": "` ~ ex.msg ~ `" }`, HTTPStatus.badRequest); }
    }

    // --- Inventories ---

    void listInventories(HTTPServerRequest req, HTTPServerResponse res) {
        auto inventories = listInventoriesUC.execute();
        writeJson(res, serializeToJsonString(inventoriesToViews(inventories)), HTTPStatus.ok);
    }

    void createInventory(HTTPServerRequest req, HTTPServerResponse res) {
        try {
            auto json = req.json;
            GroupDef[] groups;
            if ("groups" in json) {
                foreach (g; json["groups"]) {
                    string[] hids;
                    foreach (h; g["hostIds"])
                        hids ~= h.get!string;
                    string[string] gv;
                    if ("groupVars" in g) {
                        foreach (string k, v; g["groupVars"])
                            gv[k] = v.get!string;
                    }
                    groups ~= GroupDef(g["name"].get!string, hids, gv);
                }
            }
            auto command = CreateInventoryCommand(
                json["name"].get!string,
                ("description" in json) ? json["description"].get!string : "",
                groups
            );
            auto created = createInventoryUC.execute(command);
            writeJson(res, serializeToJsonString(inventoryToView(created)), HTTPStatus.created);
        } catch (Exception ex) { writeJson(res, `{ "error": "` ~ ex.msg ~ `" }`, HTTPStatus.badRequest); }
    }

    void getInventory(HTTPServerRequest req, HTTPServerResponse res) {
        auto id = extractId(req.requestPath.to!string, "/v1/inventories/");
        if (id.length == 0) { writeJson(res, `{ "error": "missing inventory id" }`, HTTPStatus.badRequest); return; }
        try {
            auto ptr = getInventoryUC.execute(id);
            if (ptr is null) { writeJson(res, `{ "error": "inventory not found" }`, HTTPStatus.notFound); return; }
            writeJson(res, serializeToJsonString(inventoryToView(*ptr)), HTTPStatus.ok);
        } catch (Exception ex) { writeJson(res, `{ "error": "` ~ ex.msg ~ `" }`, HTTPStatus.badRequest); }
    }

    void deleteInventory(HTTPServerRequest req, HTTPServerResponse res) {
        auto id = extractId(req.requestPath.to!string, "/v1/inventories/");
        if (id.length == 0) { writeJson(res, `{ "error": "missing inventory id" }`, HTTPStatus.badRequest); return; }
        try { deleteInventoryUC.execute(id); writeJson(res, `{ "status": "deleted" }`, HTTPStatus.ok); }
        catch (Exception ex) { writeJson(res, `{ "error": "` ~ ex.msg ~ `" }`, HTTPStatus.badRequest); }
    }

    // --- Tasks ---

    void listTasks(HTTPServerRequest req, HTTPServerResponse res) {
        auto tasks = listTasksUC.execute();
        writeJson(res, serializeToJsonString(tasksToViews(tasks)), HTTPStatus.ok);
    }

    void createTask(HTTPServerRequest req, HTTPServerResponse res) {
        try {
            auto json = req.json;
            string[string] params;
            if ("parameters" in json) {
                foreach (string k, v; json["parameters"])
                    params[k] = v.get!string;
            }
            auto command = CreateTaskCommand(
                json["name"].get!string,
                json["taskModule"].get!string,
                params,
                ("ignoreErrors" in json) ? json["ignoreErrors"].get!bool : false,
                ("when" in json) ? json["when"].get!string : ""
            );
            auto created = createTaskUC.execute(command);
            writeJson(res, serializeToJsonString(taskToView(created)), HTTPStatus.created);
        } catch (Exception ex) { writeJson(res, `{ "error": "` ~ ex.msg ~ `" }`, HTTPStatus.badRequest); }
    }

    void getTask(HTTPServerRequest req, HTTPServerResponse res) {
        auto id = extractId(req.requestPath.to!string, "/v1/tasks/");
        if (id.length == 0) { writeJson(res, `{ "error": "missing task id" }`, HTTPStatus.badRequest); return; }
        try {
            auto ptr = getTaskUC.execute(id);
            if (ptr is null) { writeJson(res, `{ "error": "task not found" }`, HTTPStatus.notFound); return; }
            writeJson(res, serializeToJsonString(taskToView(*ptr)), HTTPStatus.ok);
        } catch (Exception ex) { writeJson(res, `{ "error": "` ~ ex.msg ~ `" }`, HTTPStatus.badRequest); }
    }

    void deleteTask(HTTPServerRequest req, HTTPServerResponse res) {
        auto id = extractId(req.requestPath.to!string, "/v1/tasks/");
        if (id.length == 0) { writeJson(res, `{ "error": "missing task id" }`, HTTPStatus.badRequest); return; }
        try { deleteTaskUC.execute(id); writeJson(res, `{ "status": "deleted" }`, HTTPStatus.ok); }
        catch (Exception ex) { writeJson(res, `{ "error": "` ~ ex.msg ~ `" }`, HTTPStatus.badRequest); }
    }

    // --- Playbooks ---

    void listPlaybooks(HTTPServerRequest req, HTTPServerResponse res) {
        auto playbooks = listPlaybooksUC.execute();
        writeJson(res, serializeToJsonString(playbooksToViews(playbooks)), HTTPStatus.ok);
    }

    void createPlaybook(HTTPServerRequest req, HTTPServerResponse res) {
        try {
            auto json = req.json;
            PlayDef[] plays;
            if ("plays" in json) {
                foreach (p; json["plays"]) {
                    string[] tids;
                    foreach (t; p["taskIds"])
                        tids ~= t.get!string;
                    string[string] pv;
                    if ("vars" in p) {
                        foreach (string k, v; p["vars"])
                            pv[k] = v.get!string;
                    }
                    plays ~= PlayDef(
                        p["name"].get!string,
                        p["targetGroup"].get!string,
                        tids,
                        pv,
                        ("become" in p) ? p["become"].get!bool : false
                    );
                }
            }
            auto command = CreatePlaybookCommand(
                json["name"].get!string,
                ("description" in json) ? json["description"].get!string : "",
                plays
            );
            auto created = createPlaybookUC.execute(command);
            writeJson(res, serializeToJsonString(playbookToView(created)), HTTPStatus.created);
        } catch (Exception ex) { writeJson(res, `{ "error": "` ~ ex.msg ~ `" }`, HTTPStatus.badRequest); }
    }

    void getPlaybook(HTTPServerRequest req, HTTPServerResponse res) {
        auto id = extractId(req.requestPath.to!string, "/v1/playbooks/");
        if (id.length == 0) { writeJson(res, `{ "error": "missing playbook id" }`, HTTPStatus.badRequest); return; }
        try {
            auto ptr = getPlaybookUC.execute(id);
            if (ptr is null) { writeJson(res, `{ "error": "playbook not found" }`, HTTPStatus.notFound); return; }
            writeJson(res, serializeToJsonString(playbookToView(*ptr)), HTTPStatus.ok);
        } catch (Exception ex) { writeJson(res, `{ "error": "` ~ ex.msg ~ `" }`, HTTPStatus.badRequest); }
    }

    void deletePlaybook(HTTPServerRequest req, HTTPServerResponse res) {
        auto id = extractId(req.requestPath.to!string, "/v1/playbooks/");
        if (id.length == 0) { writeJson(res, `{ "error": "missing playbook id" }`, HTTPStatus.badRequest); return; }
        try { deletePlaybookUC.execute(id); writeJson(res, `{ "status": "deleted" }`, HTTPStatus.ok); }
        catch (Exception ex) { writeJson(res, `{ "error": "` ~ ex.msg ~ `" }`, HTTPStatus.badRequest); }
    }

    // --- Run Playbook ---

    void runPlaybook(HTTPServerRequest req, HTTPServerResponse res) {
        try {
            auto json = req.json;
            auto command = RunPlaybookCommand(
                json["playbookId"].get!string,
                json["inventoryId"].get!string
            );
            auto execution = runPlaybookUC.execute(command);
            writeJson(res, serializeToJsonString(executionToDetailView(execution)), HTTPStatus.created);
        } catch (Exception ex) { writeJson(res, `{ "error": "` ~ ex.msg ~ `" }`, HTTPStatus.badRequest); }
    }

    // --- Executions ---

    void listExecutions(HTTPServerRequest req, HTTPServerResponse res) {
        auto executions = listExecutionsUC.execute();
        writeJson(res, serializeToJsonString(executionsToViews(executions)), HTTPStatus.ok);
    }

    void getExecution(HTTPServerRequest req, HTTPServerResponse res) {
        auto id = extractId(req.requestPath.to!string, "/v1/executions/");
        if (id.length == 0) { writeJson(res, `{ "error": "missing execution id" }`, HTTPStatus.badRequest); return; }
        try {
            auto ptr = getExecutionUC.execute(id);
            if (ptr is null) { writeJson(res, `{ "error": "execution not found" }`, HTTPStatus.notFound); return; }
            writeJson(res, serializeToJsonString(executionToDetailView(*ptr)), HTTPStatus.ok);
        } catch (Exception ex) { writeJson(res, `{ "error": "` ~ ex.msg ~ `" }`, HTTPStatus.badRequest); }
    }

    // --- View converters ---

    private HostView hostToView(in Host h) {
        return HostView(h.id, h.hostname, h.ipAddress, h.port, h.user, h.status.to!string);
    }

    private HostView[] hostsToViews(scope const Host[] hosts) {
        HostView[] views;
        foreach (h; hosts) views ~= hostToView(h);
        return views;
    }

    private InventoryView inventoryToView(in Inventory inv) {
        return InventoryView(inv.id, inv.name, inv.description, cast(uint) inv.groups.length);
    }

    private InventoryView[] inventoriesToViews(scope const Inventory[] inventories) {
        InventoryView[] views;
        foreach (inv; inventories) views ~= inventoryToView(inv);
        return views;
    }

    private TaskView taskToView(in Task t) {
        return TaskView(t.id, t.name, t.taskModule.to!string, t.ignoreErrors, t.when);
    }

    private TaskView[] tasksToViews(scope const Task[] tasks) {
        TaskView[] views;
        foreach (t; tasks) views ~= taskToView(t);
        return views;
    }

    private PlaybookView playbookToView(in Playbook pb) {
        return PlaybookView(pb.id, pb.name, pb.description, cast(uint) pb.plays.length);
    }

    private PlaybookView[] playbooksToViews(scope const Playbook[] playbooks) {
        PlaybookView[] views;
        foreach (pb; playbooks) views ~= playbookToView(pb);
        return views;
    }

    private ExecutionView executionToView(in Execution e) {
        return ExecutionView(e.id, e.playbookId, e.playbookName, e.inventoryId, e.status.to!string, e.okCount(), e.failedCount(), e.changedCount(), e.startedAt, e.finishedAt);
    }

    private ExecutionView[] executionsToViews(scope const Execution[] executions) {
        ExecutionView[] views;
        foreach (e; executions) views ~= executionToView(e);
        return views;
    }

    private ExecutionDetailView executionToDetailView(in Execution e) {
        TaskResultView[] results;
        foreach (r; e.results)
            results ~= TaskResultView(r.taskId, r.taskName, r.hostId, r.hostname, r.changed, r.failed, r.output, r.error);
        return ExecutionDetailView(e.id, e.playbookId, e.playbookName, e.inventoryId, e.status.to!string, results, e.startedAt, e.finishedAt);
    }

    // --- Helpers ---

    private string extractId(string requestPath, string prefix) {
        if (!requestPath.startsWith(prefix))
            return "";
        return requestPath[prefix.length .. $];
    }

    private void writeJson(HTTPServerResponse res, string body, HTTPStatus status) {
        res.writeBody(body, cast(int) status, "application/json");
    }
}
