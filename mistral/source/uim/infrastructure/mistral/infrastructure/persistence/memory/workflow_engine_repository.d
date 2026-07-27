/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.infrastructure.mistral.infrastructure.persistence.memory.workflow_engine_repository;

import std.algorithm.searching : canFind;
import std.algorithm.iteration : filter;
import std.array : array;
import std.conv : to;
import std.datetime.systime : Clock;
import std.random : uniform;
import std.string : format;
import std.uuid : randomUUID;

import uim.infrastructure.mistral.domain.entities.workflow : WorkflowDefinition;
import uim.infrastructure.mistral.domain.entities.execution : WorkflowExecution, ExecutionState;
import uim.infrastructure.mistral.domain.entities.task : TaskExecution;
import uim.infrastructure.mistral.domain.entities.action_execution : ActionExecution;
import uim.infrastructure.mistral.domain.ports.repositories.workflow_engine : IWorkflowEngineRepository;

class InMemoryWorkflowEngineRepository : IWorkflowEngineRepository {
private:
    WorkflowDefinition[] workflows;
    WorkflowExecution[] executions;
    TaskExecution[] tasks;
    ActionExecution[] actionExecutions;

public:
    this() {
        seedData();
    }

    override WorkflowDefinition[] listWorkflows() {
        return workflows.dup;
    }

    override WorkflowDefinition* getWorkflow(string idOrName, string namespace_ = "") {
        foreach (ref workflow; workflows) {
            const namespaceMatch = namespace_.length == 0 || workflow.namespace_ == namespace_;
            if ((workflow.id == idOrName || workflow.name == idOrName) && namespaceMatch) {
                return &workflow;
            }
        }
        return null;
    }

    override WorkflowDefinition createWorkflow(string name, string namespace_, string definition, string description, string[] tags) {
        const ts = Clock.currTime().toISOExtString();
        WorkflowDefinition workflow;
        workflow.id = "wf-" ~ randomUUID().toString();
        workflow.name = name.length == 0 ? "workflow-" ~ uniform(1000, 9999).to!string : name;
        workflow.namespace_ = namespace_.length == 0 ? "" : namespace_;
        workflow.definition = definition;
        workflow.description = description;
        workflow.tags = tags.dup;
        workflow.createdAt = ts;
        workflow.updatedAt = ts;

        workflows ~= workflow;
        return workflow;
    }

    override WorkflowDefinition* updateWorkflow(string idOrName, string namespace_, string name, string definition, string description, string[] tags, bool updateName, bool updateDefinition, bool updateDescription, bool updateTags) {
        foreach (ref workflow; workflows) {
            const namespaceMatch = namespace_.length == 0 || workflow.namespace_ == namespace_;
            if ((workflow.id == idOrName || workflow.name == idOrName) && namespaceMatch) {
                if (updateName) {
                    workflow.name = name;
                }
                if (updateDefinition) {
                    workflow.definition = definition;
                }
                if (updateDescription) {
                    workflow.description = description;
                }
                if (updateTags) {
                    workflow.tags = tags.dup;
                }
                workflow.updatedAt = Clock.currTime().toISOExtString();
                return &workflow;
            }
        }

        return null;
    }

    override bool deleteWorkflow(string idOrName, string namespace_ = "") {
        foreach (index, workflow; workflows) {
            const namespaceMatch = namespace_.length == 0 || workflow.namespace_ == namespace_;
            if ((workflow.id == idOrName || workflow.name == idOrName) && namespaceMatch) {
                workflows = workflows[0 .. index] ~ workflows[index + 1 .. $];
                return true;
            }
        }
        return false;
    }

    override WorkflowExecution[] listExecutions() {
        return executions.dup;
    }

    override WorkflowExecution* getExecution(string id) {
        foreach (ref execution; executions) {
            if (execution.id == id) {
                return &execution;
            }
        }
        return null;
    }

    override WorkflowExecution createExecution(string workflowIdentifier, string workflowNamespace, string inputJson, string description, string[] tags, string projectId) {
        const workflowPtr = getWorkflow(workflowIdentifier, workflowNamespace);
        const ts = Clock.currTime().toISOExtString();

        WorkflowExecution execution;
        execution.id = "ex-" ~ randomUUID().toString();
        execution.workflowName = workflowPtr !is null ? workflowPtr.name : workflowIdentifier;
        execution.workflowNamespace = workflowPtr !is null ? workflowPtr.namespace_ : workflowNamespace;
        execution.workflowId = workflowPtr !is null ? workflowPtr.id : "";
        execution.description = description;
        execution.tags = tags.dup;
        execution.projectId = projectId.length == 0 ? "default" : projectId;
        execution.state = ExecutionState.running;
        execution.stateInfo = "Execution accepted";
        execution.inputJson = inputJson.length == 0 ? "{}" : inputJson;
        execution.outputJson = "{}";
        execution.paramsJson = "{}";
        execution.createdAt = ts;
        execution.updatedAt = ts;

        executions ~= execution;
        createSyntheticTaskAndAction(execution);
        return execution;
    }

