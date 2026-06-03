module uim.infrastructure.manila.application.usecases.get_quota_set;

import uim.infrastructure.manila.domain.entities.quota_set : QuotaSet;
import uim.infrastructure.manila.domain.ports.repositories.share : IShareRepository;
import uim.infrastructure.manila.domain.ports.repositories.snapshot : ISnapshotRepository;

class GetQuotaSetUseCase {
    private enum uint defaultMaxShares = 50;
    private enum ulong defaultMaxShareGiB = 1024;
    private enum uint defaultMaxSnapshots = 100;

    private IShareRepository shareRepository;
    private ISnapshotRepository snapshotRepository;

    this(IShareRepository shareRepository, ISnapshotRepository snapshotRepository) {
        this.shareRepository = shareRepository;
        this.snapshotRepository = snapshotRepository;
    }

    QuotaSet execute(string projectId) {
        if (projectId.length == 0) {
            throw new Exception("project id must not be empty");
        }

        auto shares = shareRepository.listByProject(projectId);
        auto snapshots = snapshotRepository.listByProject(projectId);

        ulong usedShareGiB;
        foreach (share; shares) {
            usedShareGiB += share.sizeGiB;
        }

        return QuotaSet(
            projectId,
            defaultMaxShares,
            defaultMaxShareGiB,
            defaultMaxSnapshots,
            cast(uint) shares.length,
            usedShareGiB,
            cast(uint) snapshots.length
        );
    }
}