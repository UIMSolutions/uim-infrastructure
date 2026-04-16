module monitoring_service.infrastructure.probing.http_check_runner;

import monitoring_service.domain.entities.check : Check;
import monitoring_service.domain.entities.check_result : CheckResult;
import monitoring_service.domain.ports.runners.check : ICheckRunner;
import std.conv : to;
import vibe.http.client : requestHTTP;
import vibe.http.common : HTTPMethod, HTTPStatus;
import vibe.inet.url : URL;
import vibe.stream.operations : readAllUTF8;

class HttpCheckRunner : ICheckRunner {
    override CheckResult run(in Check check) {
        import std.datetime : Clock;
        auto timestampUnix = Clock.currTime().toUnixTime!long();

        auto targetURL = URL(check.address() ~ "/health");

        try {
            bool   healthy;
            uint   statusCode;
            string message;

            requestHTTP(targetURL,
                (scope req) {
                    req.method = HTTPMethod.GET;
                },
                (scope res) {
                    statusCode = cast(uint) res.statusCode;
                    healthy    = statusCode >= 200 && statusCode < 300;
                    message    = res.bodyReader.readAllUTF8();
                }
            );

            return CheckResult(check.id, healthy, statusCode, message, timestampUnix);
        } catch (Exception ex) {
            return CheckResult(check.id, false, 0, ex.msg, timestampUnix);
        }
    }
}
