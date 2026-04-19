module uim.infrastructure.kafka.infrastructure.adapters.http.controller;

import std.conv : to;

import vibe.http.router : URLRouter;
import vibe.http.server : HTTPServerRequest, HTTPServerResponse;
import vibe.http.status : HTTPStatus;
import vibe.data.json : Json, parseJsonString;

import uim.infrastructure.kafka.application.usecases.create_topic : CreateTopicUseCase;
import uim.infrastructure.kafka.application.usecases.list_topics : ListTopicsUseCase;
import uim.infrastructure.kafka.application.usecases.get_topic : GetTopicUseCase;
import uim.infrastructure.kafka.application.usecases.delete_topic : DeleteTopicUseCase;
import uim.infrastructure.kafka.application.usecases.produce_record : ProduceRecordUseCase;
import uim.infrastructure.kafka.application.usecases.consume_records : ConsumeRecordsUseCase;
import uim.infrastructure.kafka.application.usecases.create_consumer_group : CreateConsumerGroupUseCase;
import uim.infrastructure.kafka.application.usecases.list_consumer_groups : ListConsumerGroupsUseCase;
import uim.infrastructure.kafka.application.usecases.delete_consumer_group : DeleteConsumerGroupUseCase;
import uim.infrastructure.kafka.application.usecases.commit_offset : CommitOffsetUseCase;
import uim.infrastructure.kafka.application.usecases.get_offsets : GetOffsetsUseCase;
import uim.infrastructure.kafka.application.usecases.register_broker : RegisterBrokerUseCase;
import uim.infrastructure.kafka.application.usecases.list_brokers : ListBrokersUseCase;

import uim.infrastructure.kafka.application.dtos.topic : CreateTopicDTO, TopicResponseDTO;
import uim.infrastructure.kafka.application.dtos.record : ProduceRecordDTO, RecordResponseDTO;
import uim.infrastructure.kafka.application.dtos.consumer_group : CreateConsumerGroupDTO,
    ConsumerGroupResponseDTO, CommitOffsetDTO, ConsumerOffsetResponseDTO;
import uim.infrastructure.kafka.application.dtos.broker : RegisterBrokerDTO, BrokerResponseDTO;

class KafkaController {
    private CreateTopicUseCase createTopicUC;
    private ListTopicsUseCase listTopicsUC;
    private GetTopicUseCase getTopicUC;
    private DeleteTopicUseCase deleteTopicUC;
    private ProduceRecordUseCase produceRecordUC;
    private ConsumeRecordsUseCase consumeRecordsUC;
    private CreateConsumerGroupUseCase createConsumerGroupUC;
    private ListConsumerGroupsUseCase listConsumerGroupsUC;
    private DeleteConsumerGroupUseCase deleteConsumerGroupUC;
    private CommitOffsetUseCase commitOffsetUC;
    private GetOffsetsUseCase getOffsetsUC;
    private RegisterBrokerUseCase registerBrokerUC;
    private ListBrokersUseCase listBrokersUC;

    this(
        CreateTopicUseCase createTopicUC,
        ListTopicsUseCase listTopicsUC,
        GetTopicUseCase getTopicUC,
        DeleteTopicUseCase deleteTopicUC,
        ProduceRecordUseCase produceRecordUC,
        ConsumeRecordsUseCase consumeRecordsUC,
        CreateConsumerGroupUseCase createConsumerGroupUC,
        ListConsumerGroupsUseCase listConsumerGroupsUC,
        DeleteConsumerGroupUseCase deleteConsumerGroupUC,
        CommitOffsetUseCase commitOffsetUC,
        GetOffsetsUseCase getOffsetsUC,
        RegisterBrokerUseCase registerBrokerUC,
        ListBrokersUseCase listBrokersUC,
    ) {
        this.createTopicUC = createTopicUC;
        this.listTopicsUC = listTopicsUC;
        this.getTopicUC = getTopicUC;
        this.deleteTopicUC = deleteTopicUC;
        this.produceRecordUC = produceRecordUC;
        this.consumeRecordsUC = consumeRecordsUC;
        this.createConsumerGroupUC = createConsumerGroupUC;
        this.listConsumerGroupsUC = listConsumerGroupsUC;
        this.deleteConsumerGroupUC = deleteConsumerGroupUC;
        this.commitOffsetUC = commitOffsetUC;
        this.getOffsetsUC = getOffsetsUC;
        this.registerBrokerUC = registerBrokerUC;
        this.listBrokersUC = listBrokersUC;
    }

