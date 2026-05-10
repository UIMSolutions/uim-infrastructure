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
