/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
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