    void registerRoutes(URLRouter router) {
        router.get("/health", &healthCheck);

        // Topics
        router.post("/api/v1/topics", &createTopic);
        router.get("/api/v1/topics", &listTopics);
        router.get("/api/v1/topics/*", &getTopic);
        router.delete_("/api/v1/topics/*", &deleteTopic);

        // Records
        router.post("/api/v1/records", &produceRecord);
        router.get("/api/v1/records/*", &consumeRecords);

        // Consumer Groups
        router.post("/api/v1/consumer-groups", &createConsumerGroup);
        router.get("/api/v1/consumer-groups", &listConsumerGroups);
        router.delete_("/api/v1/consumer-groups/*", &deleteConsumerGroup);

        // Offsets
        router.post("/api/v1/offsets", &commitOffset);
        router.get("/api/v1/offsets/*", &getOffsets);

        // Brokers
        router.post("/api/v1/brokers", &registerBroker);
        router.get("/api/v1/brokers", &listBrokers);
    }

    // --- Health ---

    void healthCheck(HTTPServerRequest req, HTTPServerResponse res) {
        auto json = Json.emptyObject;
        json["status"] = "healthy";
        json["service"] = "uim-kafka-service";
        res.writeBody(json.toString(), cast(int) HTTPStatus.ok, "application/json");
    }

    // --- Topics ---

    void createTopic(HTTPServerRequest req, HTTPServerResponse res) {
        try {
            auto j = req.json;
            if (j.type == Json.Type.undefined) {
                res.writeBody(`{"error":"Request body required"}`, cast(int) HTTPStatus.badRequest, "application/json");
                return;
            }
            auto dto = CreateTopicDTO(
                j["name"].get!string,
                j["numPartitions"].type != Json.Type.undefined ? j["numPartitions"].get!uint : 1,
                j["replicationFactor"].type != Json.Type.undefined ? j["replicationFactor"].get!uint : 1,
                j["retentionMs"].type != Json.Type.undefined ? j["retentionMs"].get!long : 604_800_000,
                j["retentionBytes"].type != Json.Type.undefined ? j["retentionBytes"].get!long : -1,
                j["cleanupPolicy"].type != Json.Type.undefined ? j["cleanupPolicy"].get!string : "delete",
            );
            auto result = createTopicUC.execute(dto);
            res.writeBody(topicToJson(result).toString(), cast(int) HTTPStatus.created, "application/json");
        } catch (Exception e) {
            auto err = Json.emptyObject;
            err["error"] = e.msg;
            res.writeBody(err.toString(), cast(int) HTTPStatus.badRequest, "application/json");
        }
    }

    void listTopics(HTTPServerRequest req, HTTPServerResponse res) {
        auto results = listTopicsUC.execute();
        auto arr = Json.emptyArray;
        foreach (t; results) arr ~= topicToJson(t);
        res.writeBody(arr.toString(), cast(int) HTTPStatus.ok, "application/json");
    }

    void getTopic(HTTPServerRequest req, HTTPServerResponse res) {
        auto path = req.requestURI;
        auto name = extractLastSegment(path);
        if (name.length == 0) {
            res.writeBody(`{"error":"Topic name required"}`, cast(int) HTTPStatus.badRequest, "application/json");
            return;
        }
        auto result = getTopicUC.execute(name);
        if (result is null) {
            res.writeBody(`{"error":"Topic not found"}`, cast(int) HTTPStatus.notFound, "application/json");
            return;
        }
        res.writeBody(topicToJson(*result).toString(), cast(int) HTTPStatus.ok, "application/json");
    }

    void deleteTopic(HTTPServerRequest req, HTTPServerResponse res) {
        auto path = req.requestURI;
        auto name = extractLastSegment(path);
        if (deleteTopicUC.execute(name)) {
            res.writeBody(`{"status":"deleted"}`, cast(int) HTTPStatus.ok, "application/json");
        } else {
            res.writeBody(`{"error":"Topic not found"}`, cast(int) HTTPStatus.notFound, "application/json");
        }
    }

    // --- Records ---

