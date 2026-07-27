/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module fs_service.application.usecases.download_file;

import fs_service.application.dto.file_command : DownloadFileQuery;
import fs_service.domain.entities.stored_file : StoredFile;
import fs_service.domain.ports.repositories.file : IFileRepository;

class DownloadFileUseCase {
    private IFileRepository repository;

    this(IFileRepository repository) {
        this.repository = repository;
    }

    /// Returns a pointer to the matching file, or null when not found.
    StoredFile* execute(in DownloadFileQuery query) {
        if (query.id.length == 0) {
            throw new Exception("id must not be empty");
        }
        return repository.findById(query.id);
    }
}
