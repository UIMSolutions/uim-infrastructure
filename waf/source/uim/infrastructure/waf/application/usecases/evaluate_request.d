module uim.infrastructure.waf.application.usecases.evaluate_request;

import std.conv : to;
import std.datetime : Clock;
import std.digest : toHexString;
import std.digest.sha : sha256Of;
import std.regex : regex, matchFirst;
import std.string : toLower, indexOf;
import uim.infrastructure.waf.application.dto.commands : EvaluateRequestCommand;
import uim.infrastructure.waf.domain.entities.waf_event : WafEvent;
import uim.infrastructure.waf.domain.entities.waf_policy : WafPolicy, PolicyMode;
import uim.infrastructure.waf.domain.entities.waf_rule : WafRule, RuleAction;
import uim.infrastructure.waf.domain.ports.repositories.waf_event : IWafEventRepository;
import uim.infrastructure.waf.domain.ports.repositories.waf_policy : IWafPolicyRepository;
import uim.infrastructure.waf.domain.ports.repositories.waf_rule : IWafRuleRepository;

struct EvaluationResult {
    bool allowed;
    string ruleId;
    string ruleName;
    RuleAction action;
    string matchedPattern;
    WafEvent[] events;
}

class EvaluateRequestUseCase {
    private IWafRuleRepository ruleRepo;
    private IWafPolicyRepository policyRepo;
    private IWafEventRepository eventRepo;

    this(IWafRuleRepository ruleRepo, IWafPolicyRepository policyRepo, IWafEventRepository eventRepo) {
        this.ruleRepo = ruleRepo;
        this.policyRepo = policyRepo;
        this.eventRepo = eventRepo;
    }

    EvaluationResult execute(in EvaluateRequestCommand command) {
        if (command.policyId.length == 0)
            throw new Exception("policyId must not be empty");

        auto policyPtr = policyRepo.findById(command.policyId);
        if (policyPtr is null)
            throw new Exception("policy not found: " ~ command.policyId);

        auto policy = *policyPtr;
        auto inspectTarget = buildInspectTarget(command);

        EvaluationResult result;
        result.allowed = true;

        foreach (ruleId; policy.ruleIds) {
            auto rulePtr = ruleRepo.findById(ruleId);
            if (rulePtr is null) continue;

            auto rule = *rulePtr;
            if (!rule.enabled) continue;

            if (matchesRule(rule, inspectTarget)) {
                auto event = createEvent(command, rule);
                eventRepo.save(event);
                result.events ~= event;

                if (rule.action == RuleAction.BLOCK || rule.action == RuleAction.CHALLENGE) {
                    if (policy.mode == PolicyMode.PREVENTION) {
                        result.allowed = false;
                        result.ruleId = rule.id;
                        result.ruleName = rule.name;
                        result.action = rule.action;
                        result.matchedPattern = rule.pattern;
                        return result;
                    }
                }
            }
        }

        return result;
    }

    private bool matchesRule(in WafRule rule, string target) {
        try {
            auto re = regex(rule.pattern, "i");
            auto m = matchFirst(target, re);
            return !m.empty;
        } catch (Exception) {
            return target.toLower().indexOf(rule.pattern.toLower()) != -1;
        }
    }

    private string buildInspectTarget(in EvaluateRequestCommand command) {
        return command.requestMethod ~ " " ~ command.requestPath ~ " " ~ command.requestBody;
    }

    private WafEvent createEvent(in EvaluateRequestCommand command, in WafRule rule) {
        auto ts = Clock.currTime.toISOExtString();
        auto id = generateId(rule.id ~ command.sourceIp ~ ts);
        return WafEvent(
            id,
            rule.id,
            rule.name,
            command.sourceIp,
            command.requestMethod,
            command.requestPath,
            rule.action,
            rule.pattern,
            rule.description,
            ts
        );
    }

    private string generateId(string seed) {
        auto hash = sha256Of(seed);
        return toHexString(hash[0 .. 8]).idup;
    }
}
