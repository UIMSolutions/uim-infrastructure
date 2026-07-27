/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.infrastructure.jenkins.domain.ports.repositories.build;

import jenkins_service.domain.entities.build : Build;

interface IBuildRepository {
    void save(in Build build);
    Build[] listByPipeline(string pipelineId);
    Build* findById(string id);
    uint nextBuildNumber(string pipelineId);
}
