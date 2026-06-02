module uim.infrastructure.keppel.domain.entities.image_tag;

struct ImageTag {
    string name;
    string digest;
    long sizeBytes;
    string mediaType;
    string createdAt;
}
