module uim.infrastructure.manila.infrastructure.auth.static_token_validator;

import std.string : toLower;
import uim.infrastructure.manila.infrastructure.auth.token_validator : ITokenValidator, TokenContext;

/// Static in-memory token validator useful for development and local testing.
class StaticTokenValidator : ITokenValidator {
    private TokenContext[string] tokenMap;
    private bool allowInsecureFallback;

    this(bool allowInsecureFallback = false) {
        this.allowInsecureFallback = allowInsecureFallback;
    }

    void register(string token, string projectId, string userId, string[] roles) {
        tokenMap[token] = TokenContext(userId, projectId, normalizedRoles(roles));
    }

    override TokenContext* validateToken(string token) {
        if (token.length == 0) {
            return null;
        }
        if (auto context = token in tokenMap) {
            return context;
        }

        if (!allowInsecureFallback) {
            return null;
        }

        tokenMap[token] = TokenContext("user-" ~ token, token, ["member"]);
        return token in tokenMap;
    }

    private string[] normalizedRoles(string[] roles) {
        string[] normalized;
        foreach (role; roles) {
            auto lowered = role.toLower();
            if (lowered.length > 0) {
                normalized ~= lowered;
            }
        }
        if (normalized.length == 0) {
            normalized = ["member"];
        }
        return normalized;
    }
}

unittest {
    auto validator = new StaticTokenValidator();
    validator.register("token-a", "project-a", "user-a", ["member"]);

    auto context = validator.validateToken("token-a");
    assert(context !is null);
    assert(context.projectId == "project-a");
    assert(!context.isAdmin());
}
