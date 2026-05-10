module uim.infrastructure.maia.domain.ports.repositories.token;

import uim.infrastructure.maia.domain.entities.tenant : Tenant;

/// Hexagonal port: authentication driver — validates tokens to Tenant contexts.
/// In production this would call OpenStack Keystone; here it is a pluggable interface.
interface ITokenRepository {
    /// Validate a Keystone token and return the scoped Tenant, or null if invalid.
    Tenant* validateToken(string token);

    /// Validate HTTP Basic-Auth credentials and return the scoped Tenant, or null.
    /// username encodes scope: "user|project_id", "user|@domain_name", etc.
    Tenant* validateBasicAuth(string username, string password);
}
