module uim.infrastructure.scim.infrastructure.auth.token_validator;

struct TokenContext {
    string subject;
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

interface ITokenValidator {
    TokenContext* validateToken(string token);
}
