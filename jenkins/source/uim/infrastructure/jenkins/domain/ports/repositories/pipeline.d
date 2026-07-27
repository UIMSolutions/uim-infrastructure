/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.infrastructure.jenkins.domain.ports.repositories.pipeline;

import jenkins_service.domain.entities.pipeline : Pipeline;

interface IPipelineRepository {
    void save(in Pipeline pipeline);
    Pipeline[] list();
    Pipeline* findById(string id);
    void deleteById(string id);
}
