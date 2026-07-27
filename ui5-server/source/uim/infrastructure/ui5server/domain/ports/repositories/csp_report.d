/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.infrastructure.ui5server.domain.ports.repositories.csp_report;

import uim.infrastructure.ui5server.domain.entities.csp_policy : CspReport;

interface ICspReportRepository {
    bool save(CspReport report);
    CspReport[] findAll();
    CspReport[] findByDocumentUri(string uri);
    bool clear();
    ulong count();
}
