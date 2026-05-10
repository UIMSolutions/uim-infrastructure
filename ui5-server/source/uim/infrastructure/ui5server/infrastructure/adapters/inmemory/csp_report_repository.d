module uim.infrastructure.ui5server.infrastructure.adapters.inmemory.csp_report_repository;

import core.sync.mutex : Mutex;
import uim.infrastructure.ui5server.domain.entities.csp_policy : CspReport;
import uim.infrastructure.ui5server.domain.ports.repositories.csp_report : ICspReportRepository;

class InMemoryCspReportRepository : ICspReportRepository {
    private CspReport[] store;
    private Mutex mtx;

    this() {
        mtx = new Mutex();
    }

    bool save(CspReport report) {
        mtx.lock();
        scope(exit) mtx.unlock();
        store ~= report;
        return true;
    }

    CspReport[] findAll() {
        mtx.lock();
        scope(exit) mtx.unlock();
        return store.dup;
    }

    CspReport[] findByDocumentUri(string uri) {
        mtx.lock();
        scope(exit) mtx.unlock();
        CspReport[] results;
        foreach (ref r; store) {
            if (r.documentUri == uri) results ~= r;
        }
        return results;
    }

    bool clear() {
        mtx.lock();
        scope(exit) mtx.unlock();
        store = [];
        return true;
    }

    ulong count() {
        mtx.lock();
        scope(exit) mtx.unlock();
        return store.length;
    }
}
