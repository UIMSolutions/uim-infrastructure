module uim.infrastructure.odata.infrastructure.adapters.inmemory.function_import_repository;

import core.sync.mutex : Mutex;
import uim.infrastructure.odata.domain.entities.function_import : FunctionImport;
import uim.infrastructure.odata.domain.ports.repositories.function_import : IFunctionImportRepository;

class InMemoryFunctionImportRepository : IFunctionImportRepository {
    private FunctionImport[string] funcs;
    private Mutex mtx;

    this() {
        mtx = new Mutex();
    }

    void save(in FunctionImport func) {
        mtx.lock();
        scope(exit) mtx.unlock();
        funcs[func.name] = cast(FunctionImport) func;
    }

    FunctionImport[] list() {
        mtx.lock();
        scope(exit) mtx.unlock();
        return funcs.values;
    }

    FunctionImport* findByName(string name) {
        mtx.lock();
        scope(exit) mtx.unlock();
        auto p = name in funcs;
        if (p is null) return null;
        return p;
    }

    void deleteByName(string name) {
        mtx.lock();
        scope(exit) mtx.unlock();
        funcs.remove(name);
    }
}
