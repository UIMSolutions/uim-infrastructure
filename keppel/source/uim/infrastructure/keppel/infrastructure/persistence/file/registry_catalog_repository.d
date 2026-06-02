module uim.infrastructure.keppel.infrastructure.persistence.file.registry_catalog_repository;

import core.sync.mutex : Mutex;
import std.file : fileExists = exists, readText, write, mkdirRecurse;
import std.path : dirName;
import std.datetime : Clock;
import vibe.data.json : serializeToJsonString, parseJsonString, deserializeJson;
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

struct StorageModel {
    Repository[] repositories;
    RepositoryManifestMap[] manifestMaps;
    RepositoryBlobMap[] blobMaps;
}

class FileRegistryCatalogRepository : IRegistryCatalogRepository {
    private string filePath;
    private Mutex mutex;
    private StorageModel data;

    this(string filePath) {
        this.filePath = filePath;
        this.mutex = new Mutex;
        load();
    }

    override void save(in Repository repository) {
        synchronized (mutex) {
            foreach (i, ref existing; data.repositories) {
                if (existing.name == repository.name) {
                    data.repositories[i] = copyRepository(repository);
                    persist();
                    return;
                }
            }
            data.repositories ~= copyRepository(repository);
            persist();
        }
    }

    override bool exists(string name) {
        synchronized (mutex) {
            foreach (ref r; data.repositories) {
                if (r.name == name) return true;
            }
            return false;
        }
    }

    override Repository[] list(string projectId = "") {
        synchronized (mutex) {
            if (projectId.length == 0) return data.repositories.dup;
            Repository[] result;
            foreach (r; data.repositories) {
                if (r.projectId == projectId) result ~= r;
            }
            return result;
        }
    }

    override Repository* findByName(string name) {
        synchronized (mutex) {
            foreach (ref r; data.repositories) {
                if (r.name == name) return &r;
            }
            return null;
        }
    }

    override bool remove(string name) {
        synchronized (mutex) {
            Repository[] filtered;
            bool removed = false;
            foreach (r; data.repositories) {
                if (r.name == name) {
                    removed = true;
                    continue;
                }
                filtered ~= r;
            }
            data.repositories = filtered;
            if (removed) persist();
            return removed;
        }
    }

    override bool upsertTag(string repositoryName, in ImageTag tag) {
        synchronized (mutex) {
            foreach (ref r; data.repositories) {
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
                persist();
                return true;
            }
            return false;
        }
    }

    override ImageTag[] listTags(string repositoryName) {
        synchronized (mutex) {
            foreach (ref r; data.repositories) {
                if (r.name == repositoryName) return r.tags.dup;
            }
            return [];
        }
    }

    override bool deleteTag(string repositoryName, string tagName) {
        synchronized (mutex) {
            foreach (ref r; data.repositories) {
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
                    persist();
                }
                return removed;
            }
            return false;
        }
    }

    override bool upsertManifest(string repositoryName, string reference, in Manifest manifest) {
        synchronized (mutex) {
            if (!exists(repositoryName)) return false;

            foreach (ref map; data.manifestMaps) {
                if (map.repositoryName != repositoryName) continue;

                foreach (i, ref existing; map.manifests) {
                    if (existing.reference == reference) {
                        map.manifests[i] = copyManifest(manifest);
                        persist();
                        return true;
                    }
                }

                map.manifests ~= copyManifest(manifest);
                persist();
                return true;
            }

            RepositoryManifestMap map;
            map.repositoryName = repositoryName;
            map.manifests ~= copyManifest(manifest);
            data.manifestMaps ~= map;
            persist();
            return true;
        }
    }

    override Manifest* findManifest(string repositoryName, string reference) {
        synchronized (mutex) {
            foreach (ref map; data.manifestMaps) {
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

            foreach (ref map; data.blobMaps) {
                if (map.repositoryName != repositoryName) continue;

                foreach (i, ref existing; map.blobs) {
                    if (existing.digest == blob.digest) {
                        map.blobs[i] = copyBlob(blob);
                        persist();
                        return true;
                    }
                }

                map.blobs ~= copyBlob(blob);
                persist();
                return true;
            }

            RepositoryBlobMap map;
            map.repositoryName = repositoryName;
            map.blobs ~= copyBlob(blob);
            data.blobMaps ~= map;
            persist();
            return true;
        }
    }

    override Blob* findBlob(string repositoryName, string digest) {
        synchronized (mutex) {
            foreach (ref map; data.blobMaps) {
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

    private void load() {
        synchronized (mutex) {
            if (!fileExists(filePath)) {
                data = StorageModel([], [], []);
                return;
            }

            auto raw = readText(filePath);
            if (raw.length == 0) {
                data = StorageModel([], [], []);
                return;
            }

            try {
                auto j = parseJsonString(raw);
                deserializeJson(data, j);
            } catch (Exception) {
                data = StorageModel([], [], []);
            }
        }
    }

    private void persist() {
        auto parent = dirName(filePath);
        if (parent.length > 0 && parent != ".") {
            mkdirRecurse(parent);
        }

        auto payload = serializeToJsonString(data);
        write(filePath, payload);
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
