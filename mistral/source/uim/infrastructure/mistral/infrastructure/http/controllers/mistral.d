/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.infrastructure.mistral.infrastructure.http.controllers.mistral;

import std.algorithm.searching : canFind;
import std.conv : to;
import std.string : strip, split, splitLines, toLower, indexOf;
import std.uuid : randomUUID;

import vibe.vibe;

import uim.infrastructure.mistral.application.dto.mistral_command : WorkflowCommand, UpdateWorkflowCommand, ExecutionCommand, ActionExecutionCommand;
import uim.infrastructure.mistral.application.usecases.workflow_usecases : WorkflowUseCases;
import uim.infrastructure.mistral.domain.entities.workflow : WorkflowDefinition;
import uim.infrastructure.mistral.domain.entities.execution : WorkflowExecution, executionStateToString;
import uim.infrastructure.mistral.domain.entities.task : TaskExecution;
import uim.infrastructure.mistral.domain.entities.action_execution : ActionExecution;

class MistralController {
private:
    WorkflowUseCases useCases;

public:
    this(WorkflowUseCases useCases) {
        this.useCases = useCases;
    }

    void register(URLRouter router) {
        router.get("/health", &healthHandler);
        router.get("/v2", &apiRootHandler);

        router.get("/v2/workflows", &listWorkflowsHandler);
        router.get("/v2/workflows/*", &getWorkflowHandler);
        router.post("/v2/workflows", &createWorkflowHandler);
        router.put("/v2/workflows/*", &updateWorkflowHandler);
        router.delete_("/v2/workflows/*", &deleteWorkflowHandler);

        router.get("/v2/executions", &listExecutionsHandler);
        router.get("/v2/executions/*", &getExecutionHandler);
        router.post("/v2/executions", &createExecutionHandler);
        router.delete_("/v2/executions/*", &deleteExecutionHandler);

        router.get("/v2/tasks", &listTasksHandler);
        router.get("/v2/tasks/*", &getTaskHandler);

        router.get("/v2/action_executions", &listActionExecutionsHandler);
        router.get("/v2/action_executions/*", &getActionExecutionHandler);
        router.post("/v2/action_executions", &createActionExecutionHandler);
    }

private:
    void healthHandler(HTTPServerRequest req, HTTPServerResponse res) {
        setOpenStackHeaders(res);
        Json body;
        body["status"] = Json("ok");
        body["service"] = Json("uim-mistral-service");
        body["api"] = Json("v2");
        body["source"] = Json("https://docs.openstack.org/mistral/latest/");
        writeJson(res, cast(int) HTTPStatus.ok, body);
    }

    void apiRootHandler(HTTPServerRequest req, HTTPServerResponse res) {
        setOpenStackHeaders(res);
        Json apiVersion;
        apiVersion["id"] = Json("v2.0");
        apiVersion["status"] = Json("stable");
        apiVersion["updated"] = Json("2017-02-16T00:00:00Z");

        Json links = Json.emptyArray;
        Json selfLink;
        selfLink["rel"] = Json("self");
        selfLink["href"] = Json(baseUrl(req) ~ "/v2");
        links ~= selfLink;
        apiVersion["links"] = links;

        Json body;
        body["version"] = apiVersion;
        writeJson(res, cast(int) HTTPStatus.ok, body);
    }

    void listWorkflowsHandler(HTTPServerRequest req, HTTPServerResponse res) {
        setOpenStackHeaders(res);
        auto workflows = useCases.listWorkflows();

        const nameFilter = req.query.get("name", "").to!string;
        const namespaceFilter = req.query.get("namespace", "").to!string;
        const tagsFilter = parseCsvQuery(req.query.get("tags", "").to!string);
        const marker = req.query.get("marker", "").to!string;
        const limit = parseLimit(req, 100, 1000);

        WorkflowDefinition[] filtered;
        foreach (workflow; workflows) {
            if (nameFilter.length > 0 && workflow.name != nameFilter) {
                continue;
            }
            if (namespaceFilter.length > 0 && workflow.namespace_ != namespaceFilter) {
                continue;
            }

            bool hasAllTags = true;
            foreach (tag; tagsFilter) {
                if (!workflow.tags.canFind(tag)) {
                    hasAllTags = false;
                    break;
                }
            }
            if (!hasAllTags) {
                continue;
            }

            filtered ~= workflow;
        }

        const page = paginateWorkflows(filtered, marker, limit);

        Json payload = Json.emptyArray;
        foreach (workflow; page.items) {
            payload ~= toWorkflowJson(req, workflow);
        }

        Json body;
        body["workflows"] = payload;
        body["next"] = page.hasMore
            ? Json(buildNextLink(req, page.nextMarker, limit))
            : Json(null);
        writeJson(res, cast(int) HTTPStatus.ok, body);
    }

