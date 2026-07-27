/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.infrastructure.barbican.application.usecases.get_secret;

import uim.infrastructure.barbican.domain.entities.secret : Secret;
import uim.infrastructure.barbican.domain.ports.repositories.secret : ISecretRepository;

class GetSecretUseCase {
    private ISecretRepository repository;

    this(ISecretRepository repository) {
        this.repository = repository;
    }

    Secret* execute(string id) {
        return repository.findById(id);
    }
}
