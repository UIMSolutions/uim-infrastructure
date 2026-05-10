module uim.infrastructure.maia.domain.ports.repositories.time_series;

import uim.infrastructure.maia.domain.entities.label_matcher : LabelMatcher;
import uim.infrastructure.maia.domain.entities.sample : Sample;
import uim.infrastructure.maia.domain.entities.tenant : Tenant;
import uim.infrastructure.maia.domain.entities.time_series : TimeSeries;

/// Hexagonal port: driven-side contract for time-series storage.
interface ITimeSeriesRepository {
    /// Find or create a time series by its exact label set; returns its ID.
    string ensureTimeSeries(string[string] labels);

    /// List time series whose labels all satisfy the given matchers, scoped to tenant.
    /// Tenant isolation: project-scoped tenants see only series with matching project_id;
    /// domain-scoped tenants see series with matching domain_id.
    TimeSeries[] listSeries(LabelMatcher[] matchers, Tenant tenant);

    /// Persist a sample.
    void saveSample(in Sample sample);

    /// For each series ID return its most recent sample (at or before atMs).
    Sample[] getLatestSamples(string[] seriesIds, long atMs);

    /// Return all samples for the given series IDs within [startMs, endMs].
    Sample[] getRangeSamples(string[] seriesIds, long startMs, long endMs);

    /// Return all distinct label names visible to the tenant.
    string[] listLabels(Tenant tenant);

    /// Return all distinct values for labelName visible to the tenant.
    string[] listLabelValues(string labelName, Tenant tenant);
}
