module fs_service.domain.ports.repositories.file;

import fs_service.domain.entities.stored_file : StoredFile;

interface IFileRepository {
    void     save(StoredFile file);
    void     remove(string id);
    StoredFile[]    list();
    StoredFile* findById(string id);
}
