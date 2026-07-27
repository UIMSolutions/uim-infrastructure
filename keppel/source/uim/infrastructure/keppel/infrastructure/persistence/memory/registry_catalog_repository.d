/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.infrastructure.keppel.infrastructure.persistence.memory.registry_catalog_repository;

import core.sync.mutex : Mutex;
import std.datetime : Clock;
import uim.infrastructure.keppel.domain.entities.repository : Repository;
import uim.infrastructure.keppel.domain.entities.image_tag : ImageTag;
import uim.infrastructure.keppel.domain.entities.manifest : Manifest;
import uim.infrastructure.keppel.domain.entities.blob : Blob;
import uim.infrastructure.keppel.domain.ports.repositories.registry_catalog : IRegistryCatalogRepository;

struct RepositoryManifestMap {
    string repositoryName;
    Manifest[] manifests;
}

struct RepositoryBlobMap {
    string repositoryName;
    Blob[] blobs;
}

class InMemoryRegistryCatalogRepository : IRegistryCatalogRepository {
    private Repository[] repositories;
    private RepositoryManifestMap[] manifestMaps;
    private RepositoryBlobMap[] blobMaps;
    private Mutex mutex;

    this() {
        mutex = new Mutex;
    }

    override void save(in Repository repository) {
        synchronized (mutex) {
            foreach (i, ref existing; repositories) {
                if (existing.name == repository.name) {
                    repositories[i] = copyRepository(repository);
                    return;
                }
            }
            repositories ~= copyRepository(repository);
        }
    }

    override bool exists(string name) {
        synchronized (mutex) {
            foreach (ref r; repositories) {
                if (r.name == name) return true;
            }
            return false;
        }
    }

    override Repository[] list(string projectId = "") {
        synchronized (mutex) {
            if (projectId.length == 0) return repositories.dup;
            Repository[] result;
            foreach (r; repositories) {
                if (r.projectId == projectId) result ~= r;
            }
            return result;
        }
    }

    override Repository* findByName(string name) {
        synchronized (mutex) {
            foreach (ref r; repositories) {
                if (r.name == name) return &r;
            }
            return null;
        }
    }

    override bool remove(string name) {
        synchronized (mutex) {
            Repository[] filtered;
            bool removed = false;
            foreach (r; repositories) {
                if (r.name == name) {
                    removed = true;
                    continue;
                }
                filtered ~= r;
            }
            repositories = filtered;
            return removed;
        }
    }

    override bool upsertTag(string repositoryName, in ImageTag tag) {
        synchronized (mutex) {
            foreach (ref r; repositories) {
                if (r.name != repositoryName) continue;

                bool updated = false;
                foreach (i, ref existing; r.tags) {
                    if (existing.name == tag.name) {
                        r.tags[i] = copyTag(tag);
                        updated = true;
                        break;
                    }
                }
                if (!updated) {
                    r.tags ~= copyTag(tag);
                }
                r.updatedAt = Clock.currTime.toISOExtString();
                return true;
            }
            return false;
        }
    }

    override ImageTag[] listTags(string repositoryName) {
        synchronized (mutex) {
            foreach (ref r; repositories) {
                if (r.name == repositoryName) {
                    return r.tags.dup;
                }
            }
            return [];
        }
    }

    override bool deleteTag(string repositoryName, string tagName) {
        synchronized (mutex) {
            foreach (ref r; repositories) {
                if (r.name != repositoryName) continue;

                ImageTag[] filtered;
                bool removed = false;
                foreach (tag; r.tags) {
                    if (tag.name == tagName) {
                        removed = true;
                        continue;
                    }
                    filtered ~= tag;
                }
                if (removed) {
                    r.tags = filtered;
                    r.updatedAt = Clock.currTime.toISOExtString();
                }
                return removed;
            }
            return false;
        }
    }

    override bool upsertManifest(string repositoryName, string reference, in Manifest manifest) {
        synchronized (mutex) {
            if (!exists(repositoryName)) return false;

            foreach (ref map; manifestMaps) {
                if (map.repositoryName != repositoryName) continue;

                foreach (i, ref existing; map.manifests) {
                    if (existing.reference == reference) {
                        map.manifests[i] = copyManifest(manifest);
                        return true;
                    }
                }

                map.manifests ~= copyManifest(manifest);
                return true;
            }

            RepositoryManifestMap map;
            map.repositoryName = repositoryName;
            map.manifests ~= copyManifest(manifest);
            manifestMaps ~= map;
            return true;
        }
    }

    override Manifest* findManifest(string repositoryName, string reference) {
        synchronized (mutex) {
            foreach (ref map; manifestMaps) {
                if (map.repositoryName != repositoryName) continue;
                foreach (ref manifest; map.manifests) {
                    if (manifest.reference == reference || manifest.digest == reference) {
                        return &manifest;
                    }
                }
            }
            return null;
        }
    }

    override bool upsertBlob(string repositoryName, in Blob blob) {
        synchronized (mutex) {
            if (!exists(repositoryName)) return false;

            foreach (ref map; blobMaps) {
                if (map.repositoryName != repositoryName) continue;

                foreach (i, ref existing; map.blobs) {
                    if (existing.digest == blob.digest) {
                        map.blobs[i] = copyBlob(blob);
                        return true;
                    }
                }

                map.blobs ~= copyBlob(blob);
                return true;
            }

            RepositoryBlobMap map;
            map.repositoryName = repositoryName;
            map.blobs ~= copyBlob(blob);
            blobMaps ~= map;
            return true;
        }
    }

    override Blob* findBlob(string repositoryName, string digest) {
        synchronized (mutex) {
            foreach (ref map; blobMaps) {
                if (map.repositoryName != repositoryName) continue;
                foreach (ref blob; map.blobs) {
                    if (blob.digest == digest) {
                        return &blob;
                    }
                }
            }
            return null;
        }
    }

    private Repository copyRepository(in Repository src) {
        Repository dst;
        dst.name = src.name;
        dst.projectId = src.projectId;
        dst.visibility = src.visibility;
        dst.createdAt = src.createdAt;
        dst.updatedAt = src.updatedAt;
        dst.tags = src.tags.dup;
        return dst;
    }

    private ImageTag copyTag(in ImageTag src) {
        ImageTag dst;
        dst.name = src.name;
        dst.digest = src.digest;
        dst.sizeBytes = src.sizeBytes;
        dst.mediaType = src.mediaType;
        dst.createdAt = src.createdAt;
        return dst;
    }

    private Manifest copyManifest(in Manifest src) {
        Manifest dst;
        dst.reference = src.reference;
        dst.digest = src.digest;
        dst.mediaType = src.mediaType;
        dst.content = src.content;
        dst.createdAt = src.createdAt;
        return dst;
    }

    private Blob copyBlob(in Blob src) {
        Blob dst;
        dst.digest = src.digest;
        dst.mediaType = src.mediaType;
        dst.sizeBytes = src.sizeBytes;
        dst.payloadBase64 = src.payloadBase64;
        dst.createdAt = src.createdAt;
        return dst;
    }
}
