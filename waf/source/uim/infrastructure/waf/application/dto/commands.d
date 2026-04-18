module waf_service.application.dto.commands;

struct CreateRuleCommand {
    string name;
    string pattern;
    string action;
    string ruleType;
    uint priority;
    string description;
}

struct CreatePolicyCommand {
    string name;
    string[] ruleIds;
    string mode;
    string description;
}

struct EvaluateRequestCommand {
    string policyId;
    string sourceIp;
    string requestMethod;
    string requestPath;
    string requestBody;
    string[string] headers;
}
