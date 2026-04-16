module monitoring_service.domain.entities.check_result;

/// Represents the outcome of a single health-check probe.
struct CheckResult {
    string checkId;
    bool healthy;
    uint statusCode;
    string message;
    long timestampUnix;
}