    void getWorkflowHandler(HTTPServerRequest req, HTTPServerResponse res) {
        setOpenStackHeaders(res);
        const workflowId = wildcardTail(req.requestPath.to!string, "/v2/workflows/");
        const namespaceValue = req.query.get("namespace", "").to!string;
        auto workflowPtr = useCases.getWorkflow(workflowId, namespaceValue);

        if (workflowPtr is null) {
            writeNotFound(res, "Workflow not found");
            return;
        }

        Json body;
        body["workflow"] = toWorkflowJson(req, *workflowPtr);
        writeJson(res, cast(int) HTTPStatus.ok, body);
    }

    void createWorkflowHandler(HTTPServerRequest req, HTTPServerResponse res) {
        setOpenStackHeaders(res);
        const requestBody = req.json;

        WorkflowCommand command;
        if ("name" in requestBody) {
            command.name = requestBody["name"].get!string;
        }
        if ("namespace" in requestBody) {
            command.namespace_ = requestBody["namespace"].get!string;
        }
        if ("definition" in requestBody) {
            command.definition = requestBody["definition"].get!string;
        }
        if ("description" in requestBody) {
            command.description = requestBody["description"].get!string;
        }
        if ("tags" in requestBody && requestBody["tags"].type == Json.Type.array) {
            foreach (tag; requestBody["tags"]) {
                command.tags ~= tag.get!string;
            }
        }

        if (command.definition.strip.length == 0) {
            Json error;
            error["message"] = Json("Field 'definition' is required");
            error["type"] = Json("InvalidModelException");
            writeJson(res, cast(int) HTTPStatus.badRequest, error);
            return;
        }

        if (command.name.strip.length == 0) {
            command.name = inferWorkflowName(command.definition);
        }

        const workflow = useCases.createWorkflow(command);

        Json body;
        body["workflow"] = toWorkflowJson(req, workflow);
        writeJson(res, cast(int) HTTPStatus.created, body);
    }

    void updateWorkflowHandler(HTTPServerRequest req, HTTPServerResponse res) {
        setOpenStackHeaders(res);
        const workflowId = wildcardTail(req.requestPath.to!string, "/v2/workflows/");
        const namespaceValue = req.query.get("namespace", "").to!string;
        const requestBody = req.json;

        UpdateWorkflowCommand command;
        if ("name" in requestBody) {
            command.name = requestBody["name"].get!string;
            command.updateName = true;
        }
        if ("definition" in requestBody) {
            command.definition = requestBody["definition"].get!string;
            command.updateDefinition = true;
        }
        if ("description" in requestBody) {
            command.description = requestBody["description"].get!string;
            command.updateDescription = true;
        }
        if ("tags" in requestBody && requestBody["tags"].type == Json.Type.array) {
            foreach (tag; requestBody["tags"]) {
                command.tags ~= tag.get!string;
            }
            command.updateTags = true;
        }

        if (!command.updateName && !command.updateDefinition && !command.updateDescription && !command.updateTags) {
            Json error;
            error["message"] = Json("At least one updatable field is required: name, definition, description, tags");
            error["type"] = Json("InvalidModelException");
            writeJson(res, cast(int) HTTPStatus.badRequest, error);
            return;
        }

        auto workflowPtr = useCases.updateWorkflow(workflowId, namespaceValue, command);
        if (workflowPtr is null) {
            writeNotFound(res, "Workflow not found");
            return;
        }

        Json body;
        body["workflow"] = toWorkflowJson(req, *workflowPtr);
        writeJson(res, cast(int) HTTPStatus.ok, body);
    }

