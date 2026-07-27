/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.infrastructure.barbican.application.usecases.list_containers;

import uim.infrastructure.barbican.domain.entities.secret_container : SecretContainer;
import uim.infrastructure.barbican.domain.ports.repositories.secret_container : ISecretContainerRepository;

class ListContainersUseCase {
    private ISecretContainerRepository repository;

    this(ISecretContainerRepository repository) {
        this.repository = repository;
    }

    SecretContainer[] execute(string projectId = "") {
        return repository.list(projectId);
    }
}
