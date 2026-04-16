module bs_service.infrastructure.persistence.memory.block_volume_repository;

import core.sync.mutex : Mutex;
import bs_service.domain.entities.block_volume : BlockVolume;
import bs_service.domain.ports.repositories.block_volume : IBlockVolumeRepository;

class InMemoryBlockVolumeRepository : IBlockVolumeRepository {
    private BlockVolume[] volumes;
    private Mutex mutex;

    this() {
        mutex = new Mutex;
    }

    override void save(BlockVolume volume) {
        synchronized (mutex) {
            foreach (i, ref v; volumes) {
                if (v.id == volume.id) {
                    volumes[i] = volume;
                    return;
                }
            }
            volumes ~= volume;
        }
    }

    override void remove(string id) {
        synchronized (mutex) {
            BlockVolume[] remaining;
            foreach (v; volumes) {
                if (v.id != id) {
                    remaining ~= v;
                }
            }
            volumes = remaining;
        }
    }

    override BlockVolume[] list() {
        synchronized (mutex) {
            return volumes.dup;
        }
    }

    override BlockVolume* findById(string id) {
        synchronized (mutex) {
            foreach (ref v; volumes) {
                if (v.id == id) {
                    // Heap-copy so the returned pointer survives after the
                    // synchronized block and any later array reallocation.
                    auto copy = new BlockVolume(
                        v.id, v.name, v.sizeGiB, v.state,
                        v.attachedToInstanceId, v.createdAt
                    );
                    return copy;
                }
            }
            return null;
        }
    }
}

unittest {
    import std.datetime : Clock;
    import bs_service.domain.entities.block_volume : VolumeState;

    auto repo = new InMemoryBlockVolumeRepository();
    repo.save(BlockVolume("vol-1", "alpha", 50,  VolumeState.available, "", Clock.currTime()));
    repo.save(BlockVolume("vol-2", "beta",  100, VolumeState.available, "", Clock.currTime()));

    assert(repo.list().length == 2);

    auto found = repo.findById("vol-1");
    assert(found !is null);
    assert(found.name == "alpha");

    repo.remove("vol-1");
    assert(repo.list().length == 1);
    assert(repo.list()[0].id == "vol-2");
    assert(repo.findById("vol-1") is null);
}
