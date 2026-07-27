/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.infrastructure.waf.application.dto.commands;

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
