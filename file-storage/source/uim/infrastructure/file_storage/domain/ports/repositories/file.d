/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module fs_service.domain.ports.repositories.file;

import fs_service.domain.entities.stored_file : StoredFile;

interface IFileRepository {
    void     save(StoredFile file);
    void     remove(string id);
    StoredFile[]    list();
    StoredFile* findById(string id);
}
