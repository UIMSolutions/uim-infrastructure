module uim.infrastructure.kafka.application.usecases.produce_record;

import std.conv : to;
import std.digest.crc : crc32Of;
import uim.infrastructure.kafka.domain.entities.record;
import uim.infrastructure.kafka.domain.entities.topic : Topic;
import uim.infrastructure.kafka.domain.ports.repositories.record : IRecordRepository;
import uim.infrastructure.kafka.domain.ports.repositories.topic : ITopicRepository;
import uim.infrastructure.kafka.application.dtos.record;

class ProduceRecordUseCase {
    private IRecordRepository recordRepo;
    private ITopicRepository topicRepo;

    this(IRecordRepository recordRepo, ITopicRepository topicRepo) {
        this.recordRepo = recordRepo;
        this.topicRepo = topicRepo;
    }

    RecordResponseDTO execute(in ProduceRecordDTO dto) {
        auto topic = topicRepo.findByName(dto.topic);
        if (topic is null) {
            throw new Exception("Topic '" ~ dto.topic ~ "' does not exist");
        }

        auto partition = assignPartition(dto.key, topic.config.numPartitions);

        Header[] headers;
        foreach (k, v; dto.headers) {
            headers ~= Header(k, v);
        }

        auto timestamp = currentTimestampMs();

        auto rec = Record(
            dto.topic,
            partition,
            0,
            dto.key,
            dto.value,
            timestamp,
            headers,
        );

        auto offset = recordRepo.append(dto.topic, partition, rec);

        string[string] respHeaders;
        foreach (h; headers) {
            respHeaders[h.key] = h.value;
        }

        return RecordResponseDTO(
            dto.topic,
            partition,
            offset,
            dto.key,
            dto.value,
            timestamp,
            respHeaders,
        );
    }

    private uint assignPartition(string key, uint numPartitions) {
        if (numPartitions == 0) return 0;
        if (key.length == 0) return 0;
        auto hash = crc32Of(cast(const(ubyte)[]) key);
        uint h = (cast(uint) hash[0]) | (cast(uint) hash[1] << 8)
            | (cast(uint) hash[2] << 16) | (cast(uint) hash[3] << 24);
        return h % numPartitions;
    }

    private long currentTimestampMs() {
        import core.time : MonoTime;
        return MonoTime.currTime.ticks / 1_000;
    }
}
