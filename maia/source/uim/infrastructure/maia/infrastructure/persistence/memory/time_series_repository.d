/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.infrastructure.maia.infrastructure.persistence.memory.time_series_repository;

import core.sync.mutex : Mutex;
import uim.infrastructure.maia.domain.entities.label_matcher : LabelMatcher, MatchOp;
import uim.infrastructure.maia.domain.entities.sample : Sample;
import uim.infrastructure.maia.domain.entities.tenant : Tenant;
import uim.infrastructure.maia.domain.entities.time_series : TimeSeries;
import uim.infrastructure.maia.domain.ports.repositories.time_series : ITimeSeriesRepository;
import std.algorithm : sort, uniq, canFind;
import std.array : array;
import std.uuid : randomUUID;

class InMemoryTimeSeriesRepository : ITimeSeriesRepository {
    private TimeSeries[] seriesList;
    private Sample[]     samples;
    private Mutex        mutex;

    this() { mutex = new Mutex; }

    override string ensureTimeSeries(string[string] labels) {
        synchronized (mutex) {
            foreach (ref ts; seriesList) {
                if (labelsEqual(ts.labels, labels)) return ts.id;
            }
            auto newId = randomUUID().toString();
            seriesList ~= TimeSeries(newId, labels.dup);
            return newId;
        }
    }

    override TimeSeries[] listSeries(LabelMatcher[] matchers, Tenant tenant) {
        synchronized (mutex) {
            TimeSeries[] result;
            foreach (ts; seriesList) {
                if (!visibleToTenant(ts, tenant)) continue;
                if (matchesAll(ts, matchers)) result ~= ts;
            }
            return result;
        }
    }

    override void saveSample(in Sample sample) {
        synchronized (mutex) {
            samples ~= sample;
        }
    }

    override Sample[] getLatestSamples(string[] seriesIds, long atMs) {
        synchronized (mutex) {
            Sample[] result;
            foreach (id; seriesIds) {
                long bestTs = long.min;
                bool found  = false;
                Sample best;
                foreach (s; samples) {
                    if (s.timeSeriesId == id && s.timestampMs <= atMs && s.timestampMs > bestTs) {
                        bestTs = s.timestampMs;
                        best   = s;
                        found  = true;
                    }
                }
                if (found) result ~= best;
            }
            return result;
        }
    }

    override Sample[] getRangeSamples(string[] seriesIds, long startMs, long endMs) {
        synchronized (mutex) {
            Sample[] result;
            foreach (s; samples) {
                if (s.timestampMs >= startMs && s.timestampMs <= endMs
                        && canFind(seriesIds, s.timeSeriesId)) {
                    result ~= s;
                }
            }
            return result;
        }
    }

    override string[] listLabels(Tenant tenant) {
        synchronized (mutex) {
            bool[string] seen;
            foreach (ts; seriesList) {
                if (!visibleToTenant(ts, tenant)) continue;
                foreach (k, _; ts.labels) seen[k] = true;
            }
            auto keys = seen.keys.dup;
            keys.sort();
            return keys;
        }
    }

    override string[] listLabelValues(string labelName, Tenant tenant) {
        synchronized (mutex) {
            bool[string] seen;
            foreach (ts; seriesList) {
                if (!visibleToTenant(ts, tenant)) continue;
                if (auto v = labelName in ts.labels) seen[*v] = true;
            }
            auto vals = seen.keys.dup;
            vals.sort();
            return vals;
        }
    }

    // ── helpers ──────────────────────────────────────────────────────────────

    private static bool labelsEqual(in string[string] a, in string[string] b) {
        if (a.length != b.length) return false;
        foreach (k, v; a) {
            auto p = k in b;
            if (p is null || *p != v) return false;
        }
        return true;
    }

    private static bool visibleToTenant(in TimeSeries ts, in Tenant tenant) {
        if (tenant.isProjectScoped()) {
            auto p = "project_id" in ts.labels;
            return p !is null && *p == tenant.projectId;
        }
        if (tenant.isDomainScoped()) {
            auto d = "domain_id" in ts.labels;
            return d !is null && *d == tenant.domainId;
        }
        return true; // no scoping → see everything (e.g. admin)
    }

    private static bool matchesAll(in TimeSeries ts, in LabelMatcher[] matchers) {
        foreach (m; matchers) {
            if (m.label.length == 0) continue;
            auto v = m.label in ts.labels;
            string actual = v !is null ? *v : "";
            if (!m.matches(actual)) return false;
        }
        return true;
    }
}

unittest {
    auto repo = new InMemoryTimeSeriesRepository();

    auto id1 = repo.ensureTimeSeries(["__name__": "up", "project_id": "p1", "job": "os"]);
    auto id2 = repo.ensureTimeSeries(["__name__": "up", "project_id": "p2", "job": "os"]);
    auto id1b = repo.ensureTimeSeries(["__name__": "up", "project_id": "p1", "job": "os"]);
    assert(id1 == id1b, "same labels must return same id");
    assert(id1 != id2);

    repo.saveSample(Sample(id1, 1.0, 1_620_000_000_000L));
    repo.saveSample(Sample(id2, 0.0, 1_620_000_000_000L));

    auto t1 = Tenant("p1", "");
    auto seriesP1 = repo.listSeries([], t1);
    assert(seriesP1.length == 1);
    assert(seriesP1[0].id == id1);

    auto latest = repo.getLatestSamples([id1], 1_620_000_001_000L);
    assert(latest.length == 1 && latest[0].value == 1.0);

    assert(repo.listLabels(t1).length > 0);
    auto vals = repo.listLabelValues("project_id", t1);
    assert(vals.length == 1 && vals[0] == "p1");
}
