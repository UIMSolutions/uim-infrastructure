module uim.infrastructure.waf.infrastructure.http.controllers.waf;

import uim.infrastructure.waf.application.dto.commands : CreateRuleCommand, CreatePolicyCommand, EvaluateRequestCommand;
import uim.infrastructure.waf.application.use_cases.create_rule : CreateRuleUseCase;
import uim.infrastructure.waf.application.use_cases.list_rules : ListRulesUseCase;
import uim.infrastructure.waf.application.use_cases.get_rule : GetRuleUseCase;
import uim.infrastructure.waf.application.use_cases.delete_rule : DeleteRuleUseCase;
import uim.infrastructure.waf.application.use_cases.create_policy : CreatePolicyUseCase;
import uim.infrastructure.waf.application.use_cases.list_policies : ListPoliciesUseCase;
import uim.infrastructure.waf.application.use_cases.get_policy : GetPolicyUseCase;
import uim.infrastructure.waf.application.use_cases.delete_policy : DeletePolicyUseCase;
import uim.infrastructure.waf.application.use_cases.evaluate_request : EvaluateRequestUseCase, EvaluationResult;
import uim.infrastructure.waf.application.use_cases.list_events : ListEventsUseCase;
import uim.infrastructure.waf.domain.entities.waf_rule : WafRule;
import uim.infrastructure.waf.domain.entities.waf_policy : WafPolicy;
import uim.infrastructure.waf.domain.entities.waf_event : WafEvent;
import std.conv : to;
import std.string : split, startsWith;
import vibe.http.router : URLRouter;
import vibe.http.server : HTTPServerRequest, HTTPServerResponse;
import vibe.http.common : HTTPStatus;
import vibe.data.json : Json, serializeToJsonString;

// --- View structs for serialization ---

struct RuleView {
    string id;
    string name;
    string pattern;
    string action;
    string ruleType;
    uint priority;
    bool enabled;
    string description;
}

struct PolicyView {
    string id;
    string name;
    string[] ruleIds;
    string mode;
    string description;
}

struct EventView {
    string id;
    string ruleId;
    string ruleName;
    string sourceIp;
    string requestMethod;
    string requestPath;
    string action;
    string matchedPattern;
    string details;
    string timestamp;
}

struct EvaluationResultView {
    bool allowed;
    string ruleId;
    string ruleName;
    string action;
    string matchedPattern;
    uint eventsGenerated;
}

class WafController {
    private CreateRuleUseCase createRuleUC;
    private ListRulesUseCase listRulesUC;
    private GetRuleUseCase getRuleUC;
    private DeleteRuleUseCase deleteRuleUC;
    private CreatePolicyUseCase createPolicyUC;
    private ListPoliciesUseCase listPoliciesUC;
    private GetPolicyUseCase getPolicyUC;
    private DeletePolicyUseCase deletePolicyUC;
    private EvaluateRequestUseCase evaluateUC;
    private ListEventsUseCase listEventsUC;

    this(
        CreateRuleUseCase createRuleUC,
        ListRulesUseCase listRulesUC,
        GetRuleUseCase getRuleUC,
        DeleteRuleUseCase deleteRuleUC,
        CreatePolicyUseCase createPolicyUC,
        ListPoliciesUseCase listPoliciesUC,
        GetPolicyUseCase getPolicyUC,
        DeletePolicyUseCase deletePolicyUC,
        EvaluateRequestUseCase evaluateUC,
        ListEventsUseCase listEventsUC
    ) {
        this.createRuleUC = createRuleUC;
        this.listRulesUC = listRulesUC;
        this.getRuleUC = getRuleUC;
        this.deleteRuleUC = deleteRuleUC;
        this.createPolicyUC = createPolicyUC;
        this.listPoliciesUC = listPoliciesUC;
        this.getPolicyUC = getPolicyUC;
        this.deletePolicyUC = deletePolicyUC;
        this.evaluateUC = evaluateUC;
        this.listEventsUC = listEventsUC;
    }

