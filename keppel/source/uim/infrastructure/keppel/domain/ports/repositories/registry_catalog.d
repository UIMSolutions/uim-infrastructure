/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.infrastructure.keppel.domain.ports.repositories.registry_catalog;

import uim.infrastructure.keppel.domain.entities.repository : Repository;
import uim.infrastructure.keppel.domain.entities.image_tag : ImageTag;
import uim.infrastructure.keppel.domain.entities.manifest : Manifest;
import uim.infrastructure.keppel.domain.entities.blob : Blob;

interface IRegistryCatalogRepository {
    void save(in Repository repository);
    bool exists(string name);
    Repository[] list(string projectId = "");
    Repository* findByName(string name);
    bool remove(string name);

    bool upsertTag(string repositoryName, in ImageTag tag);
    ImageTag[] listTags(string repositoryName);
    bool deleteTag(string repositoryName, string tagName);

    bool upsertManifest(string repositoryName, string reference, in Manifest manifest);
    Manifest* findManifest(string repositoryName, string reference);

    bool upsertBlob(string repositoryName, in Blob blob);
    Blob* findBlob(string repositoryName, string digest);
}
