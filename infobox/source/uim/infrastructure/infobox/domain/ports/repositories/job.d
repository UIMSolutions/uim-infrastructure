/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.infrastructure.infobox.domain.ports.repositories.job;

import uim.infrastructure.infobox.domain.entities.job : Job;

interface IJobRepository {
    void save(in Job job);
    void update(in Job job);
    Job[] listByBuild(string buildId);
    Job* findById(string id);
    Job[] findByName(string buildId, string jobName);
}
