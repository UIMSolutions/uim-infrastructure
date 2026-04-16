module monitoring_service.domain.ports.runners.check;

import monitoring_service.domain.entities.check : Check;
import monitoring_service.domain.entities.check_result : CheckResult;

interface ICheckRunner {
    /// Probe the given check target and return the result.
    CheckResult run(in Check check);
}