    void produceRecord(HTTPServerRequest req, HTTPServerResponse res) {
        try {
            auto j = req.json;
            if (j.type == Json.Type.undefined) {
                res.writeBody(`{"error":"Request body required"}`, cast(int) HTTPStatus.badRequest, "application/json");
                return;
            }
            string[string] headers;
            if (j["headers"].type != Json.Type.undefined && j["headers"].type == Json.Type.object) {
                foreach (string k, v; j["headers"]) {
                    headers[k] = v.get!string;
                }
            }
            auto dto = ProduceRecordDTO(
                j["topic"].get!string,
                j["key"].type != Json.Type.undefined ? j["key"].get!string : "",
                j["value"].get!string,
                headers,
            );
            auto result = produceRecordUC.execute(dto);
            res.writeBody(recordToJson(result).toString(), cast(int) HTTPStatus.created, "application/json");
        } catch (Exception e) {
            auto err = Json.emptyObject;
            err["error"] = e.msg;
            res.writeBody(err.toString(), cast(int) HTTPStatus.badRequest, "application/json");
        }
    }

    void consumeRecords(HTTPServerRequest req, HTTPServerResponse res) {
        auto path = req.requestURI;
        auto topicName = extractLastSegment(path);
        uint partition = 0;
        long offset = 0;
        uint maxRecords = 10;
        try {
            auto qp = req.queryParams();
            foreach (p; qp) {
                if (p[0] == "partition") partition = p[1].to!uint;
                else if (p[0] == "offset") offset = p[1].to!long;
                else if (p[0] == "maxRecords") maxRecords = p[1].to!uint;
            }
        } catch (Exception e) {
            // use defaults
        }
        auto results = consumeRecordsUC.execute(topicName, partition, offset, maxRecords);
        auto arr = Json.emptyArray;
        foreach (r; results) arr ~= recordToJson(r);
        res.writeBody(arr.toString(), cast(int) HTTPStatus.ok, "application/json");
    }

    // --- Consumer Groups ---

    void createConsumerGroup(HTTPServerRequest req, HTTPServerResponse res) {
        try {
            auto j = req.json;
            if (j.type == Json.Type.undefined) {
                res.writeBody(`{"error":"Request body required"}`, cast(int) HTTPStatus.badRequest, "application/json");
                return;
            }
            auto dto = CreateConsumerGroupDTO(j["groupId"].get!string);
            auto result = createConsumerGroupUC.execute(dto);
            res.writeBody(consumerGroupToJson(result).toString(), cast(int) HTTPStatus.created, "application/json");
        } catch (Exception e) {
            auto err = Json.emptyObject;
            err["error"] = e.msg;
            res.writeBody(err.toString(), cast(int) HTTPStatus.badRequest, "application/json");
        }
    }

    void listConsumerGroups(HTTPServerRequest req, HTTPServerResponse res) {
        auto results = listConsumerGroupsUC.execute();
        auto arr = Json.emptyArray;
        foreach (g; results) arr ~= consumerGroupToJson(g);
        res.writeBody(arr.toString(), cast(int) HTTPStatus.ok, "application/json");
    }

    void deleteConsumerGroup(HTTPServerRequest req, HTTPServerResponse res) {
        auto path = req.requestURI;
        auto groupId = extractLastSegment(path);
        if (deleteConsumerGroupUC.execute(groupId)) {
            res.writeBody(`{"status":"deleted"}`, cast(int) HTTPStatus.ok, "application/json");
        } else {
            res.writeBody(`{"error":"Consumer group not found"}`, cast(int) HTTPStatus.notFound, "application/json");
        }
    }

    // --- Offsets ---

    void commitOffset(HTTPServerRequest req, HTTPServerResponse res) {
        try {
            auto j = req.json;
            if (j.type == Json.Type.undefined) {
                res.writeBody(`{"error":"Request body required"}`, cast(int) HTTPStatus.badRequest, "application/json");
                return;
            }
            auto dto = CommitOffsetDTO(
                j["groupId"].get!string,
                j["topic"].get!string,
                j["partition"].get!uint,
                j["offset"].get!long,
            );
            if (commitOffsetUC.execute(dto)) {
                res.writeBody(`{"status":"committed"}`, cast(int) HTTPStatus.ok, "application/json");
            } else {
                res.writeBody(`{"error":"Consumer group not found"}`, cast(int) HTTPStatus.notFound, "application/json");
            }
        } catch (Exception e) {
            auto err = Json.emptyObject;
            err["error"] = e.msg;
            res.writeBody(err.toString(), cast(int) HTTPStatus.badRequest, "application/json");
        }
    }

