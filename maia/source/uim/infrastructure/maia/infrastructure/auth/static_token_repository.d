module uim.infrastructure.maia.infrastructure.auth.static_token_repository;

import uim.infrastructure.maia.domain.entities.tenant : Tenant;
import uim.infrastructure.maia.domain.ports.repositories.token : ITokenRepository;
import std.string : indexOf, split, strip;

/// A simple pluggable token store that maps pre-configured tokens to Tenants.
///
/// Authentication strategy (in order):
///   1. Exact match in the token map (from MAIA_TOKENS env or debug token).
///   2. Fallback: treat the token itself as the project_id (useful for development).
///
/// For Basic-Auth the username encodes the scope following the Maia convention:
///   "user|project_id" → project-scoped tenant
///   "user|@domain_name" → domain-scoped tenant
///   "user" alone → project_id = username
class StaticTokenRepository : ITokenRepository {
    private Tenant[string] tokenMap;

    /// debugToken — a single pre-configured token accepted unconditionally.
    this(string debugToken = "") {
        if (debugToken.length > 0) {
            tokenMap[debugToken] = Tenant("debug-project", "debug-domain");
        }
    }

    /// Register a token → Tenant mapping (called during startup configuration).
    void register(string token, string projectId, string domainId = "") {
        tokenMap[token] = Tenant(projectId, domainId);
    }

    override Tenant* validateToken(string token) {
        if (token.length == 0) return null;
        if (auto p = token in tokenMap) return p;
        // Fallback: treat token as project_id (development convenience)
        tokenMap[token] = Tenant(token, "");
        return token in tokenMap;
    }

    override Tenant* validateBasicAuth(string username, string password) {
        if (username.length == 0) return null;

        // Parse Maia username convention: "user|scope"
        auto pipePos = username.indexOf('|');
        string scope_ = pipePos >= 0 ? username[pipePos + 1 .. $].strip() : username.strip();

        Tenant tenant;
        if (scope_.length > 0 && scope_[0] == '@') {
            // Domain-scoped: "@domain_name"
            tenant = Tenant("", scope_[1 .. $]);
        } else if (scope_.length > 0) {
            tenant = Tenant(scope_, "");
        } else {
            tenant = Tenant(username, "");
        }

        auto key = "basic:" ~ scope_;
        tokenMap[key] = tenant;
        return key in tokenMap;
    }
}

unittest {
    auto repo = new StaticTokenRepository("test-token");

    auto t = repo.validateToken("test-token");
    assert(t !is null);
    assert(t.projectId == "debug-project");

    // Fallback: unknown token → use token as project_id
    auto t2 = repo.validateToken("proj-abc");
    assert(t2 !is null);
    assert(t2.projectId == "proj-abc");

    // Basic auth: "user|project-001"
    auto t3 = repo.validateBasicAuth("alice|project-001", "pass");
    assert(t3 !is null);
    assert(t3.projectId == "project-001");

    // Basic auth: domain scope "@my-domain"
    auto t4 = repo.validateBasicAuth("alice|@my-domain", "pass");
    assert(t4 !is null);
    assert(t4.isDomainScoped());
    assert(t4.domainId == "my-domain");
}
