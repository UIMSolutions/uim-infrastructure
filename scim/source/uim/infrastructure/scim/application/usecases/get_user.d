/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.infrastructure.scim.application.usecases.get_user;

import uim.infrastructure.scim.domain.entities.user : ScimUser;
import uim.infrastructure.scim.domain.ports.repositories.user : IUserRepository;

class GetUserUseCase {
    private IUserRepository repository;

    this(IUserRepository repository) {
        this.repository = repository;
    }

    ScimUser* execute(string id) {
        return repository.findById(id);
    }
}