    void deleteWorkflowHandler(HTTPServerRequest req, HTTPServerResponse res) {
        setOpenStackHeaders(res);
        const workflowId = wildcardTail(req.requestPath.to!string, "/v2/workflows/");
        const namespaceValue = req.query.get("namespace", "").to!string;

        if (!useCases.deleteWorkflow(workflowId, namespaceValue)) {
            writeNotFound(res, "Workflow not found");
            return;
        }

        Json body;
        body["result"] = Json("deleted");
        writeJson(res, cast(int) HTTPStatus.accepted, body);
    }

    void listExecutionsHandler(HTTPServerRequest req, HTTPServerResponse res) {
        setOpenStackHeaders(res);
        auto executions = useCases.listExecutions();

        const workflowNameFilter = req.query.get("workflow_name", "").to!string;
        const workflowIdFilter = req.query.get("workflow_id", "").to!string;
        const projectIdFilter = req.query.get("project_id", "").to!string;
        const stateFilter = req.query.get("state", "").to!string.toLower();
        const marker = req.query.get("marker", "").to!string;
        const limit = parseLimit(req, 100, 1000);

        WorkflowExecution[] filtered;
        foreach (execution; executions) {
            if (workflowNameFilter.length > 0 && execution.workflowName != workflowNameFilter) {
                continue;
            }
            if (workflowIdFilter.length > 0 && execution.workflowId != workflowIdFilter) {
                continue;
            }
            if (projectIdFilter.length > 0 && execution.projectId != projectIdFilter) {
                continue;
            }
            if (stateFilter.length > 0 && executionStateToString(execution.state).toLower() != stateFilter) {
                continue;
            }
            filtered ~= execution;
        }

        const page = paginateExecutions(filtered, marker, limit);

        Json payload = Json.emptyArray;
        foreach (execution; page.items) {
            payload ~= toExecutionJson(req, execution);
        }

        Json body;
        body["executions"] = payload;
        body["next"] = page.hasMore
            ? Json(buildNextLink(req, page.nextMarker, limit))
            : Json(null);
        writeJson(res, cast(int) HTTPStatus.ok, body);
    }

    void getExecutionHandler(HTTPServerRequest req, HTTPServerResponse res) {
        setOpenStackHeaders(res);
        const executionId = wildcardTail(req.requestPath.to!string, "/v2/executions/");
        auto executionPtr = useCases.getExecution(executionId);

        if (executionPtr is null) {
            writeNotFound(res, "Execution not found");
            return;
        }

        Json body;
        body["execution"] = toExecutionJson(req, *executionPtr);
        writeJson(res, cast(int) HTTPStatus.ok, body);
    }

    void createExecutionHandler(HTTPServerRequest req, HTTPServerResponse res) {
        setOpenStackHeaders(res);
        const requestBody = req.json;

        ExecutionCommand command;
        if ("workflow_id" in requestBody) {
            command.workflowIdentifier = requestBody["workflow_id"].get!string;
        }
        if (command.workflowIdentifier.length == 0 && "workflow_name" in requestBody) {
            command.workflowIdentifier = requestBody["workflow_name"].get!string;
        }
        if ("workflow_namespace" in requestBody) {
            command.workflowNamespace = requestBody["workflow_namespace"].get!string;
        }
        if ("description" in requestBody) {
            command.description = requestBody["description"].get!string;
        }
        if ("project_id" in requestBody) {
            command.projectId = requestBody["project_id"].get!string;
        }
        if ("input" in requestBody) {
            command.inputJson = requestBody["input"].toString();
        }
        if ("params" in requestBody) {
            // Keep payload in domain-friendly string format for the in-memory adapter.
            command.inputJson = requestBody["params"].toString();
        }
        if ("tags" in requestBody && requestBody["tags"].type == Json.Type.array) {
            foreach (tag; requestBody["tags"]) {
                command.tags ~= tag.get!string;
            }
        }

        if (command.workflowIdentifier.strip.length == 0) {
            Json error;
            error["message"] = Json("Either 'workflow_id' or 'workflow_name' is required");
            error["type"] = Json("InvalidModelException");
            writeJson(res, cast(int) HTTPStatus.badRequest, error);
            return;
        }

        const execution = useCases.createExecution(command);

        Json body;
        body["execution"] = toExecutionJson(req, execution);
        writeJson(res, cast(int) HTTPStatus.created, body);
    }