    override bool deleteExecution(string id, bool force) {
        foreach (index, execution; executions) {
            if (execution.id == id) {
                if (!force && execution.state == ExecutionState.running) {
                    return false;
                }

                string[] deletedTaskIds;
                foreach (task; tasks) {
                    if (task.workflowExecutionId == id) {
                        deletedTaskIds ~= task.id;
                    }
                }

                executions = executions[0 .. index] ~ executions[index + 1 .. $];
                tasks = tasks
                    .filter!(task => task.workflowExecutionId != id)
                    .array;
                actionExecutions = actionExecutions
                    .filter!(action => !deletedTaskIds.canFind(action.taskExecutionId))
                    .array;
                return true;
            }
        }
        return false;
    }

    override TaskExecution[] listTasks(string workflowExecutionId = "") {
        if (workflowExecutionId.length == 0) {
            return tasks.dup;
        }

        TaskExecution[] filtered;
        foreach (task; tasks) {
            if (task.workflowExecutionId == workflowExecutionId) {
                filtered ~= task;
            }
        }
        return filtered;
    }

    override TaskExecution* getTask(string id) {
        foreach (ref task; tasks) {
            if (task.id == id) {
                return &task;
            }
        }
        return null;
    }

    override ActionExecution[] listActionExecutions(string taskExecutionId = "") {
        if (taskExecutionId.length == 0) {
            return actionExecutions.dup;
        }

        ActionExecution[] filtered;
        foreach (execution; actionExecutions) {
            if (execution.taskExecutionId == taskExecutionId) {
                filtered ~= execution;
            }
        }
        return filtered;
    }

    override ActionExecution* getActionExecution(string id) {
        foreach (ref actionExecution; actionExecutions) {
            if (actionExecution.id == id) {
                return &actionExecution;
            }
        }
        return null;
    }

    override ActionExecution createActionExecution(string name, string description, string inputJson, string paramsJson, string workflowName, string taskName, string taskExecutionId, string projectId) {
        const ts = Clock.currTime().toISOExtString();

        ActionExecution actionExecution;
        actionExecution.id = "acex-" ~ randomUUID().toString();
        actionExecution.workflowName = workflowName;
        actionExecution.taskName = taskName;
        actionExecution.taskExecutionId = taskExecutionId;
        actionExecution.name = name.length == 0 ? "std.echo" : name;
        actionExecution.description = description;
        actionExecution.projectId = projectId.length == 0 ? "default" : projectId;
        actionExecution.state = ExecutionState.running;
        actionExecution.stateInfo = "Action accepted";
        actionExecution.accepted = true;
        actionExecution.inputJson = inputJson.length == 0 ? "{}" : inputJson;
        actionExecution.outputJson = "{}";
        actionExecution.paramsJson = paramsJson.length == 0 ? "{}" : paramsJson;
        actionExecution.createdAt = ts;
        actionExecution.updatedAt = ts;

        actionExecutions ~= actionExecution;
        return actionExecution;
    }

private:
    void seedData() {
        const defaultDefinition = "version: '2.0'\nhello_world:\n  type: direct\n  tasks:\n    greet:\n      action: std.echo output='Hello, World!'";
        const workflow = createWorkflow(
            "hello_world",
            "",
            defaultDefinition,
            "Simple seeded workflow",
            ["demo"]
        );

        const execution = createExecution(
            workflow.id,
            workflow.namespace_,
            "{\"name\":\"demo\"}",
            "Seeded execution",
            ["demo"],
            "default"
        );

        foreach (ref item; executions) {
            if (item.id == execution.id) {
                item.state = ExecutionState.success;
                item.stateInfo = "Execution finished";
                item.outputJson = "{\"result\":\"ok\"}";
                item.updatedAt = Clock.currTime().toISOExtString();
            }
        }

        foreach (ref item; tasks) {
            if (item.workflowExecutionId == execution.id) {
                item.state = ExecutionState.success;
                item.stateInfo = "Task finished";
                item.resultJson = "{\"result\":\"ok\"}";
                item.updatedAt = Clock.currTime().toISOExtString();
            }
        }

        foreach (ref item; actionExecutions) {
            if (item.workflowName == execution.workflowName) {
                item.state = ExecutionState.success;
                item.stateInfo = "Action finished";
                item.outputJson = "{\"output\":\"Hello, World!\"}";
                item.updatedAt = Clock.currTime().toISOExtString();
            }
        }
    }

    void createSyntheticTaskAndAction(WorkflowExecution execution) {
        const ts = Clock.currTime().toISOExtString();

        TaskExecution task;
        task.id = "task-" ~ randomUUID().toString();
        task.workflowName = execution.workflowName;
        task.workflowId = execution.workflowId;
        task.workflowExecutionId = execution.id;
        task.name = "main";
        task.state = ExecutionState.running;
        task.stateInfo = "Task accepted";
        task.resultJson = "{}";
        task.publishedJson = "{}";
        task.processed = false;
        task.reset = false;
        task.createdAt = ts;
        task.updatedAt = ts;

        tasks ~= task;

        ActionExecution action;
        action.id = "acex-" ~ randomUUID().toString();
        action.workflowName = execution.workflowName;
        action.taskName = task.name;
        action.taskExecutionId = task.id;
        action.name = "std.echo";
        action.description = "Synthetic action execution";
        action.projectId = execution.projectId;
        action.state = ExecutionState.running;
        action.stateInfo = "Action accepted";
        action.accepted = true;
        action.inputJson = execution.inputJson;
        action.outputJson = "{}";
        action.paramsJson = execution.paramsJson;
        action.createdAt = ts;
        action.updatedAt = ts;

        actionExecutions ~= action;
    }
}
