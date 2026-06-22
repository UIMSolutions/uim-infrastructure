module uim.infrastructure.scim.infrastructure.auth.static_bearer_token_validator;

import std.string : toLower;
import uim.infrastructure.scim.infrastructure.auth.token_validator : ITokenValidator, TokenContext;

class StaticBearerTokenValidator : ITokenValidator {
    private TokenContext[string] tokenMap;
    private bool allowInsecureFallback;

    this(bool allowInsecureFallback = false) {
        this.allowInsecureFallback = allowInsecureFallback;
    }

    void register(string token, string subject, string[] roles) {
        tokenMap[token] = TokenContext(subject, normalizedRoles(roles));
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

        tokenMap[token] = TokenContext("subject-" ~ token, ["member"]);
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