    void deleteExecutionHandler(HTTPServerRequest req, HTTPServerResponse res) {
        setOpenStackHeaders(res);
        const executionId = wildcardTail(req.requestPath.to!string, "/v2/executions/");
        bool force = false;
        if ("force" in req.query) {
            force = req.query.get("force", "false").to!string.toLower() == "true";
        }

        if (!useCases.deleteExecution(executionId, force)) {
            Json error;
            error["message"] = Json("Execution not found or cannot be deleted without force=true");
            error["type"] = Json("WorkflowException");
            writeJson(res, cast(int) HTTPStatus.conflict, error);
            return;
        }

        Json body;
        body["result"] = Json("deleted");
        writeJson(res, cast(int) HTTPStatus.accepted, body);
    }

    void listTasksHandler(HTTPServerRequest req, HTTPServerResponse res) {
        setOpenStackHeaders(res);
        const executionIdFilter = req.query.get("workflow_execution_id", "").to!string;
        const nameFilter = req.query.get("name", "").to!string;
        const stateFilter = req.query.get("state", "").to!string.toLower();
        const marker = req.query.get("marker", "").to!string;
        const limit = parseLimit(req, 100, 1000);

        auto tasks = useCases.listTasks(executionIdFilter);
        TaskExecution[] filtered;
        foreach (task; tasks) {
            if (nameFilter.length > 0 && task.name != nameFilter) {
                continue;
            }
            if (stateFilter.length > 0 && executionStateToString(task.state).toLower() != stateFilter) {
                continue;
            }
            filtered ~= task;
        }

        const page = paginateTasks(filtered, marker, limit);

        Json payload = Json.emptyArray;
        foreach (task; page.items) {
            payload ~= toTaskJson(req, task);
        }

        Json body;
        body["tasks"] = payload;
        body["next"] = page.hasMore
            ? Json(buildNextLink(req, page.nextMarker, limit))
            : Json(null);
        writeJson(res, cast(int) HTTPStatus.ok, body);
    }

    void getTaskHandler(HTTPServerRequest req, HTTPServerResponse res) {
        setOpenStackHeaders(res);
        const taskId = wildcardTail(req.requestPath.to!string, "/v2/tasks/");
        auto taskPtr = useCases.getTask(taskId);

        if (taskPtr is null) {
            writeNotFound(res, "Task not found");
            return;
        }

        Json body;
        body["task"] = toTaskJson(req, *taskPtr);
        writeJson(res, cast(int) HTTPStatus.ok, body);
    }

    void listActionExecutionsHandler(HTTPServerRequest req, HTTPServerResponse res) {
        setOpenStackHeaders(res);
        const taskExecutionIdFilter = req.query.get("task_execution_id", "").to!string;
        const workflowNameFilter = req.query.get("workflow_name", "").to!string;
        const stateFilter = req.query.get("state", "").to!string.toLower();
        const marker = req.query.get("marker", "").to!string;
        const limit = parseLimit(req, 100, 1000);

        auto actionExecutions = useCases.listActionExecutions(taskExecutionIdFilter);
        ActionExecution[] filtered;
        foreach (execution; actionExecutions) {
            if (workflowNameFilter.length > 0 && execution.workflowName != workflowNameFilter) {
                continue;
            }
            if (stateFilter.length > 0 && executionStateToString(execution.state).toLower() != stateFilter) {
                continue;
            }
            filtered ~= execution;
        }

        const page = paginateActionExecutions(filtered, marker, limit);

        Json payload = Json.emptyArray;
        foreach (execution; page.items) {
            payload ~= toActionExecutionJson(req, execution);
        }

        Json body;
        body["action_executions"] = payload;
        body["next"] = page.hasMore
            ? Json(buildNextLink(req, page.nextMarker, limit))
            : Json(null);
        writeJson(res, cast(int) HTTPStatus.ok, body);
    }

    struct WorkflowPage {
        WorkflowDefinition[] items;
        bool hasMore;
        string nextMarker;
    }

