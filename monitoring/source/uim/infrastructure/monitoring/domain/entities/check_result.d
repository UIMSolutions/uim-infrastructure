/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module monitoring_service.domain.entities.check_result;

/// Represents the outcome of a single health-check probe.
struct CheckResult {
    string checkId;
    bool healthy;
    uint statusCode;
    string message;
    long timestampUnix;
}
