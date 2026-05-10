module uim.infrastructure.maia.application.usecases.authenticate;

import uim.infrastructure.maia.domain.entities.tenant : Tenant;
import uim.infrastructure.maia.domain.ports.repositories.token : ITokenRepository;
import std.base64 : Base64;
import std.string : indexOf;

class AuthenticateUseCase {
    private ITokenRepository tokenRepo;

    this(ITokenRepository tokenRepo) {
        this.tokenRepo = tokenRepo;
    }

    /// Extract and validate the tenant from raw header values.
    /// Returns null when authentication fails.
    Tenant* fromHeaders(string xAuthToken, string authorization) {
        // Prefer X-Auth-Token (Keystone style)
        if (xAuthToken.length > 0) {
            return tokenRepo.validateToken(xAuthToken);
        }

        // Fall back to HTTP Basic (for Grafana / federated Prometheus)
        if (authorization.length > 7 && authorization[0 .. 6] == "Basic ") {
            auto encoded = authorization[6 .. $];
            try {
                auto decoded = cast(string) Base64.decode(encoded);
                auto colonPos = decoded.indexOf(':');
                if (colonPos < 0) return null;
                string username = decoded[0 .. colonPos];
                string password = decoded[colonPos + 1 .. $];
                return tokenRepo.validateBasicAuth(username, password);
            } catch (Exception) {
                return null;
            }
        }

        return null;
    }
}
