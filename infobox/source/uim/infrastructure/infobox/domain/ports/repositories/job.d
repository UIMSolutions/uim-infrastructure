module uim.infrastructure.infobox.domain.ports.repositories.job;

import uim.infrastructure.infobox.domain.entities.job : Job;

interface IJobRepository {
    void save(in Job job);
    void update(in Job job);
    Job[] listByBuild(string buildId);
    Job* findById(string id);
    Job[] findByName(string buildId, string jobName);
}