    struct ExecutionPage {
        WorkflowExecution[] items;
        bool hasMore;
        string nextMarker;
    }

    struct TaskPage {
        TaskExecution[] items;
        bool hasMore;
        string nextMarker;
    }

    struct ActionExecutionPage {
        ActionExecution[] items;
        bool hasMore;
        string nextMarker;
    }

    WorkflowPage paginateWorkflows(WorkflowDefinition[] items, string marker, int limit) {
        size_t start = findWorkflowStartIndex(items, marker);
        return paginateWorkflowsFrom(items, start, limit);
    }

    WorkflowPage paginateWorkflowsFrom(WorkflowDefinition[] items, size_t start, int limit) {
        WorkflowPage page;
        if (start >= items.length) {
            page.items = [];
            page.hasMore = false;
            page.nextMarker = "";
            return page;
        }

        size_t end = start + cast(size_t) limit;
        if (end > items.length) {
            end = items.length;
        }

        page.items = items[start .. end].dup;
        page.hasMore = end < items.length;
        page.nextMarker = page.hasMore && page.items.length > 0 ? page.items[$ - 1].id : "";
        return page;
    }

    ExecutionPage paginateExecutions(WorkflowExecution[] items, string marker, int limit) {
        size_t start = findExecutionStartIndex(items, marker);
        ExecutionPage page;
        if (start >= items.length) {
            page.items = [];
            page.hasMore = false;
            page.nextMarker = "";
            return page;
        }

        size_t end = start + cast(size_t) limit;
        if (end > items.length) {
            end = items.length;
        }

        page.items = items[start .. end].dup;
        page.hasMore = end < items.length;
        page.nextMarker = page.hasMore && page.items.length > 0 ? page.items[$ - 1].id : "";
        return page;
    }

    TaskPage paginateTasks(TaskExecution[] items, string marker, int limit) {
        size_t start = findTaskStartIndex(items, marker);
        TaskPage page;
        if (start >= items.length) {
            page.items = [];
            page.hasMore = false;
            page.nextMarker = "";
            return page;
        }

        size_t end = start + cast(size_t) limit;
        if (end > items.length) {
            end = items.length;
        }

        page.items = items[start .. end].dup;
        page.hasMore = end < items.length;
        page.nextMarker = page.hasMore && page.items.length > 0 ? page.items[$ - 1].id : "";
        return page;
    }

    ActionExecutionPage paginateActionExecutions(ActionExecution[] items, string marker, int limit) {
        size_t start = findActionExecutionStartIndex(items, marker);
        ActionExecutionPage page;
        if (start >= items.length) {
            page.items = [];
            page.hasMore = false;
            page.nextMarker = "";
            return page;
        }

        size_t end = start + cast(size_t) limit;
        if (end > items.length) {
            end = items.length;
        }

        page.items = items[start .. end].dup;
        page.hasMore = end < items.length;
        page.nextMarker = page.hasMore && page.items.length > 0 ? page.items[$ - 1].id : "";
        return page;
    }

    size_t findWorkflowStartIndex(WorkflowDefinition[] items, string marker) {
        if (marker.length == 0) {
            return 0;
        }

        foreach (index, item; items) {
            if (item.id == marker) {
                return index + 1;
            }
        }

        return items.length;
    }

    size_t findExecutionStartIndex(WorkflowExecution[] items, string marker) {
        if (marker.length == 0) {
            return 0;
        }

        foreach (index, item; items) {
            if (item.id == marker) {
                return index + 1;
            }
        }

        return items.length;
    }

    size_t findTaskStartIndex(TaskExecution[] items, string marker) {
        if (marker.length == 0) {
            return 0;
        }

        foreach (index, item; items) {
            if (item.id == marker) {
                return index + 1;
            }
        }

        return items.length;
    }

    size_t findActionExecutionStartIndex(ActionExecution[] items, string marker) {
        if (marker.length == 0) {
            return 0;
        }

        foreach (index, item; items) {
            if (item.id == marker) {
                return index + 1;
            }
        }

        return items.length;
    }

