/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.infrastructure.infobox.application.usecases.list_secrets;

import uim.infrastructure.infobox.application.dto.commands : ListSecretsQuery;
import uim.infrastructure.infobox.domain.entities.secret : Secret;
import uim.infrastructure.infobox.domain.ports.repositories.secret : ISecretRepository;

class ListSecretsUseCase {
    private ISecretRepository repository;

    this(ISecretRepository repository) {
        this.repository = repository;
    }

    Secret[] execute(in ListSecretsQuery query) {
        if (query.projectId.length == 0) {
            throw new Exception("project id must not be empty");
        }
        return repository.listByProject(query.projectId);
    }
}
