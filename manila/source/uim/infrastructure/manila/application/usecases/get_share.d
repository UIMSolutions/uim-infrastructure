/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.infrastructure.manila.application.usecases.get_share;

import uim.infrastructure.manila.domain.entities.share : Share;
import uim.infrastructure.manila.domain.ports.repositories.share : IShareRepository;

class GetShareUseCase {
    private IShareRepository repository;

    this(IShareRepository repository) {
        this.repository = repository;
    }

    Share* execute(string id) {
        if (id.length == 0) {
            throw new Exception("share id must not be empty");
        }
        return repository.findById(id);
    }
}