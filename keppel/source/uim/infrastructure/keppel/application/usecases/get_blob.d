/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
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
