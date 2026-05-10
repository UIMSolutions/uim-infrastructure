module uim.infrastructure.maia.infrastructure.http.controllers.maia;

import uim.infrastructure.maia.application.dto.maia_commands;
import uim.infrastructure.maia.application.usecases.authenticate : AuthenticateUseCase;
import uim.infrastructure.maia.application.usecases.ingest_sample : IngestSampleUseCase;
import uim.infrastructure.maia.application.usecases.list_label_values : ListLabelValuesUseCase;
import uim.infrastructure.maia.application.usecases.list_labels : ListLabelsUseCase;
import uim.infrastructure.maia.application.usecases.list_series : ListSeriesUseCase;
import uim.infrastructure.maia.application.usecases.query_instant : QueryInstantUseCase;
import uim.infrastructure.maia.application.usecases.query_range : QueryRangeUseCase;
import uim.infrastructure.maia.domain.entities.sample : Sample;
import uim.infrastructure.maia.domain.entities.tenant : Tenant;
import uim.infrastructure.maia.domain.entities.time_series : TimeSeries;
import std.algorithm : sort, uniq;
import std.array : array, Appender;
import std.conv : to;
import std.format : format;
import std.string : split, startsWith, join;
import vibe.data.json : Json, serializeToJsonString;
import vibe.http.common : HTTPStatus;
import vibe.http.router : URLRouter;
import vibe.http.server : HTTPServerRequest, HTTPServerResponse;

class MaiaController {
    private AuthenticateUseCase    authUseCase;
    private IngestSampleUseCase    ingestUseCase;
    private QueryInstantUseCase    queryInstantUseCase;
    private QueryRangeUseCase      queryRangeUseCase;
    private ListSeriesUseCase      listSeriesUseCase;
    private ListLabelsUseCase      listLabelsUseCase;
    private ListLabelValuesUseCase listLabelValuesUseCase;

    this(
        AuthenticateUseCase    authUseCase,
        IngestSampleUseCase    ingestUseCase,
        QueryInstantUseCase    queryInstantUseCase,
        QueryRangeUseCase      queryRangeUseCase,
        ListSeriesUseCase      listSeriesUseCase,
        ListLabelsUseCase      listLabelsUseCase,
        ListLabelValuesUseCase listLabelValuesUseCase
    ) {
        this.authUseCase            = authUseCase;
        this.ingestUseCase          = ingestUseCase;
        this.queryInstantUseCase    = queryInstantUseCase;
        this.queryRangeUseCase      = queryRangeUseCase;
        this.listSeriesUseCase      = listSeriesUseCase;
        this.listLabelsUseCase      = listLabelsUseCase;
        this.listLabelValuesUseCase = listLabelValuesUseCase;
    }

    void registerRoutes(URLRouter router) {
        router.get ("/health",                  &health);
        router.get ("/api/v1/query",            &queryInstant);
        router.get ("/api/v1/query_range",      &queryRange);
        router.get ("/api/v1/series",           &listSeries);
        router.get ("/api/v1/labels",           &listLabels);
        router.get ("/api/v1/label/*",          &handleLabelPath); // /api/v1/label/<name>/values
        router.get ("/api/v1/metadata",         &metadata);
        router.get ("/federate",                &federate);
        router.post("/api/v1/ingest",           &ingest);
    }

    // ── GET /health ───────────────────────────────────────────────────────────

    void health(HTTPServerRequest req, HTTPServerResponse res) {
        writeJson(res, `{"status":"ok","service":"uim-maia-service"}`, HTTPStatus.ok);
    }

    // ── GET /api/v1/query?query=<selector>&time=<unix_sec> ───────────────────

