# UIM Kafka Service

Cloud-native event streaming service inspired by [Apache Kafka](https://kafka.apache.org/), built with **vibe.d** and **D** using a combination of clean and hexagonal architecture.

## Overview

This service provides a REST API for managing Kafka-like event streaming concepts:

- **Topics** - Named channels for organizing event streams, with configurable partitioning and replication
- **Records** - Events with key, value, timestamp, and optional headers
- **Partitions** - Ordered, append-only logs within topics; records with the same key go to the same partition
- **Consumer Groups** - Named groups of consumers that coordinate consumption and track offsets
- **Brokers** - Server nodes forming the cluster
- **Offsets** - Positions within partitions, tracked per consumer group

## Architecture

```
Clean + Hexagonal Architecture

Domain Layer (entities + port interfaces)
    |
Application Layer (use cases + DTOs)
    |
Infrastructure Layer
    +-- Inbound:  HTTP Controller (vibe.d REST API)
    +-- Outbound: In-Memory Repositories (thread-safe with Mutex)
    |
Composition Root (app.d wires everything)
```

## API Endpoints

### Health
| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/health` | Health check |

### Topics
| Method | Endpoint | Description |
|--------|----------|-------------|
| POST | `/api/v1/topics` | Create a topic |
| GET | `/api/v1/topics` | List all topics |
| GET | `/api/v1/topics/{name}` | Get topic by name |
| DELETE | `/api/v1/topics/{name}` | Delete a topic |

### Records (Produce/Consume)
| Method | Endpoint | Description |
|--------|----------|-------------|
| POST | `/api/v1/records` | Produce a record to a topic |
| GET | `/api/v1/records/{topic}?partition=0&offset=0&maxRecords=10` | Consume records |

### Consumer Groups
| Method | Endpoint | Description |
|--------|----------|-------------|
| POST | `/api/v1/consumer-groups` | Create a consumer group |
| GET | `/api/v1/consumer-groups` | List all consumer groups |
| DELETE | `/api/v1/consumer-groups/{groupId}` | Delete a consumer group |

### Offsets
| Method | Endpoint | Description |
|--------|----------|-------------|
| POST | `/api/v1/offsets` | Commit an offset |
| GET | `/api/v1/offsets/{groupId}?topic={topic}` | Get committed offsets |

### Brokers
| Method | Endpoint | Description |
|--------|----------|-------------|
| POST | `/api/v1/brokers` | Register a broker |
| GET | `/api/v1/brokers` | List all brokers |

## Example Usage

### Create a Topic
```bash
curl -X POST http://localhost:8080/api/v1/topics \
  -H "Content-Type: application/json" \
  -d '{"name":"payments","numPartitions":4,"replicationFactor":3}'
```

### Produce a Record
```bash
curl -X POST http://localhost:8080/api/v1/records \
  -H "Content-Type: application/json" \
  -d '{"topic":"payments","key":"alice","value":"Made a payment of 200 to Bob","headers":{"source":"payment-service"}}'
```

### Consume Records
```bash
curl "http://localhost:8080/api/v1/records/payments?partition=0&offset=0&maxRecords=10"
```

### Create a Consumer Group
```bash
curl -X POST http://localhost:8080/api/v1/consumer-groups \
  -H "Content-Type: application/json" \
  -d '{"groupId":"payment-processors"}'
```

### Commit an Offset
```bash
curl -X POST http://localhost:8080/api/v1/offsets \
  -H "Content-Type: application/json" \
  -d '{"groupId":"payment-processors","topic":"payments","partition":0,"offset":5}'
```

### Register a Broker
```bash
curl -X POST http://localhost:8080/api/v1/brokers \
  -H "Content-Type: application/json" \
  -d '{"id":1,"host":"kafka-0.kafka.svc","port":9092,"rack":"rack-a"}'
```

## Build and Run

### Local
```bash
cd kafka
dub build
./uim-kafka-service
```

### Docker
```bash
docker build -t uim-kafka-service .
docker run -p 8080:8080 uim-kafka-service
```

### Podman
```bash
podman build -t uim-kafka-service -f Containerfile .
podman run -p 8080:8080 uim-kafka-service
```

### Kubernetes
```bash
kubectl apply -f k8s/namespace.yaml
kubectl apply -f k8s/configmap.yaml
kubectl apply -f k8s/deployment.yaml
kubectl apply -f k8s/service.yaml
```

## Project Structure

```
kafka/
  dub.sdl
  Dockerfile
  Containerfile
  README.md
  k8s/
    namespace.yaml
    configmap.yaml
    deployment.yaml
    service.yaml
  source/
    app.d                          # Composition root
    uim/infrastructure/kafka/
      domain/
        entities/
          topic.d                  # Topic entity with config and status
          record.d                 # Record (event) with key, value, headers
          partition.d              # Partition info
          consumer_group.d         # Consumer group with member assignments
          broker.d                 # Broker node
        ports/
          repositories/
            topic.d                # ITopicRepository
            record.d               # IRecordRepository
            consumer_group.d       # IConsumerGroupRepository
            broker.d               # IBrokerRepository
      application/
        dtos/
          topic.d                  # Create/Update/Response DTOs
          record.d                 # Produce/Response DTOs
          consumer_group.d         # Create/Response/Offset DTOs
          broker.d                 # Register/Update/Response DTOs
        usecases/
          create_topic.d
          list_topics.d
          get_topic.d
          delete_topic.d
          produce_record.d         # Partition assignment by key hash
          consume_records.d
          create_consumer_group.d
          list_consumer_groups.d
          delete_consumer_group.d
          commit_offset.d
          get_offsets.d
          register_broker.d
          list_brokers.d
      infrastructure/
        adapters/
          http/
            controller.d           # REST API routes
          inmemory/
            topic_repository.d
            record_repository.d
            consumer_group_repository.d
            broker_repository.d
```

## Key Kafka Concepts Modeled

- **Event streaming**: Records are appended to partitioned topic logs and retained (not deleted on consumption)
- **Partitioning**: Records with the same key hash to the same partition, ensuring ordering per key
- **Consumer groups**: Coordinate consumption; track committed offsets per partition
- **Multi-producer/multi-consumer**: Topics accept writes from any producer and reads from any consumer
- **Broker registry**: Track cluster nodes with host, port, rack, and status

## License

Apache-2.0
