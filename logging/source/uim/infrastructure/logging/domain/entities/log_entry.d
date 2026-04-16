module log_service.domain.entities.log_entry;

import std.conv : to;
import std.string : toUpper;

enum LogLevel {
    DEBUG,
    INFO,
    WARNING,
    ERROR,
    CRITICAL
}

struct LogEntry {
    string   id;
    LogLevel level;
    string   message;
    string   service;
    string   timestamp;
}

LogLevel parseLogLevel(string rawLevel) {
    auto normalized = rawLevel.toUpper();
    foreach (candidate; __traits(allMembers, LogLevel)) {
        if (candidate == normalized) {
            return to!LogLevel(normalized);
        }
    }
    throw new Exception("Unsupported log level: " ~ rawLevel);
}

unittest {
    assert(parseLogLevel("info")     == LogLevel.INFO);
    assert(parseLogLevel("ERROR")    == LogLevel.ERROR);
    assert(parseLogLevel("debug")    == LogLevel.DEBUG);
    assert(parseLogLevel("WARNING")  == LogLevel.WARNING);
    assert(parseLogLevel("critical") == LogLevel.CRITICAL);

    LogEntry entry = LogEntry("1", LogLevel.INFO, "started", "my-service", "2026-01-01T00:00:00Z");
    assert(entry.service == "my-service");
    assert(entry.level   == LogLevel.INFO);
}
