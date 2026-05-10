module uim.infrastructure.maia.domain.entities.sample;

/// A single observed value for a time series at a point in time.
struct Sample {
    string timeSeriesId;
    double value;
    long   timestampMs; /// Unix epoch in milliseconds

    double timestampSec() const { return cast(double) timestampMs / 1000.0; }
}

unittest {
    auto s = Sample("ts1", 72.5, 1_620_000_000_000L);
    assert(s.timestampSec() == 1_620_000_000.0);
    assert(s.value          == 72.5);
}
