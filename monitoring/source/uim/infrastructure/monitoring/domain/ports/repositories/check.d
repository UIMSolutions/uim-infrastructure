module monitoring_service.domain.ports.repositories.check;

import monitoring_service.domain.entities.check : Check;
import monitoring_service.domain.entities.check_result : CheckResult;

interface ICheckRepository {
    void save(in Check check);
    void remove(string id);
    Check[] list();
    Check* findById(string id);
    void saveResult(in CheckResult result);
    CheckResult[] listResults(string checkId);
}
