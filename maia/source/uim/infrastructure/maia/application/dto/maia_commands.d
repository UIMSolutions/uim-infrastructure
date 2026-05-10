module uim.infrastructure.maia.application.dto.maia_commands;

/// Command to push a single metric sample into the store.
struct IngestSampleCommand {
    string[string] labels;      /// Must include "__name__"; should include "project_id" or "domain_id"
    double         value;
    long           timestampMs; /// Unix ms; 0 means "use current time"
}

/// Query for an instant (point-in-time) result.
struct InstantQueryCommand {
    string selector;   /// PromQL selector expression
    long   atMs;       /// Unix ms; 0 means "now"
}

/// Query for a range result.
struct RangeQueryCommand {
    string selector;
    long   startMs;
    long   endMs;
    long   stepMs; /// Resolution; ignored in the in-memory implementation
}

/// Query for listing matching time series.
struct ListSeriesCommand {
    string[] selectors; /// One or more PromQL selector expressions (match[])
    long     startMs;
    long     endMs;
}

/// Query for listing all known label names.
struct ListLabelsCommand {
    long startMs;
    long endMs;
}

/// Query for listing known values of a single label.
struct ListLabelValuesCommand {
    string labelName;
    long   startMs;
    long   endMs;
}