    int parseLimit(HTTPServerRequest req, int defaultValue, int maxValue) {
        int value = defaultValue;
        if ("limit" in req.query) {
            const raw = req.query.get("limit", "").to!string;
            if (raw.length > 0) {
                try {
                    value = raw.to!int;
                } catch (Exception) {
                    value = defaultValue;
                }
            }
        }

        if (value <= 0) {
            value = defaultValue;
        }
        if (value > maxValue) {
            value = maxValue;
        }
        return value;
    }

    string[] parseCsvQuery(string value) {
        if (value.strip.length == 0) {
            return [];
        }

        string[] result;
        foreach (part; value.split(",")) {
            const trimmed = part.strip;
            if (trimmed.length > 0) {
                result ~= trimmed;
            }
        }
        return result;
    }

    string buildNextLink(HTTPServerRequest req, string marker, int limit) {
        return baseUrl(req) ~ req.requestPath.to!string ~ "?marker=" ~ marker ~ "&limit=" ~ limit.to!string;
    }

    void getActionExecutionHandler(HTTPServerRequest req, HTTPServerResponse res) {
        setOpenStackHeaders(res);
        const id = wildcardTail(req.requestPath.to!string, "/v2/action_executions/");
        auto actionPtr = useCases.getActionExecution(id);

        if (actionPtr is null) {
            writeNotFound(res, "Action execution not found");
            return;
        }

        Json body;
        body["action_execution"] = toActionExecutionJson(req, *actionPtr);
        writeJson(res, cast(int) HTTPStatus.ok, body);
    }

    void createActionExecutionHandler(HTTPServerRequest req, HTTPServerResponse res) {
        setOpenStackHeaders(res);
        const requestBody = req.json;

        ActionExecutionCommand command;
        if ("name" in requestBody) {
            command.name = requestBody["name"].get!string;
        }
        if ("description" in requestBody) {
            command.description = requestBody["description"].get!string;
        }
        if ("workflow_name" in requestBody) {
            command.workflowName = requestBody["workflow_name"].get!string;
        }
        if ("task_name" in requestBody) {
            command.taskName = requestBody["task_name"].get!string;
        }
        if ("task_execution_id" in requestBody) {
            command.taskExecutionId = requestBody["task_execution_id"].get!string;
        }
        if ("project_id" in requestBody) {
            command.projectId = requestBody["project_id"].get!string;
        }
        if ("input" in requestBody) {
            command.inputJson = requestBody["input"].toString();
        }
        if ("params" in requestBody) {
            command.paramsJson = requestBody["params"].toString();
        }

        const created = useCases.createActionExecution(command);

        Json body;
        body["action_execution"] = toActionExecutionJson(req, created);
        writeJson(res, cast(int) HTTPStatus.created, body);
    }

    Json toWorkflowJson(HTTPServerRequest req, const WorkflowDefinition workflow) {
        Json body;
        body["id"] = Json(workflow.id);
        body["name"] = Json(workflow.name);
        body["namespace"] = Json(workflow.namespace_);
        body["definition"] = Json(workflow.definition);
        body["description"] = Json(workflow.description);
        body["created_at"] = Json(workflow.createdAt);
        body["updated_at"] = Json(workflow.updatedAt);

        Json tags = Json.emptyArray;
        foreach (tag; workflow.tags) {
            tags ~= Json(tag);
        }
        body["tags"] = tags;

        Json links = Json.emptyArray;
        Json selfLink;
        selfLink["rel"] = Json("self");
        selfLink["href"] = Json(baseUrl(req) ~ "/v2/workflows/" ~ workflow.id);
        links ~= selfLink;
        body["links"] = links;

        return body;
    }

    Json toExecutionJson(HTTPServerRequest req, const WorkflowExecution execution) {
        Json body;
        body["id"] = Json(execution.id);
        body["workflow_name"] = Json(execution.workflowName);
        body["workflow_namespace"] = Json(execution.workflowNamespace);
        body["workflow_id"] = Json(execution.workflowId);
        body["description"] = Json(execution.description);
        body["project_id"] = Json(execution.projectId);
        body["state"] = Json(executionStateToString(execution.state));
        body["state_info"] = Json(execution.stateInfo);
        body["input"] = Json(execution.inputJson);
        body["output"] = Json(execution.outputJson);
        body["params"] = Json(execution.paramsJson);
        body["created_at"] = Json(execution.createdAt);
        body["updated_at"] = Json(execution.updatedAt);

        Json tags = Json.emptyArray;
        foreach (tag; execution.tags) {
            tags ~= Json(tag);
        }
        body["tags"] = tags;

        Json links = Json.emptyArray;
        Json selfLink;
        selfLink["rel"] = Json("self");
        selfLink["href"] = Json(baseUrl(req) ~ "/v2/executions/" ~ execution.id);
        links ~= selfLink;
        body["links"] = links;

        return body;
    }

