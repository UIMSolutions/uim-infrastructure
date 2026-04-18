module app;

import waf_service.application.use_cases.create_rule : CreateRuleUseCase;
import waf_service.application.use_cases.list_rules : ListRulesUseCase;
import waf_service.application.use_cases.get_rule : GetRuleUseCase;
import waf_service.application.use_cases.delete_rule : DeleteRuleUseCase;
import waf_service.application.use_cases.create_policy : CreatePolicyUseCase;
import waf_service.application.use_cases.list_policies : ListPoliciesUseCase;
import waf_service.application.use_cases.get_policy : GetPolicyUseCase;
import waf_service.application.use_cases.delete_policy : DeletePolicyUseCase;
import waf_service.application.use_cases.evaluate_request : EvaluateRequestUseCase;
import waf_service.application.use_cases.list_events : ListEventsUseCase;
import waf_service.infrastructure.http.waf_controller : WafController;
import waf_service.infrastructure.persistence.in_memory_rule_repository : InMemoryRuleRepository;
import waf_service.infrastructure.persistence.in_memory_policy_repository : InMemoryPolicyRepository;
import waf_service.infrastructure.persistence.in_memory_event_repository : InMemoryEventRepository;
import std.conv : to;
import std.exception : collectException;
import std.string : fromStringz;
import core.stdc.stdlib : getenv;
import vibe.vibe;

void main() {
    auto settings = new HTTPServerSettings;
    settings.port = readPort();
    settings.bindAddresses = [readBindAddress()];

    // --- Outbound adapters (repositories) ---
    auto ruleRepo = new InMemoryRuleRepository();
    auto policyRepo = new InMemoryPolicyRepository();
    auto eventRepo = new InMemoryEventRepository();

    // --- Use cases ---
    auto createRuleUC = new CreateRuleUseCase(ruleRepo);
    auto listRulesUC = new ListRulesUseCase(ruleRepo);
    auto getRuleUC = new GetRuleUseCase(ruleRepo);
    auto deleteRuleUC = new DeleteRuleUseCase(ruleRepo);
    auto createPolicyUC = new CreatePolicyUseCase(policyRepo);
    auto listPoliciesUC = new ListPoliciesUseCase(policyRepo);
    auto getPolicyUC = new GetPolicyUseCase(policyRepo);
    auto deletePolicyUC = new DeletePolicyUseCase(policyRepo);
    auto evaluateUC = new EvaluateRequestUseCase(ruleRepo, policyRepo, eventRepo);
    auto listEventsUC = new ListEventsUseCase(eventRepo);

    // --- Inbound adapter (HTTP controller) ---
    auto controller = new WafController(
        createRuleUC, listRulesUC, getRuleUC, deleteRuleUC,
        createPolicyUC, listPoliciesUC, getPolicyUC, deletePolicyUC,
        evaluateUC, listEventsUC
    );

    auto router = new URLRouter;
    controller.registerRoutes(router);

    logInfo("WAF service starting on %s:%d", settings.bindAddresses[0], settings.port);
    listenHTTP(settings, router);
    runApplication();
}

private ushort readPort() {
    auto raw = getenv("PORT");
    if (raw is null) {
        return 8080;
    }

    ushort parsed;
    auto err = collectException(parsed = fromStringz(raw).to!ushort);
    return err is null ? parsed : cast(ushort) 8080;
}

private string readBindAddress() {
    auto raw = getenv("BIND_ADDRESS");
    return raw is null ? "0.0.0.0".idup : fromStringz(raw).idup;
}
