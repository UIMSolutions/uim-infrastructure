module uim.infrastructure.mistral.domain.entities.action_execution;

import uim.infrastructure.mistral.domain.entities.execution : ExecutionState;

struct ActionExecution {
    string id;
    string workflowName;
    string taskName;
    string taskExecutionId;
    string name;
    string description;
    string projectId;
    ExecutionState state;
    string stateInfo;
    bool accepted;
    string inputJson;
    string outputJson;
    string paramsJson;
    string createdAt;
    string updatedAt;
}
