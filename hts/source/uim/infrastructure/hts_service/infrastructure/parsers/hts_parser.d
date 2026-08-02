module uim.infrastructure.hts_service.infrastructure.parsers.hts_parser;

import uim.infrastructure.hts_service.domain.entities.hts_record : HtsFormat,
    HtsRecord;
import uim.infrastructure.hts_service.domain.ports.parsers.hts_parser : IHtsParser;
import std.array : split;
import std.conv : to;
import std.exception : collectException;
import std.string : splitLines, strip;

class BasicHtsParser : IHtsParser {
    override HtsRecord[] parse(string datasetId, HtsFormat format, string rawContent) {
        final switch (format) {
            case HtsFormat.sam:
                return parseSam(datasetId, rawContent);
            case HtsFormat.vcf:
                return parseVcf(datasetId, rawContent);
            case HtsFormat.fastq:
                return parseFastq(datasetId, rawContent);
        }
    }

    private HtsRecord[] parseSam(string datasetId, string raw) {
        HtsRecord[] records;

        foreach (line; raw.splitLines()) {
            auto clean = line.strip();
            if (clean.length == 0 || clean[0] == '@') {
                continue;
            }

            auto fields = clean.split("\t");
            if (fields.length < 4) {
                continue;
            }

            records ~= HtsRecord(
                fields[0].idup,
                datasetId,
                HtsFormat.sam,
                fields[2].idup,
                toLong(fields[3]),
                "",
                clean.idup
            );
        }

        return records;
    }

    private HtsRecord[] parseVcf(string datasetId, string raw) {
        HtsRecord[] records;

        foreach (line; raw.splitLines()) {
            auto clean = line.strip();
            if (clean.length == 0 || clean[0] == '#') {
                continue;
            }

            auto fields = clean.split("\t");
            if (fields.length < 3) {
                continue;
            }

            auto sample = fields.length > 9 ? fields[9] : "";
            records ~= HtsRecord(
                fields[2].length > 0 ? fields[2].idup : fields[0] ~ ":" ~ fields[1],
                datasetId,
                HtsFormat.vcf,
                fields[0].idup,
                toLong(fields[1]),
                sample.idup,
                clean.idup
            );
        }

        return records;
    }

    private HtsRecord[] parseFastq(string datasetId, string raw) {
        HtsRecord[] records;
        auto lines = raw.splitLines();

        size_t i;
        while (i + 3 < lines.length) {
            auto header = lines[i].strip();
            auto sequence = lines[i + 1].strip();
            auto plus = lines[i + 2].strip();
            auto quality = lines[i + 3].strip();
            i += 4;

            if (header.length == 0 || header[0] != '@') {
                continue;
            }
            if (plus.length == 0 || plus[0] != '+') {
                continue;
            }

            auto id = header[1 .. $];
            records ~= HtsRecord(
                id.idup,
                datasetId,
                HtsFormat.fastq,
                "read",
                cast(long) records.length + 1,
                "",
                (header ~ "\n" ~ sequence ~ "\n" ~ plus ~ "\n" ~ quality).idup
            );
        }

        return records;
    }

    private long toLong(string value) {
        long parsed;
        auto err = collectException(parsed = value.to!long);
        return err is null ? parsed : -1;
    }
}