    void registerRoutes(URLRouter router) {
        // Health
        router.get("/health", &health);

        // Rules
        router.get("/v1/rules", &listRules);
        router.post("/v1/rules", &createRule);
        router.get("/v1/rules/*", &getRule);
        router.delete_("/v1/rules/*", &deleteRule);

        // Policies
        router.get("/v1/policies", &listPolicies);
        router.post("/v1/policies", &createPolicy);
        router.get("/v1/policies/*", &getPolicy);
        router.delete_("/v1/policies/*", &deletePolicy);

        // Evaluate
        router.post("/v1/evaluate", &evaluateRequest);

        // Events
        router.get("/v1/events", &listEvents);
    }

    // --- Health ---

    void health(HTTPServerRequest req, HTTPServerResponse res) {
        writeJson(res, `{ "status": "ok", "service": "uim-waf-service" }`, HTTPStatus.ok);
    }

    // --- Rules ---

    void listRules(HTTPServerRequest req, HTTPServerResponse res) {
        auto rules = listRulesUC.execute();
        writeJson(res, serializeToJsonString(rulesToViews(rules)), HTTPStatus.ok);
    }

    void createRule(HTTPServerRequest req, HTTPServerResponse res) {
        try {
            auto json = req.json;
            auto command = CreateRuleCommand(
                json["name"].get!string,
                json["pattern"].get!string,
                json["action"].get!string,
                json["ruleType"].get!string,
                json["priority"].get!uint,
                json["description"].get!string
            );
            auto created = createRuleUC.execute(command);
            writeJson(res, serializeToJsonString(ruleToView(created)), HTTPStatus.created);
        } catch (Exception ex) {
            writeJson(res, `{ "error": "` ~ ex.msg ~ `" }`, HTTPStatus.badRequest);
        }
    }

    void getRule(HTTPServerRequest req, HTTPServerResponse res) {
        auto id = extractIdFromPath(req.requestPath.to!string, "/v1/rules/");
        if (id.length == 0) {
            writeJson(res, `{ "error": "missing rule id" }`, HTTPStatus.badRequest);
            return;
        }

        try {
            auto rulePtr = getRuleUC.execute(id);
            if (rulePtr is null) {
                writeJson(res, `{ "error": "rule not found" }`, HTTPStatus.notFound);
                return;
            }
            writeJson(res, serializeToJsonString(ruleToView(*rulePtr)), HTTPStatus.ok);
        } catch (Exception ex) {
            writeJson(res, `{ "error": "` ~ ex.msg ~ `" }`, HTTPStatus.badRequest);
        }
    }

    void deleteRule(HTTPServerRequest req, HTTPServerResponse res) {
        auto id = extractIdFromPath(req.requestPath.to!string, "/v1/rules/");
        if (id.length == 0) {
            writeJson(res, `{ "error": "missing rule id" }`, HTTPStatus.badRequest);
            return;
        }

        try {
            deleteRuleUC.execute(id);
            writeJson(res, `{ "status": "deleted" }`, HTTPStatus.ok);
        } catch (Exception ex) {
            writeJson(res, `{ "error": "` ~ ex.msg ~ `" }`, HTTPStatus.badRequest);
        }
    }

    // --- Policies ---

    void listPolicies(HTTPServerRequest req, HTTPServerResponse res) {
        auto policies = listPoliciesUC.execute();
        writeJson(res, serializeToJsonString(policiesToViews(policies)), HTTPStatus.ok);
    }

    void createPolicy(HTTPServerRequest req, HTTPServerResponse res) {
        try {
            auto json = req.json;

            string[] ruleIds;
            foreach (item; json["ruleIds"]) {
                ruleIds ~= item.get!string;
            }

            auto command = CreatePolicyCommand(
                json["name"].get!string,
                ruleIds,
                json["mode"].get!string,
                json["description"].get!string
            );
            auto created = createPolicyUC.execute(command);
            writeJson(res, serializeToJsonString(policyToView(created)), HTTPStatus.created);
        } catch (Exception ex) {
            writeJson(res, `{ "error": "` ~ ex.msg ~ `" }`, HTTPStatus.badRequest);
        }
    }