    Json toTaskJson(HTTPServerRequest req, const TaskExecution task) {
        Json body;
        body["id"] = Json(task.id);
        body["name"] = Json(task.name);
        body["workflow_name"] = Json(task.workflowName);
        body["workflow_id"] = Json(task.workflowId);
        body["workflow_execution_id"] = Json(task.workflowExecutionId);
        body["state"] = Json(executionStateToString(task.state));
        body["state_info"] = Json(task.stateInfo);
        body["result"] = Json(task.resultJson);
        body["published"] = Json(task.publishedJson);
        body["processed"] = Json(task.processed);
        body["reset"] = Json(task.reset);
        body["created_at"] = Json(task.createdAt);
        body["updated_at"] = Json(task.updatedAt);

        Json links = Json.emptyArray;
        Json selfLink;
        selfLink["rel"] = Json("self");
        selfLink["href"] = Json(baseUrl(req) ~ "/v2/tasks/" ~ task.id);
        links ~= selfLink;
        body["links"] = links;

        return body;
    }

    Json toActionExecutionJson(HTTPServerRequest req, const ActionExecution actionExecution) {
        Json body;
        body["id"] = Json(actionExecution.id);
        body["name"] = Json(actionExecution.name);
        body["description"] = Json(actionExecution.description);
        body["workflow_name"] = Json(actionExecution.workflowName);
        body["task_name"] = Json(actionExecution.taskName);
        body["task_execution_id"] = Json(actionExecution.taskExecutionId);
        body["project_id"] = Json(actionExecution.projectId);
        body["state"] = Json(executionStateToString(actionExecution.state));
        body["state_info"] = Json(actionExecution.stateInfo);
        body["accepted"] = Json(actionExecution.accepted);
        body["input"] = Json(actionExecution.inputJson);
        body["output"] = Json(actionExecution.outputJson);
        body["params"] = Json(actionExecution.paramsJson);
        body["created_at"] = Json(actionExecution.createdAt);
        body["updated_at"] = Json(actionExecution.updatedAt);

        Json links = Json.emptyArray;
        Json selfLink;
        selfLink["rel"] = Json("self");
        selfLink["href"] = Json(baseUrl(req) ~ "/v2/action_executions/" ~ actionExecution.id);
        links ~= selfLink;
        body["links"] = links;

        return body;
    }

    string inferWorkflowName(string definition) {
        foreach (line; definition.splitLines()) {
            auto trimmed = line.strip;
            if (trimmed.length == 0 || trimmed[0] == '#') {
                continue;
            }
            if (trimmed.indexOf(":") >= 0) {
                return trimmed.split(":")[0].strip;
            }
        }
        return "workflow-" ~ randomUUID().toString();
    }

    string wildcardTail(string requestPath, string prefix) {
        if (requestPath.length <= prefix.length) {
            return "";
        }
        return requestPath[prefix.length .. $].strip;
    }

    string baseUrl(HTTPServerRequest req) {
        return "http://" ~ req.headers.get("Host", "localhost").to!string;
    }

    void setOpenStackHeaders(HTTPServerResponse res) {
        res.headers["X-Openstack-Request-Id"] = "req-" ~ randomUUID().toString();
        res.headers["OpenStack-API-Version"] = "workflow 2.0";
        res.headers["Content-Type"] = "application/json";
    }

    void writeNotFound(HTTPServerResponse res, string message) {
        Json body;
        body["message"] = Json(message);
        body["type"] = Json("NotFoundException");
        writeJson(res, cast(int) HTTPStatus.notFound, body);
    }

    void writeJson(HTTPServerResponse res, int status, Json body) {
        res.statusCode = status;
        res.writeBody(body.toString(), status, "application/json");
    }
}
