/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
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