    void queryInstant(HTTPServerRequest req, HTTPServerResponse res) {
        auto tenant = authenticate(req, res);
        if (tenant is null) return;

        try {
            auto selector = req.query.get("query", "");
            auto timeStr  = req.query.get("time",  "");
            long atMs     = timeStr.length > 0 ? cast(long)(timeStr.to!double * 1000.0) : 0L;

            auto cmd     = InstantQueryCommand(selector, atMs);
            auto results = queryInstantUseCase.execute(cmd, *tenant);

            auto data = Json.emptyObject;
            data["resultType"] = Json("vector");
            auto resultArr = Json.emptyArray;
            foreach (r; results) {
                auto entry = Json.emptyObject;
                entry["metric"] = labelsToJson(r.series.labels);
                auto valuePair  = Json.emptyArray;
                valuePair.appendArrayElement(Json(r.timestampSec));
                valuePair.appendArrayElement(Json(format!"%g"(r.value)));
                entry["value"] = valuePair;
                resultArr.appendArrayElement(entry);
            }
            data["result"] = resultArr;
            writeSuccess(res, data);
        } catch (Exception ex) {
            writeError(res, "bad_data", ex.msg, HTTPStatus.badRequest);
        }
    }

    // ── GET /api/v1/query_range?query=<selector>&start=<s>&end=<s>&step=<s> ─

    void queryRange(HTTPServerRequest req, HTTPServerResponse res) {
        auto tenant = authenticate(req, res);
        if (tenant is null) return;

        try {
            auto selector = req.query.get("query", "");
            auto startStr = req.query.get("start", "");
            auto endStr   = req.query.get("end",   "");
            auto stepStr  = req.query.get("step",  "60");

            if (startStr.length == 0 || endStr.length == 0) {
                writeError(res, "bad_data", "start and end are required", HTTPStatus.badRequest);
                return;
            }

            long startMs = cast(long)(startStr.to!double * 1000.0);
            long endMs   = cast(long)(endStr.to!double   * 1000.0);
            long stepMs  = cast(long)(stepStr.to!double  * 1000.0);

            auto cmd     = RangeQueryCommand(selector, startMs, endMs, stepMs);
            auto results = queryRangeUseCase.execute(cmd, *tenant);

            auto data = Json.emptyObject;
            data["resultType"] = Json("matrix");
            auto resultArr = Json.emptyArray;
            foreach (r; results) {
                auto entry = Json.emptyObject;
                entry["metric"] = labelsToJson(r.series.labels);
                auto valuesArr  = Json.emptyArray;
                foreach (s; r.samples) {
                    auto pair = Json.emptyArray;
                    pair.appendArrayElement(Json(s.timestampSec()));
                    pair.appendArrayElement(Json(format!"%g"(s.value)));
                    valuesArr.appendArrayElement(pair);
                }
                entry["values"] = valuesArr;
                resultArr.appendArrayElement(entry);
            }
            data["result"] = resultArr;
            writeSuccess(res, data);
        } catch (Exception ex) {
            writeError(res, "bad_data", ex.msg, HTTPStatus.badRequest);
        }
    }

    // ── GET /api/v1/series?match[]=<selector> ────────────────────────────────

    void listSeries(HTTPServerRequest req, HTTPServerResponse res) {
        auto tenant = authenticate(req, res);
        if (tenant is null) return;

        try {
            string[] matchers;
            foreach (kv; req.query.byKeyValue()) {
                if (kv.key == "match[]") matchers ~= kv.value;
            }

            long startMs, endMs;
            auto startStr = req.query.get("start", "");
            auto endStr   = req.query.get("end",   "");
            if (startStr.length > 0) startMs = cast(long)(startStr.to!double * 1000.0);
            if (endStr.length   > 0) endMs   = cast(long)(endStr.to!double   * 1000.0);

            auto cmd    = ListSeriesCommand(matchers, startMs, endMs);
            auto series = listSeriesUseCase.execute(cmd, *tenant);

            auto dataArr = Json.emptyArray;
            foreach (ts; series) {
                dataArr.appendArrayElement(labelsToJson(ts.labels));
            }
            writeSuccess(res, dataArr);
        } catch (Exception ex) {
            writeError(res, "bad_data", ex.msg, HTTPStatus.badRequest);
        }
    }

    // ── GET /api/v1/labels ───────────────────────────────────────────────────

