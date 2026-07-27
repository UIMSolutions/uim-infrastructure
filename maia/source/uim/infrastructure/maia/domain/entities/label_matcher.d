/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.infrastructure.maia.domain.entities.label_matcher;

import std.string : strip, indexOf, lastIndexOf, split;
import std.regex  : regex, matchFirst;

/// Comparison operator for a label matcher.
enum MatchOp {
    eq,    /// label = "value"
    neq,   /// label != "value"
    re,    /// label =~ "regex"
    nre    /// label !~ "regex"
}

/// A single Prometheus label selector constraint.
struct LabelMatcher {
    string  label;
    string  value;
    MatchOp op;

    /// Test whether the actual label value satisfies this matcher.
    bool matches(string actual) const {
        final switch (op) {
            case MatchOp.eq:  return actual == value;
            case MatchOp.neq: return actual != value;
            case MatchOp.re:  return !matchFirst(actual, regex(value)).empty;
            case MatchOp.nre: return matchFirst(actual, regex(value)).empty;
        }
    }
}

/// Parse a PromQL selector expression into a list of LabelMatchers.
/// Supports:
///   "metric_name"              → {__name__="metric_name"}
///   "{label1="v",label2!="v"}" → explicit matchers
///   "metric_name{label="v"}"   → name + matchers
LabelMatcher[] parseSelector(string expr) {
    expr = expr.strip();
    if (expr.length == 0) return [];

    LabelMatcher[] result;

    auto braceOpen  = expr.indexOf('{');
    auto braceClose = expr.lastIndexOf('}');

    if (braceOpen < 0) {
        // Plain metric name only
        result ~= LabelMatcher("__name__", expr, MatchOp.eq);
        return result;
    }

    // Optional metric name before {
    if (braceOpen > 0) {
        result ~= LabelMatcher("__name__", expr[0 .. braceOpen].strip(), MatchOp.eq);
    }

    if (braceClose <= braceOpen) return result;

    // Parse comma-separated matchers inside { }
    auto inner = expr[braceOpen + 1 .. braceClose];
    foreach (part; inner.split(',')) {
        auto m = parseOneMatcher(part.strip());
        if (m.label.length > 0) result ~= m;
    }

    return result;
}

private LabelMatcher parseOneMatcher(string part) {
    if (part.length == 0) return LabelMatcher.init;

    // Detect two-character operators first to avoid ambiguity with '='
    auto nreIdx  = part.indexOf("!~");
    auto reIdx   = part.indexOf("=~");
    auto neqIdx  = part.indexOf("!=");
    auto eqIdx   = part.indexOf('=');

    string label;
    string rawVal;
    MatchOp op;

    if (neqIdx >= 0 && (reIdx < 0 || neqIdx < reIdx) && (nreIdx < 0 || neqIdx < nreIdx)) {
        label  = part[0 .. neqIdx].strip();
        rawVal = part[neqIdx + 2 .. $].strip();
        op     = MatchOp.neq;
    } else if (reIdx >= 0 && (nreIdx < 0 || reIdx <= nreIdx)) {
        label  = part[0 .. reIdx].strip();
        rawVal = part[reIdx + 2 .. $].strip();
        op     = MatchOp.re;
    } else if (nreIdx >= 0) {
        label  = part[0 .. nreIdx].strip();
        rawVal = part[nreIdx + 2 .. $].strip();
        op     = MatchOp.nre;
    } else if (eqIdx >= 0) {
        label  = part[0 .. eqIdx].strip();
        rawVal = part[eqIdx + 1 .. $].strip();
        op     = MatchOp.eq;
    } else {
        return LabelMatcher.init;
    }

    return LabelMatcher(label, unquote(rawVal), op);
}

private string unquote(string s) {
    if (s.length >= 2 && s[0] == '"' && s[$ - 1] == '"')
        return s[1 .. $ - 1];
    return s;
}

unittest {
    auto m1 = parseSelector("up");
    assert(m1.length == 1);
    assert(m1[0].label == "__name__");
    assert(m1[0].value == "up");
    assert(m1[0].op    == MatchOp.eq);

    auto m2 = parseSelector(`up{project_id="p1",job!="none"}`);
    assert(m2.length == 3);
    assert(m2[0].label == "__name__" && m2[0].value == "up");
    assert(m2[1].label == "project_id" && m2[1].op == MatchOp.eq);
    assert(m2[2].label == "job"        && m2[2].op == MatchOp.neq);

    auto lm = LabelMatcher("job", "foo", MatchOp.eq);
    assert( lm.matches("foo"));
    assert(!lm.matches("bar"));

    auto lmRe = LabelMatcher("__name__", "http_.*", MatchOp.re);
    assert( lmRe.matches("http_requests_total"));
    assert(!lmRe.matches("cpu_util"));
}
