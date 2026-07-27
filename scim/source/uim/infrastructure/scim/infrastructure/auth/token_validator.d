/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
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
