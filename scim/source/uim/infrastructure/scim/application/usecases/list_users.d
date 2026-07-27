/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.infrastructure.scim.application.usecases.list_users;

import std.string : toLower;
import uim.infrastructure.scim.domain.entities.user : ScimUser;
import uim.infrastructure.scim.domain.ports.repositories.user : IUserRepository;

class ListUsersUseCase {
    private IUserRepository repository;

    this(IUserRepository repository) {
        this.repository = repository;
    }

    ScimUser[] execute(string filterAttribute = "", string filterValue = "") {
        auto users = repository.list();
        if (filterAttribute.length == 0 || filterValue.length == 0) {
            return users;
        }

        ScimUser[] filtered;
        foreach (user; users) {
            switch (toLower(filterAttribute)) {
                case "username":
                    if (toLower(user.userName) == toLower(filterValue)) {
                        filtered ~= user;
                    }
                    break;
                case "externalid":
                    if (toLower(user.externalId) == toLower(filterValue)) {
                        filtered ~= user;
                    }
                    break;
                case "displayname":
                    if (toLower(user.displayName) == toLower(filterValue)) {
                        filtered ~= user;
                    }
                    break;
                default:
                    return users;
            }
        }
        return filtered;
    }
}
