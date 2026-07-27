/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.infrastructure.mistral.application.dto.mistral_command;

struct WorkflowCommand {
    string name;
    string namespace_;
    string definition;
    string description;
    string[] tags;
}

struct UpdateWorkflowCommand {
    string name;
    string definition;
    string description;
    string[] tags;
    bool updateName;
    bool updateDefinition;
    bool updateDescription;
    bool updateTags;
}

struct ExecutionCommand {
    string workflowIdentifier;
    string workflowNamespace;
    string inputJson;
    string description;
    string[] tags;
    string projectId;
}

struct ActionExecutionCommand {
    string name;
    string description;
    string inputJson;
    string paramsJson;
    string workflowName;
    string taskName;
    string taskExecutionId;
    string projectId;
}