    void getOffsets(HTTPServerRequest req, HTTPServerResponse res) {
        auto path = req.requestURI;
        auto groupId = extractLastSegment(path);
        string topic = "";
        try {
            auto qp = req.queryParams();
            foreach (p; qp) {
                if (p[0] == "topic") topic = p[1];
            }
        } catch (Exception e) {
            // ignore
        }
        auto results = getOffsetsUC.execute(groupId, topic);
        auto arr = Json.emptyArray;
        foreach (o; results) {
            auto j = Json.emptyObject;
            j["groupId"] = o.groupId;
            j["topic"] = o.topic;
            j["partition"] = o.partition;
            j["committedOffset"] = o.committedOffset;
            j["logEndOffset"] = o.logEndOffset;
            j["lag"] = o.lag;
            arr ~= j;
        }
        res.writeBody(arr.toString(), cast(int) HTTPStatus.ok, "application/json");
    }

    // --- Brokers ---

    void registerBroker(HTTPServerRequest req, HTTPServerResponse res) {
        try {
            auto j = req.json;
            if (j.type == Json.Type.undefined) {
                res.writeBody(`{"error":"Request body required"}`, cast(int) HTTPStatus.badRequest, "application/json");
                return;
            }
            auto dto = RegisterBrokerDTO(
                j["id"].get!uint,
                j["host"].get!string,
                j["port"].type != Json.Type.undefined ? j["port"].get!ushort : 9092,
                j["rack"].type != Json.Type.undefined ? j["rack"].get!string : "",
            );
            auto result = registerBrokerUC.execute(dto);
            res.writeBody(brokerToJson(result).toString(), cast(int) HTTPStatus.created, "application/json");
        } catch (Exception e) {
            auto err = Json.emptyObject;
            err["error"] = e.msg;
            res.writeBody(err.toString(), cast(int) HTTPStatus.badRequest, "application/json");
        }
    }

    void listBrokers(HTTPServerRequest req, HTTPServerResponse res) {
        auto results = listBrokersUC.execute();
        auto arr = Json.emptyArray;
        foreach (b; results) arr ~= brokerToJson(b);
        res.writeBody(arr.toString(), cast(int) HTTPStatus.ok, "application/json");
    }

    // --- JSON helpers ---

    private Json topicToJson(in TopicResponseDTO t) {
        auto j = Json.emptyObject;
        j["name"] = t.name;
        j["numPartitions"] = t.numPartitions;
        j["replicationFactor"] = t.replicationFactor;
        j["retentionMs"] = t.retentionMs;
        j["retentionBytes"] = t.retentionBytes;
        j["cleanupPolicy"] = t.cleanupPolicy;
        j["status"] = t.status;
        j["createdAt"] = t.createdAt;
        return j;
    }

    private Json recordToJson(in RecordResponseDTO r) {
        auto j = Json.emptyObject;
        j["topic"] = r.topic;
        j["partition"] = r.partition;
        j["offset"] = r.offset;
        j["key"] = r.key;
        j["value"] = r.value;
        j["timestamp"] = r.timestamp;
        auto h = Json.emptyObject;
        foreach (k, v; r.headers) {
            h[k] = v;
        }
        j["headers"] = h;
        return j;
    }

    private Json consumerGroupToJson(in ConsumerGroupResponseDTO g) {
        auto j = Json.emptyObject;
        j["groupId"] = g.groupId;
        j["state"] = g.state;
        j["memberCount"] = g.memberCount;
        j["createdAt"] = g.createdAt;
        return j;
    }

    private Json brokerToJson(in BrokerResponseDTO b) {
        auto j = Json.emptyObject;
        j["id"] = b.id;
        j["host"] = b.host;
        j["port"] = b.port;
        j["status"] = b.status;
        j["rack"] = b.rack;
        j["startedAt"] = b.startedAt;
        return j;
    }

    private string extractLastSegment(string path) {
        import std.string : indexOf;
        // Remove query string
        auto qIdx = path.indexOf('?');
        if (qIdx >= 0) path = path[0 .. qIdx];
        // Remove trailing slash
        if (path.length > 0 && path[$ - 1] == '/') path = path[0 .. $ - 1];
        // Find last slash
        auto idx = path.lastIndexOf('/');
        if (idx < 0) return path;
        return path[idx + 1 .. $];
    }

    private long lastIndexOf(string s, char c) {
        for (long i = cast(long) s.length - 1; i >= 0; i--) {
            if (s[cast(size_t) i] == c) return i;
        }
        return -1;
    }
}
