module uim.infrastructure.waf.application.usecases.create_policy;

import std.conv : to;
import std.digest : toHexString;
import std.digest.sha : sha256Of;
import std.datetime : Clock;
import uim.infrastructure.waf.application.dto.commands : CreatePolicyCommand;
import uim.infrastructure.waf.domain.entities.waf_policy : WafPolicy, parsePolicyMode;
import uim.infrastructure.waf.domain.ports.repositories.waf_policy : IWafPolicyRepository;

class CreatePolicyUseCase {
    private IWafPolicyRepository repository;

    this(IWafPolicyRepository repository) {
        this.repository = repository;
    }

    WafPolicy execute(in CreatePolicyCommand command) {
        enforceCommand(command);

        auto id = generateId(command.name);
        auto policy = WafPolicy(
            id,
            command.name,
            command.ruleIds.dup,
            parsePolicyMode(command.mode),
            command.description
        );

        repository.save(policy);
        return policy;
    }

    private void enforceCommand(in CreatePolicyCommand command) {
        if (command.name.length == 0)
            throw new Exception("name must not be empty");
        if (command.mode.length == 0)
            throw new Exception("mode must not be empty");
    }

    private string generateId(string name) {
        auto ts = Clock.currTime.toISOExtString();
        auto hash = sha256Of(name ~ ts);
        return toHexString(hash[0 .. 8]).idup;
    }
}
