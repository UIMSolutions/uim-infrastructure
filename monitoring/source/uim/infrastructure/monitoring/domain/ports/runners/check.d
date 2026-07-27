/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module monitoring_service.domain.ports.runners.check;

import monitoring_service.domain.entities.check : Check;
import monitoring_service.domain.entities.check_result : CheckResult;

interface ICheckRunner {
    /// Probe the given check target and return the result.
    CheckResult run(in Check check);
}
