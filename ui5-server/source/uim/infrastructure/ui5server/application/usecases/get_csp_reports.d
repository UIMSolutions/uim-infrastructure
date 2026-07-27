/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.infrastructure.ui5server.application.usecases.get_csp_reports;

import uim.infrastructure.ui5server.domain.ports.repositories.csp_report : ICspReportRepository;
import uim.infrastructure.ui5server.application.dtos.csp : CspReportDTO, CspReportsResponseDTO;

class GetCspReportsUseCase {
    private ICspReportRepository repo;

    this(ICspReportRepository repo) {
        this.repo = repo;
    }

    CspReportsResponseDTO execute() {
        CspReportDTO[] reports;
        foreach (r; repo.findAll()) {
            reports ~= CspReportDTO(
                r.id,
                r.documentUri,
                r.violatedDirective,
                r.blockedUri,
                r.originalPolicy,
                r.timestamp,
            );
        }
        return CspReportsResponseDTO(reports, repo.count());
    }
}
