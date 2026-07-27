/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.infrastructure.metrics.infrastructure.http.controllers.metrics;

import uim.infrastructure.metrics.application.dto.metric_commands : GetSeriesQuery, QueryResourceQuery, RecordMetricCommand;
import uim.infrastructure.metrics.application.usecases.get_metric_series : GetMetricSeriesUseCase;
import uim.infrastructure.metrics.application.usecases.list_metrics : ListMetricsUseCase;
import uim.infrastructure.metrics.application.usecases.query_resource_metrics : QueryResourceMetricsUseCase;
import uim.infrastructure.metrics.application.usecases.record_metric : RecordMetricUseCase;
import uim.infrastructure.metrics.domain.entities.metric : Metric, MetricType, MetricUnit;
import uim.infrastructure.metrics.domain.entities.metric_data_point : MetricDataPoint;
import std.conv : to;
import std.string : split, startsWith;
import vibe.data.json : Json, serializeToJsonString;
import vibe.http.common : HTTPStatus;
import vibe.http.router : URLRouter;
import vibe.http.server : HTTPServerRequest, HTTPServerResponse;

struct MetricView {
    string id;
    string name;
    string resourceId;
    string type;
    string unit;
    string description;
}

struct DataPointView {
    string id;
    string metricId;
    string metricName;
    string resourceId;
    double value;
    string timestamp;
}

class MetricsController {
    private RecordMetricUseCase          recordUseCase;
    private ListMetricsUseCase           listUseCase;
    private GetMetricSeriesUseCase       seriesUseCase;
    private QueryResourceMetricsUseCase  resourceUseCase;

    this(
        RecordMetricUseCase          recordUseCase,
        ListMetricsUseCase           listUseCase,
        GetMetricSeriesUseCase       seriesUseCase,
        QueryResourceMetricsUseCase  resourceUseCase
    ) {
        this.recordUseCase   = recordUseCase;
        this.listUseCase     = listUseCase;
        this.seriesUseCase   = seriesUseCase;
        this.resourceUseCase = resourceUseCase;
    }

    void registerRoutes(URLRouter router) {
        router.get ("/health",            &health);
        router.get ("/v1/metrics",        &listMetrics);
        router.post("/v1/metrics",        &recordMetric);
        router.get ("/v1/metrics/*",      &handleMetricGet);
        router.get ("/v1/resources/*",    &queryResourceMetrics);
    }

    // GET /health
    void health(HTTPServerRequest req, HTTPServerResponse res) {
        writeJson(res, `{"status":"ok"}`, HTTPStatus.ok);
    }

    // GET /v1/metrics
    void listMetrics(HTTPServerRequest req, HTTPServerResponse res) {
        auto defs = listUseCase.execute();
        writeJson(res, serializeToJsonString(defsToViews(defs)), HTTPStatus.ok);
    }

    // POST /v1/metrics  (JSON body)
    void recordMetric(HTTPServerRequest req, HTTPServerResponse res) {
        auto body = req.json;
        if (body.type == Json.Type.undefined || body.type == Json.Type.null_) {
            writeJson(res, `{"error":"missing JSON body"}`, HTTPStatus.badRequest);
            return;
        }

        try {
            auto nameJson = body["name"];
            if (nameJson.type != Json.Type.string) {
                writeJson(res, `{"error":"name is required"}`, HTTPStatus.badRequest);
                return;
            }

            double value;
            auto vj = body["value"];
            if      (vj.type == Json.Type.float_) value = vj.get!double;
            else if (vj.type == Json.Type.int_)   value = cast(double) vj.get!long;
            else { writeJson(res, `{"error":"value must be numeric"}`, HTTPStatus.badRequest); return; }

            string unit       = body["unit"].type       == Json.Type.string ? body["unit"].get!string       : "";
            string metricType = body["type"].type       == Json.Type.string ? body["type"].get!string       : "gauge";
            string resourceId = body["resourceId"].type == Json.Type.string ? body["resourceId"].get!string : "";
            string desc       = body["description"].type == Json.Type.string ? body["description"].get!string : "";

            string[string] labels;
            auto lj = body["labels"];
            if (lj.type == Json.Type.object) {
                foreach (string k, Json v; lj) {
                    if (v.type == Json.Type.string) labels[k] = v.get!string;
                }
            }

            auto cmd   = RecordMetricCommand(nameJson.get!string, value, unit, metricType, resourceId, labels, desc);
            auto point = recordUseCase.execute(cmd);
            writeJson(res, serializeToJsonString(pointToView(point)), HTTPStatus.created);
        } catch (Exception ex) {
            writeJson(res, `{"error":"` ~ ex.msg ~ `"}`, HTTPStatus.badRequest);
        }
    }

    // GET /v1/metrics/<name>
    // GET /v1/metrics/<name>/<resourceId>
    void handleMetricGet(HTTPServerRequest req, HTTPServerResponse res) {
        auto segments = splitPathAfterPrefix(req.requestPath.to!string, "/v1/metrics/");
        if (segments.length == 0) {
            writeJson(res, `{"error":"expected /v1/metrics/<name>[/<resourceId>]"}`, HTTPStatus.badRequest);
            return;
        }

        try {
            auto query  = GetSeriesQuery(segments[0], segments.length >= 2 ? segments[1] : "");
            auto points = seriesUseCase.execute(query);
            writeJson(res, serializeToJsonString(pointsToViews(points)), HTTPStatus.ok);
        } catch (Exception ex) {
            writeJson(res, `{"error":"` ~ ex.msg ~ `"}`, HTTPStatus.badRequest);
        }
    }

    // GET /v1/resources/<resourceId>/metrics
    void queryResourceMetrics(HTTPServerRequest req, HTTPServerResponse res) {
        auto segments = splitPathAfterPrefix(req.requestPath.to!string, "/v1/resources/");
        // segments: ["<resourceId>", "metrics"]
        if (segments.length < 2 || segments[1] != "metrics") {
            writeJson(res, `{"error":"expected /v1/resources/<resourceId>/metrics"}`, HTTPStatus.badRequest);
            return;
        }

        try {
            auto query  = QueryResourceQuery(segments[0]);
            auto points = resourceUseCase.execute(query);
            writeJson(res, serializeToJsonString(pointsToViews(points)), HTTPStatus.ok);
        } catch (Exception ex) {
            writeJson(res, `{"error":"` ~ ex.msg ~ `"}`, HTTPStatus.badRequest);
        }
    }

    // ── helpers ───────────────────────────────────────────────────────────────

    private MetricView[] defsToViews(Metric[] defs) {
        MetricView[] views;
        foreach (m; defs) {
            views ~= MetricView(m.id, m.name, m.resourceId, m.type.to!string, m.unit.to!string, m.description);
        }
        return views;
    }

    private DataPointView pointToView(in MetricDataPoint p) {
        return DataPointView(p.id, p.metricId, p.metricName, p.resourceId, p.value, p.timestamp);
    }

    private DataPointView[] pointsToViews(MetricDataPoint[] points) {
        DataPointView[] views;
        foreach (p; points) views ~= pointToView(p);
        return views;
    }

    private string[] splitPathAfterPrefix(string requestPath, string prefix) {
        if (!requestPath.startsWith(prefix)) return [];
        return split(requestPath[prefix.length .. $], "/");
    }

    private void writeJson(HTTPServerResponse res, string body_, HTTPStatus status) {
        res.writeBody(body_, cast(int) status, "application/json");
    }
}
