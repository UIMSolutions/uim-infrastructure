module uim.infrastructure.dlang_formatter_service.infrastructure.formatter.process_formatter_gateway;

import uim.infrastructure.dlang_formatter_service.domain.entities.format_result :
    FormatRequest, FormatResult, FormatterProfile;
import uim.infrastructure.dlang_formatter_service.domain.ports.formatter.formatter_gateway :
    IFormatterGateway;
import std.array : appender;
import std.exception : collectException;
import std.file : exists, mkdirRecurse, readText, rmdirRecurse, tempDir, write;
import std.path : buildPath;
import std.process : execute;
import std.random : uniform;
import std.string : join;

class ProcessFormatterGateway : IFormatterGateway {
    override FormatResult format(FormatRequest request, FormatterProfile profile) {
        auto workspace = buildPath(tempDir(), "uim-dlang-formatter-" ~ randomSuffix());
        mkdirRecurse(workspace);

        scope (exit) {
            if (workspace.length > 0) {
                collectException(rmdirRecurse(workspace));
            }
        }

        auto sourcePath = buildPath(workspace, request.fileName);
        write(sourcePath, request.sourceCode);

        auto argList = profile.args ~ [sourcePath];
        auto command = [profile.executable] ~ argList;
        auto result = execute(command);

        string formattedCode;
        if (result.status == 0) {
            if (result.output.length > 0) {
                formattedCode = result.output;
            } else if (exists(sourcePath)) {
                // Support formatters that rewrite the file in place.
                formattedCode = readText(sourcePath);
            } else {
                formattedCode = request.sourceCode;
            }
        }

        return FormatResult(
            result.status == 0,
            result.status,
            formattedCode,
            result.output,
            "",
            join(command, " ")
        );
    }

    private string randomSuffix() {
        auto buffer = appender!string();
        foreach (_; 0 .. 8) {
            buffer.put(cast(char) ('a' + uniform(0, 26)));
        }
        return buffer.data;
    }
}