    void listLabels(HTTPServerRequest req, HTTPServerResponse res) {
        auto tenant = authenticate(req, res);
        if (tenant is null) return;

        try {
            auto cmd    = ListLabelsCommand(0L, 0L);
            auto labels = listLabelsUseCase.execute(cmd, *tenant);
            auto arr    = Json.emptyArray;
            foreach (l; labels) arr.appendArrayElement(Json(l));
            writeSuccess(res, arr);
        } catch (Exception ex) {
            writeError(res, "bad_data", ex.msg, HTTPStatus.badRequest);
        }
    }

    // ── GET /api/v1/label/<name>/values ──────────────────────────────────────

    void handleLabelPath(HTTPServerRequest req, HTTPServerResponse res) {
        auto tenant = authenticate(req, res);
        if (tenant is null) return;

        // Path: /api/v1/label/<name>/values
        auto segments = splitPathAfterPrefix(req.requestPath.to!string, "/api/v1/label/");
        if (segments.length < 2 || segments[1] != "values") {
            writeError(res, "bad_data", "expected /api/v1/label/<name>/values", HTTPStatus.badRequest);
            return;
        }

        try {
            auto cmd  = ListLabelValuesCommand(segments[0], 0L, 0L);
            auto vals = listLabelValuesUseCase.execute(cmd, *tenant);
            auto arr  = Json.emptyArray;
            foreach (v; vals) arr.appendArrayElement(Json(v));
            writeSuccess(res, arr);
        } catch (Exception ex) {
            writeError(res, "bad_data", ex.msg, HTTPStatus.badRequest);
        }
    }

    // ── GET /api/v1/metadata ─────────────────────────────────────────────────

    void metadata(HTTPServerRequest req, HTTPServerResponse res) {
        auto tenant = authenticate(req, res);
        if (tenant is null) return;

        // Return an empty metadata map — real implementation would consult a Prometheus backend
        writeSuccess(res, Json.emptyObject);
    }

    // ── GET /federate?match[]=<selector> ─────────────────────────────────────
    // Returns Prometheus text exposition format for federation.

    void federate(HTTPServerRequest req, HTTPServerResponse res) {
        auto tenant = authenticate(req, res);
        if (tenant is null) return;

        try {
            string[] matchers;
            foreach (kv; req.query.byKeyValue()) {
                if (kv.key == "match[]") matchers ~= kv.value;
            }

            import uim.infrastructure.maia.domain.entities.label_matcher : parseSelector;
            import uim.infrastructure.maia.infrastructure.persistence.memory.time_series_repository : InMemoryTimeSeriesRepository;

            auto cmd    = ListSeriesCommand(matchers, 0L, long.max);
            auto series = listSeriesUseCase.execute(cmd, *tenant);

            import std.datetime.systime : Clock;
            long nowMs = Clock.currTime().toUnixTime() * 1000L;

            // We need the repository for samples — pass it through the use case
            // For the controller, we re-query by building a fake instant command per series
            auto buf = Appender!string();
            foreach (ts; series) {
                auto name = ts.name();
                if (name.length == 0) continue;

                // Build label string (sorted keys, excluding __name__)
                string[] labelParts;
                auto sortedKeys = ts.labels.keys.dup;
                sortedKeys.sort();
                foreach (k; sortedKeys) {
                    if (k == "__name__") continue;
                    labelParts ~= k ~ `="` ~ ts.labels[k] ~ `"`;
                }
                string labelStr = labelParts.length > 0 ? ("{" ~ labelParts.join(",") ~ "}") : "";

                // Instant query for this specific series via queryInstant
                auto iqCmd = InstantQueryCommand("{__name__=\"" ~ name ~ "\"}", nowMs);
                auto results = queryInstantUseCase.execute(iqCmd, *tenant);
                foreach (r; results) {
                    if (r.series.id != ts.id) continue;
                    buf.put(name ~ labelStr);
                    buf.put(" ");
                    buf.put(format!"%g"(r.value));
                    buf.put(" ");
                    buf.put(format!"%d"(cast(long)(r.timestampSec * 1000.0)));
                    buf.put("\n");
                }
            }

            res.writeBody(buf.data, cast(int) HTTPStatus.ok, "text/plain; version=0.0.4");
        } catch (Exception ex) {
            writeError(res, "internal", ex.msg, HTTPStatus.internalServerError);
        }
    }

