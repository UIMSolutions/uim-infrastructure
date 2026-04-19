module app;

import vibe.http.router : URLRouter;
import vibe.http.server : HTTPServerSettings;
import vibe.core.core : runApplication;

import uim.infrastructure.kafka.infrastructure.adapters.inmemory.topic_repository : InMemoryTopicRepository;
import uim.infrastructure.kafka.infrastructure.adapters.inmemory.record_repository : InMemoryRecordRepository;
import uim.infrastructure.kafka.infrastructure.adapters.inmemory.consumer_group_repository : InMemoryConsumerGroupRepository;
import uim.infrastructure.kafka.infrastructure.adapters.inmemory.broker_repository : InMemoryBrokerRepository;

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

import uim.infrastructure.kafka.infrastructure.adapters.http.controller : KafkaController;

void main() {
    // --- Outbound adapters (repositories) ---
    auto topicRepo = new InMemoryTopicRepository();
    auto recordRepo = new InMemoryRecordRepository();
    auto consumerGroupRepo = new InMemoryConsumerGroupRepository();
    auto brokerRepo = new InMemoryBrokerRepository();

    // --- Application use cases ---
    auto createTopicUC = new CreateTopicUseCase(topicRepo);
    auto listTopicsUC = new ListTopicsUseCase(topicRepo);
    auto getTopicUC = new GetTopicUseCase(topicRepo);
    auto deleteTopicUC = new DeleteTopicUseCase(topicRepo);
    auto produceRecordUC = new ProduceRecordUseCase(recordRepo, topicRepo);
    auto consumeRecordsUC = new ConsumeRecordsUseCase(recordRepo);
    auto createConsumerGroupUC = new CreateConsumerGroupUseCase(consumerGroupRepo);
    auto listConsumerGroupsUC = new ListConsumerGroupsUseCase(consumerGroupRepo);
    auto deleteConsumerGroupUC = new DeleteConsumerGroupUseCase(consumerGroupRepo);
    auto commitOffsetUC = new CommitOffsetUseCase(consumerGroupRepo);
    auto getOffsetsUC = new GetOffsetsUseCase(consumerGroupRepo);
    auto registerBrokerUC = new RegisterBrokerUseCase(brokerRepo);
    auto listBrokersUC = new ListBrokersUseCase(brokerRepo);

    // --- Inbound adapter (HTTP controller) ---
    auto controller = new KafkaController(
        createTopicUC,
        listTopicsUC,
        getTopicUC,
        deleteTopicUC,
        produceRecordUC,
        consumeRecordsUC,
        createConsumerGroupUC,
        listConsumerGroupsUC,
        deleteConsumerGroupUC,
        commitOffsetUC,
        getOffsetsUC,
        registerBrokerUC,
        listBrokersUC,
    );

    auto router = new URLRouter();
    controller.registerRoutes(router);

    auto settings = new HTTPServerSettings();
    settings.port = 8080;
    settings.bindAddresses = ["0.0.0.0"];

    auto listener = listenHTTP(settings, router);
    scope(exit) listener.stopListening();

    import vibe.core.log : logInfo;
    logInfo("UIM Kafka Service running on http://0.0.0.0:8080");

    runApplication();
}

private auto listenHTTP(HTTPServerSettings settings, URLRouter router) {
    import vibe.http.server : listenHTTP;
    return listenHTTP(settings, router);
}
