module uim.infrastructure.keppel.domain.entities.blob;

struct Blob {
    string digest;
    string mediaType;
    long sizeBytes;
    string payloadBase64;
    string createdAt;
}
