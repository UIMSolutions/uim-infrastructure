module uim.infrastructure.ui5server.domain.ports.repositories.csp_report;

import uim.infrastructure.ui5server.domain.entities.csp_policy : CspReport;

interface ICspReportRepository {
    bool save(CspReport report);
    CspReport[] findAll();
    CspReport[] findByDocumentUri(string uri);
    bool clear();
    ulong count();
}
