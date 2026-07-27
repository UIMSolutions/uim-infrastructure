/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.infrastructure.infobox.application.usecases.get_job;

import uim.infrastructure.infobox.application.dto.commands : GetJobQuery;
import uim.infrastructure.infobox.domain.entities.job : Job;
import uim.infrastructure.infobox.domain.ports.repositories.job : IJobRepository;

class GetJobUseCase {
    private IJobRepository repository;

    this(IJobRepository repository) {
        this.repository = repository;
    }

    Job execute(in GetJobQuery query) {
        if (query.id.length == 0) {
            throw new Exception("job id must not be empty");
        }

        auto result = repository.findById(query.id);
        if (result is null) {
            throw new Exception("job not found: " ~ query.id);
        }
        return *result;
    }
}