    // ── POST /api/v1/ingest (custom push endpoint) ───────────────────────────

    void ingest(HTTPServerRequest req, HTTPServerResponse res) {
        auto tenant = authenticate(req, res);
        if (tenant is null) return;

        try {
            auto body = req.json;
            if (body.type == Json.Type.undefined || body.type == Json.Type.null_) {
                writeError(res, "bad_data", "missing JSON body", HTTPStatus.badRequest);
                return;
            }

            // Resolve labels
            string[string] labels;
            auto labelsJson = body["labels"];
            if (labelsJson.type == Json.Type.object) {
                foreach (string k, Json v; labelsJson) {
                    if (v.type == Json.Type.string) labels[k] = v.get!string;
                }
            }

            // __name__ can come from top-level "name" or from labels
            auto nameJson = body["name"];
            if (nameJson.type == Json.Type.string) {
                labels["__name__"] = nameJson.get!string;
            }

            // Inject tenant labels so isolation is enforced
            if (tenant.projectId.length > 0 && "project_id" !in labels) {
                labels["project_id"] = tenant.projectId;
            }
            if (tenant.domainId.length > 0 && "domain_id" !in labels) {
                labels["domain_id"] = tenant.domainId;
            }

            // Value
            double value;
            auto vj = body["value"];
            if      (vj.type == Json.Type.float_) value = vj.get!double;
            else if (vj.type == Json.Type.int_)   value = cast(double) vj.get!long;
            else { writeError(res, "bad_data", "value must be numeric", HTTPStatus.badRequest); return; }

            // Optional timestamp (Unix seconds as float)
            long tsMs = 0L;
            auto tsj  = body["timestamp"];
            if      (tsj.type == Json.Type.float_) tsMs = cast(long)(tsj.get!double * 1000.0);
            else if (tsj.type == Json.Type.int_)   tsMs = tsj.get!long * 1000L;

            auto cmd = IngestSampleCommand(labels, value, tsMs);
            ingestUseCase.execute(cmd);
            writeJson(res, `{"status":"success"}`, HTTPStatus.created);
        } catch (Exception ex) {
            writeError(res, "bad_data", ex.msg, HTTPStatus.badRequest);
        }
    }

    // ── helpers ───────────────────────────────────────────────────────────────

    private Tenant* authenticate(HTTPServerRequest req, HTTPServerResponse res) {
        auto xToken = req.headers.get("X-Auth-Token", "");
        auto authHdr = req.headers.get("Authorization", "");
        auto tenant  = authUseCase.fromHeaders(xToken, authHdr);
        if (tenant is null) {
            writeJson(res,
                `{"status":"error","errorType":"unauthorized","error":"missing or invalid authentication token"}`,
                HTTPStatus.unauthorized);
        }
        return tenant;
    }

    private void writeSuccess(HTTPServerResponse res, Json data) {
        auto obj = Json.emptyObject;
        obj["status"] = Json("success");
        obj["data"]   = data;
        res.writeBody(obj.toString(), cast(int) HTTPStatus.ok, "application/json");
    }

    private void writeError(HTTPServerResponse res, string errType, string msg, HTTPStatus status) {
        auto obj = Json.emptyObject;
        obj["status"]    = Json("error");
        obj["errorType"] = Json(errType);
        obj["error"]     = Json(msg);
        res.writeBody(obj.toString(), cast(int) status, "application/json");
    }

    private void writeJson(HTTPServerResponse res, string body_, HTTPStatus status) {
        res.writeBody(body_, cast(int) status, "application/json");
    }

    private Json labelsToJson(in string[string] labels) {
        auto obj = Json.emptyObject;
        foreach (k, v; labels) obj[k] = Json(v);
        return obj;
    }

    private string[] splitPathAfterPrefix(string requestPath, string prefix) {
        if (!requestPath.startsWith(prefix)) return [];
        return split(requestPath[prefix.length .. $], "/");
    }
}
