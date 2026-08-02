module uim.infrastructure.hts_service.domain.entities.hts_record;

enum HtsFormat {
    sam,
    vcf,
    fastq
}

struct HtsRecord {
    string id;
    string datasetId;
    HtsFormat format;
    string referenceName;
    long position;
    string sampleName;
    string payload;
}

struct IngestSummary {
    string datasetId;
    HtsFormat format;
    size_t totalRecords;
}
