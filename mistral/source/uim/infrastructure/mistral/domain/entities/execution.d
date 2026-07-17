module uim.infrastructure.mistral.domain.entities.execution;

enum ExecutionState {
    idle,
    running,
    success,
    error,
    paused
}

string executionStateToString(ExecutionState value) {
    final switch (value) {
        case ExecutionState.idle:
            return "IDLE";
        case ExecutionState.running:
            return "RUNNING";
        case ExecutionState.success:
            return "SUCCESS";
        case ExecutionState.error:
            return "ERROR";
        case ExecutionState.paused:
            return "PAUSED";
    }
}

struct WorkflowExecution {
    string id;
    string workflowName;
    string workflowNamespace;
    string workflowId;
    string description;
    string[] tags;
    string projectId;
    ExecutionState state;
    string stateInfo;
    string inputJson;
    string outputJson;
    string paramsJson;
    string createdAt;
    string updatedAt;
}
