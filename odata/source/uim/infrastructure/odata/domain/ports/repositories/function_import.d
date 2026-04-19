module uim.infrastructure.odata.domain.ports.repositories.function_import;

import uim.infrastructure.odata.domain.entities.function_import : FunctionImport;

interface IFunctionImportRepository {
    void save(in FunctionImport func);
    FunctionImport[] list();
    FunctionImport* findByName(string name);
    void deleteByName(string name);
}
