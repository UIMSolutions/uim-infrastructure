module uim.infrastructure.dlang_formatter_service.domain.ports.formatter.formatter_gateway;

import uim.infrastructure.dlang_formatter_service.domain.entities.format_result :
    FormatRequest, FormatResult, FormatterProfile;

interface IFormatterGateway {
    FormatResult format(FormatRequest request, FormatterProfile profile);
}
