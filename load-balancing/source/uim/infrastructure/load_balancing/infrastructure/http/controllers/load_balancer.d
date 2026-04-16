module lb_service.infrastructure.http.controllers.load_balancer;

import lb_service.application.dto.backend_command : DeregisterBackendCommand, RegisterBackendCommand;
import lb_service.application.usecases.deregister_backend : DeregisterBackendUseCase;
import lb_service.application.usecases.list_backends : ListBackendsUseCase;
import lb_service.application.usecases.register_backend : RegisterBackendUseCase;
import lb_service.application.usecases.select_backend : SelectBackendUseCase;
import lb_service.domain.entities.backend : Backend;
import std.conv : to;
import std.string : split, startsWith;
import vibe.data.json : serializeToJsonString;
import vibe.http.client : requestHTTP;
import vibe.http.common : HTTPMethod, HTTPStatus;
import vibe.http.router : URLRouter;
import vibe.http.server : HTTPServerRequest, HTTPServerResponse;
import vibe.inet.url : URL;
import vibe.stream.operations : readAllUTF8;

struct BackendView {
    string id;
    string host;
    ushort port;
    uint weight;
    bool healthy;
    string address;
}

class LoadBalancerController {
    private RegisterBackendUseCase registerUseCase;
    private DeregisterBackendUseCase deregisterUseCase;
    private ListBackendsUseCase listUseCase;
    private SelectBackendUseCase selectUseCase;

    this(
        RegisterBackendUseCase registerUseCase,
        DeregisterBackendUseCase deregisterUseCase,
        ListBackendsUseCase listUseCase,
        SelectBackendUseCase selectUseCase
    ) {
        this.registerUseCase   = registerUseCase;
        this.deregisterUseCase = deregisterUseCase;
        this.listUseCase       = listUseCase;
        this.selectUseCase     = selectUseCase;
    }

    void registerRoutes(URLRouter router) {
        router.get   ("/health",          &health);
        router.get   ("/v1/backends",     &listBackends);
        router.post  ("/v1/backends/*",   &registerBackend);
        router.delete_("/v1/backends/*",  &deregisterBackend);
        router.any   ("/*",               &proxyRequest);
    }

    // GET /health
    void health(HTTPServerRequest req, HTTPServerResponse res) {
        writeJson(res, `{ "status": "ok" }`, HTTPStatus.ok);
    }

    // GET /v1/backends
    void listBackends(HTTPServerRequest req, HTTPServerResponse res) {
        auto backends = listUseCase.execute();
        writeJson(res, serializeToJsonString(backendsToViews(backends)), HTTPStatus.ok);
    }

    // POST /v1/backends/<id>/<host>/<port>[/<weight>]
    void registerBackend(HTTPServerRequest req, HTTPServerResponse res) {
        auto segments = splitPathAfterPrefix(req.requestPath.to!string, "/v1/backends/");
        if (segments.length < 3) {
            writeJson(res, `{ "error": "expected /v1/backends/<id>/<host>/<port>[/<weight>]" }`, HTTPStatus.badRequest);
            return;
        }

        try {
            ushort port   = segments[2].to!ushort;
            uint   weight = segments.length >= 4 ? segments[3].to!uint : 1;

            auto command = RegisterBackendCommand(segments[0], segments[1], port, weight);
            auto backend = registerUseCase.execute(command);
            writeJson(res, serializeToJsonString(backendsToViews([backend])), HTTPStatus.created);
        } catch (Exception ex) {
            writeJson(res, `{ "error": "` ~ ex.msg ~ `" }`, HTTPStatus.badRequest);
        }
    }

    // DELETE /v1/backends/<id>
    void deregisterBackend(HTTPServerRequest req, HTTPServerResponse res) {
        auto segments = splitPathAfterPrefix(req.requestPath.to!string, "/v1/backends/");
        if (segments.length == 0) {
            writeJson(res, `{ "error": "expected /v1/backends/<id>" }`, HTTPStatus.badRequest);
            return;
        }

        try {
            deregisterUseCase.execute(DeregisterBackendCommand(segments[0]));
            res.writeBody("", cast(int) HTTPStatus.noContent, "application/json");
        } catch (Exception ex) {
            writeJson(res, `{ "error": "` ~ ex.msg ~ `" }`, HTTPStatus.badRequest);
        }
    }

    // ANY /* – forward to the next backend via round-robin
    void proxyRequest(HTTPServerRequest req, HTTPServerResponse res) {
        auto backend = selectUseCase.execute();
        if (backend is null) {
            writeJson(res, `{ "error": "no healthy backend available" }`, HTTPStatus.serviceUnavailable);
            return;
        }

        auto targetURL = URL(backend.address() ~ req.requestPath.to!string);

        try {
            string responseBody;
            int    responseStatus;
            string responseContentType;

            requestHTTP(targetURL,
                (scope reqOut) {
                    reqOut.method = req.method;
                    foreach (name, value; req.headers) {
                        if (name != "Host") {
                            reqOut.headers[name] = value;
                        }
                    }
                    reqOut.headers["Host"] = backend.host;
                },
                (scope resIn) {
                    responseStatus      = cast(int) resIn.statusCode;
                    responseContentType = resIn.contentType;
                    responseBody        = resIn.bodyReader.readAllUTF8();
                }
            );

            res.writeBody(responseBody, responseStatus, responseContentType);
        } catch (Exception ex) {
            writeJson(res, `{ "error": "upstream error: ` ~ ex.msg ~ `" }`, HTTPStatus.badGateway);
        }
    }

    private BackendView[] backendsToViews(scope const Backend[] backends) {
        BackendView[] views;
        foreach (b; backends) {
            views ~= BackendView(b.id, b.host, b.port, b.weight, b.healthy, b.address());
        }
        return views;
    }

    private string[] splitPathAfterPrefix(string requestPath, string prefix) {
        if (!requestPath.startsWith(prefix)) {
            return [];
        }
        return split(requestPath[prefix.length .. $], "/");
    }

    private void writeJson(HTTPServerResponse res, string body, HTTPStatus status) {
        res.writeBody(body, cast(int) status, "application/json");
    }
}
