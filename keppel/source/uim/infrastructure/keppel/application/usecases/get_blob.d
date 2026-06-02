module uim.infrastructure.keppel.application.usecases.get_blob;

import std.base64 : Base64;
import uim.infrastructure.keppel.domain.entities.blob : Blob;
import uim.infrastructure.keppel.domain.ports.repositories.registry_catalog : IRegistryCatalogRepository;

struct BlobPayload {
    Blob meta;
    ubyte[] payload;
}

class GetBlobUseCase {
    private IRegistryCatalogRepository repository;

    this(IRegistryCatalogRepository repository) {
        this.repository = repository;
    }

    BlobPayload execute(string repositoryName, string digest) {
        auto ptr = repository.findBlob(repositoryName, digest);
        if (ptr is null) {
            throw new Exception("blob not found");
        }

        auto payload = Base64.decode(ptr.payloadBase64);
        return BlobPayload(*ptr, payload);
    }
}
