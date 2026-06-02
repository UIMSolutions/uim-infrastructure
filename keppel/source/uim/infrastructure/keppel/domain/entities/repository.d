module uim.infrastructure.keppel.domain.entities.repository;

import uim.infrastructure.keppel.domain.entities.image_tag : ImageTag;

enum RepositoryVisibility {
    private_,
    public_
}

struct Repository {
    string name;
    string projectId;
    RepositoryVisibility visibility;
    string createdAt;
    string updatedAt;
    ImageTag[] tags;
}
