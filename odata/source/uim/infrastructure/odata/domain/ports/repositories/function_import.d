/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.infrastructure.odata.domain.ports.repositories.function_import;

import uim.infrastructure.odata.domain.entities.function_import : FunctionImport;

interface IFunctionImportRepository {
    void save(in FunctionImport func);
    FunctionImport[] list();
    FunctionImport* findByName(string name);
    void deleteByName(string name);
}
