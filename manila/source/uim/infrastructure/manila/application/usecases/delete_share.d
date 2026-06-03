module uim.infrastructure.manila.application.usecases.delete_share;

import uim.infrastructure.manila.domain.ports.repositories.share : IShareRepository;
import uim.infrastructure.manila.domain.ports.repositories.snapshot : ISnapshotRepository;

class DeleteShareUseCase {
    private IShareRepository shareRepository;
    private ISnapshotRepository snapshotRepository;

    this(IShareRepository shareRepository, ISnapshotRepository snapshotRepository) {
        this.shareRepository = shareRepository;
        this.snapshotRepository = snapshotRepository;
    }

    void execute(string id) {
        if (id.length == 0) {
            throw new Exception("share id must not be empty");
        }
        if (shareRepository.findById(id) is null) {
            throw new Exception("share not found");
        }
        snapshotRepository.removeByShareId(id);
        shareRepository.remove(id);
    }
}