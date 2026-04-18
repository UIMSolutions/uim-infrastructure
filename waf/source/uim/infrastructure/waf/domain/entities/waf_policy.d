module uim.infrastructure.waf.domain.entities.waf_policy;

import std.conv : to;
import std.string : toUpper;

enum PolicyMode {
    DETECTION,
    PREVENTION
}

struct WafPolicy {
    string id;
    string name;
    string[] ruleIds;
    PolicyMode mode;
    string description;

    string summary() const {
        return name ~ " [" ~ mode.to!string ~ "] (" ~ ruleIds.length.to!string ~ " rules)";
    }
}

PolicyMode parsePolicyMode(string raw) {
    auto normalized = raw.toUpper();
    foreach (candidate; __traits(allMembers, PolicyMode)) {
        if (candidate == normalized) {
            return to!PolicyMode(normalized);
        }
    }
    throw new Exception("Unsupported policy mode: " ~ raw);
}

unittest {
    assert(parsePolicyMode("detection") == PolicyMode.DETECTION);
    assert(parsePolicyMode("PREVENTION") == PolicyMode.PREVENTION);

    auto policy = WafPolicy("p1", "Default Policy", ["r1", "r2"], PolicyMode.PREVENTION, "Standard protection");
    assert(policy.summary() == "Default Policy [PREVENTION] (2 rules)");
}