    void getPolicy(HTTPServerRequest req, HTTPServerResponse res) {
        auto id = extractIdFromPath(req.requestPath.to!string, "/v1/policies/");
        if (id.length == 0) {
            writeJson(res, `{ "error": "missing policy id" }`, HTTPStatus.badRequest);
            return;
        }

        try {
            auto policyPtr = getPolicyUC.execute(id);
            if (policyPtr is null) {
                writeJson(res, `{ "error": "policy not found" }`, HTTPStatus.notFound);
                return;
            }
            writeJson(res, serializeToJsonString(policyToView(*policyPtr)), HTTPStatus.ok);
        } catch (Exception ex) {
            writeJson(res, `{ "error": "` ~ ex.msg ~ `" }`, HTTPStatus.badRequest);
        }
    }

    void deletePolicy(HTTPServerRequest req, HTTPServerResponse res) {
        auto id = extractIdFromPath(req.requestPath.to!string, "/v1/policies/");
        if (id.length == 0) {
            writeJson(res, `{ "error": "missing policy id" }`, HTTPStatus.badRequest);
            return;
        }

        try {
            deletePolicyUC.execute(id);
            writeJson(res, `{ "status": "deleted" }`, HTTPStatus.ok);
        } catch (Exception ex) {
            writeJson(res, `{ "error": "` ~ ex.msg ~ `" }`, HTTPStatus.badRequest);
        }
    }

    // --- Evaluate ---

    void evaluateRequest(HTTPServerRequest req, HTTPServerResponse res) {
        try {
            auto json = req.json;

            string[string] headers;
            if ("headers" in json) {
                foreach (string key, value; json["headers"]) {
                    headers[key] = value.get!string;
                }
            }

            auto command = EvaluateRequestCommand(
                json["policyId"].get!string,
                json["sourceIp"].get!string,
                json["requestMethod"].get!string,
                json["requestPath"].get!string,
                ("requestBody" in json) ? json["requestBody"].get!string : "",
                headers
            );

            auto result = evaluateUC.execute(command);
            auto view = EvaluationResultView(
                result.allowed,
                result.ruleId,
                result.ruleName,
                result.action.to!string,
                result.matchedPattern,
                cast(uint) result.events.length
            );
            auto status = result.allowed ? HTTPStatus.ok : HTTPStatus.forbidden;
            writeJson(res, serializeToJsonString(view), status);
        } catch (Exception ex) {
            writeJson(res, `{ "error": "` ~ ex.msg ~ `" }`, HTTPStatus.badRequest);
        }
    }

    // --- Events ---

    void listEvents(HTTPServerRequest req, HTTPServerResponse res) {
        auto events = listEventsUC.execute();
        writeJson(res, serializeToJsonString(eventsToViews(events)), HTTPStatus.ok);
    }

    // --- Helpers ---

    private string extractIdFromPath(string requestPath, string prefix) {
        if (!requestPath.startsWith(prefix))
            return "";
        return requestPath[prefix.length .. $];
    }

    private RuleView ruleToView(in WafRule rule) {
        return RuleView(rule.id, rule.name, rule.pattern, rule.action.to!string, rule.ruleType.to!string, rule.priority, rule.enabled, rule.description);
    }

    private RuleView[] rulesToViews(scope const WafRule[] rules) {
        RuleView[] views;
        foreach (rule; rules)
            views ~= ruleToView(rule);
        return views;
    }

    private PolicyView policyToView(in WafPolicy policy) {
        return PolicyView(policy.id, policy.name, policy.ruleIds.dup, policy.mode.to!string, policy.description);
    }

    private PolicyView[] policiesToViews(scope const WafPolicy[] policies) {
        PolicyView[] views;
        foreach (policy; policies)
            views ~= policyToView(policy);
        return views;
    }

    private EventView eventToView(in WafEvent event) {
        return EventView(event.id, event.ruleId, event.ruleName, event.sourceIp, event.requestMethod, event.requestPath, event.action.to!string, event.matchedPattern, event.details, event.timestamp);
    }

    private EventView[] eventsToViews(scope const WafEvent[] events) {
        EventView[] views;
        foreach (event; events)
            views ~= eventToView(event);
        return views;
    }

    private void writeJson(HTTPServerResponse res, string body, HTTPStatus status) {
        res.writeBody(body, cast(int) status, "application/json");
    }
}
