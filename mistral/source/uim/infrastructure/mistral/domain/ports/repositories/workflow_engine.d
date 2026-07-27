/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.infrastructure.mistral.domain.ports.repositories.workflow_engine;

import uim.infrastructure.mistral.domain.entities.workflow : WorkflowDefinition;
import uim.infrastructure.mistral.domain.entities.execution : WorkflowExecution;
import uim.infrastructure.mistral.domain.entities.task : TaskExecution;
import uim.infrastructure.mistral.domain.entities.action_execution : ActionExecution;

interface IWorkflowEngineRepository {
    WorkflowDefinition[] listWorkflows();
    WorkflowDefinition* getWorkflow(string idOrName, string namespace_ = "");
    WorkflowDefinition createWorkflow(string name, string namespace_, string definition, string description, string[] tags);
    WorkflowDefinition* updateWorkflow(string idOrName, string namespace_, string name, string definition, string description, string[] tags, bool updateName, bool updateDefinition, bool updateDescription, bool updateTags);
    bool deleteWorkflow(string idOrName, string namespace_ = "");

    WorkflowExecution[] listExecutions();
    WorkflowExecution* getExecution(string id);
    WorkflowExecution createExecution(string workflowIdentifier, string workflowNamespace, string inputJson, string description, string[] tags, string projectId);
    bool deleteExecution(string id, bool force);

    TaskExecution[] listTasks(string workflowExecutionId = "");
    TaskExecution* getTask(string id);

    ActionExecution[] listActionExecutions(string taskExecutionId = "");
    ActionExecution* getActionExecution(string id);
    ActionExecution createActionExecution(string name, string description, string inputJson, string paramsJson, string workflowName, string taskName, string taskExecutionId, string projectId);
}
