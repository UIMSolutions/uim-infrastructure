module waf_service.application.use_cases.create_rule;

import std.conv : to;
import std.digest : toHexString;
import std.digest.sha : sha256Of;
import std.datetime : Clock;
import waf_service.application.dto.commands : CreateRuleCommand;
import waf_service.domain.entities.waf_rule : WafRule, parseRuleType, parseRuleAction;
import waf_service.domain.ports.repositories.waf_rule : IWafRuleRepository;

class CreateRuleUseCase {
    private IWafRuleRepository repository;

    this(IWafRuleRepository repository) {
        this.repository = repository;
    }

    WafRule execute(in CreateRuleCommand command) {
        enforceCommand(command);

        auto id = generateId(command.name);
        auto rule = WafRule(
            id,
            command.name,
            command.pattern,
            parseRuleAction(command.action),
            parseRuleType(command.ruleType),
            command.priority,
            true,
            command.description
        );

        repository.save(rule);
        return rule;
    }

    private void enforceCommand(in CreateRuleCommand command) {
        if (command.name.length == 0)
            throw new Exception("name must not be empty");
        if (command.pattern.length == 0)
            throw new Exception("pattern must not be empty");
        if (command.action.length == 0)
            throw new Exception("action must not be empty");
        if (command.ruleType.length == 0)
            throw new Exception("ruleType must not be empty");
    }

    private string generateId(string name) {
        auto ts = Clock.currTime.toISOExtString();
        auto hash = sha256Of(name ~ ts);
        return toHexString(hash[0 .. 8]).idup;
    }
}
