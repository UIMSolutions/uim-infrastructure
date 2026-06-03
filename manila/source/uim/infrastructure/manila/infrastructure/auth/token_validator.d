module uim.infrastructure.manila.infrastructure.auth.token_validator;

/// Keystone-authenticated caller context.
struct TokenContext {
    string userId;
    string projectId;
    string[] roles;

    bool isAdmin() const {
        foreach (role; roles) {
            if (role == "admin") {
                return true;
            }
        }
        return false;
    }
}

/// Port for token validation. Implementations can use static maps or Keystone API calls.
interface ITokenValidator {
    TokenContext* validateToken(string token);
}
