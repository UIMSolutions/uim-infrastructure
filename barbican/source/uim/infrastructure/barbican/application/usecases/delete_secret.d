/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.infrastructure.barbican.application.usecases.delete_secret;

import uim.infrastructure.barbican.domain.ports.repositories.secret : ISecretRepository;

class DeleteSecretUseCase {
    private ISecretRepository repository;

    this(ISecretRepository repository) {
        this.repository = repository;
    }

    void execute(string id) {
        auto ptr = repository.findById(id);
        if (ptr is null)
            throw new Exception("Secret not found: " ~ id);
        repository.remove(id);
    }
}
