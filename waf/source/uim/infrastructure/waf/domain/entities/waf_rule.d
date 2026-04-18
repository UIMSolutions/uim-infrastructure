module uim.infrastructure.waf.domain.entities.waf_rule;

import std.conv : to;
import std.string : toUpper;

enum RuleType {
    SQL_INJECTION,
    XSS,
    PATH_TRAVERSAL,
    RATE_LIMIT,
    IP_BLACKLIST,
    CUSTOM_REGEX
}

enum RuleAction {
    ALLOW,
    BLOCK,
    LOG,
    CHALLENGE
}

struct WafRule {
    string id;
    string name;
    string pattern;
    RuleAction action;
    RuleType ruleType;
    uint priority;
    bool enabled;
    string description;

    string summary() const {
        return name ~ " [" ~ ruleType.to!string ~ "] -> " ~ action.to!string;
    }
}

RuleType parseRuleType(string raw) {
    auto normalized = raw.toUpper();
    foreach (candidate; __traits(allMembers, RuleType)) {
        if (candidate == normalized) {
            return to!RuleType(normalized);
        }
    }
    throw new Exception("Unsupported rule type: " ~ raw);
}

RuleAction parseRuleAction(string raw) {
    auto normalized = raw.toUpper();
    foreach (candidate; __traits(allMembers, RuleAction)) {
        if (candidate == normalized) {
            return to!RuleAction(normalized);
        }
    }
    throw new Exception("Unsupported rule action: " ~ raw);
}

unittest {
    assert(parseRuleType("SQL_INJECTION") == RuleType.SQL_INJECTION);
    assert(parseRuleType("xss") == RuleType.XSS);
    assert(parseRuleAction("block") == RuleAction.BLOCK);
    assert(parseRuleAction("LOG") == RuleAction.LOG);

    auto rule = WafRule("r1", "Block SQLi", `(?i)(union\s+select|drop\s+table)`, RuleAction.BLOCK, RuleType.SQL_INJECTION, 1, true, "Blocks SQL injection attempts");
    assert(rule.summary() == "Block SQLi [SQL_INJECTION] -> BLOCK");
}
