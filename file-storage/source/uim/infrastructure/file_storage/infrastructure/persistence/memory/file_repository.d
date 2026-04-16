module fs_service.infrastructure.persistence.memory.file_repository;

import core.sync.mutex : Mutex;
import fs_service.domain.entities.stored_file : StoredFile;
import fs_service.domain.ports.repositories.file : IFileRepository;

class InMemoryFileRepository : IFileRepository {
    private StoredFile[] files;
    private Mutex mutex;

    this() {
        mutex = new Mutex;
    }

    override void save(StoredFile file) {
        synchronized (mutex) {
            foreach (i, ref f; files) {
                if (f.id == file.id) {
                    files[i] = file;
                    return;
                }
            }
            files ~= file;
        }
    }

    override void remove(string id) {
        synchronized (mutex) {
            StoredFile[] remaining;
            foreach (f; files) {
                if (f.id != id) {
                    remaining ~= f;
                }
            }
            files = remaining;
        }
    }

    override StoredFile[] list() {
        synchronized (mutex) {
            return files.dup;
        }
    }

    override StoredFile* findById(string id) {
        synchronized (mutex) {
            foreach (ref f; files) {
                if (f.id == id) {
                    // Heap-copy so the returned pointer survives after the
                    // synchronized block and any later array reallocation.
                    auto copy = new StoredFile(f.id, f.name, f.contentType, f.size, f.createdAt, f.data.dup);
                    return copy;
                }
            }
            return null;
        }
    }
}

unittest {
    import std.datetime : Clock;

    auto repo = new InMemoryFileRepository();
    repo.save(StoredFile("id1", "a.txt", "text/plain", 3, Clock.currTime(), cast(ubyte[]) "abc"));
    repo.save(StoredFile("id2", "b.txt", "text/plain", 3, Clock.currTime(), cast(ubyte[]) "xyz"));

    assert(repo.list().length == 2);

    auto found = repo.findById("id1");
    assert(found !is null);
    assert(found.name == "a.txt");

    repo.remove("id1");
    assert(repo.list().length == 1);
    assert(repo.list()[0].id == "id2");
    assert(repo.findById("id1") is null);
}
