module uim.infrastructure.dlang_formatter_service.infrastructure.http.views.html_renderer;

import uim.infrastructure.dlang_formatter_service.domain.entities.format_result :
    FormatResult, FormatterProfile;
import std.format : format;
import std.string : join, replace;

class HtmlRenderer {
    string renderHome(FormatterProfile[] profiles, string notice = "") {
        string profileRows;
        foreach (profile; profiles) {
            profileRows ~= format(
                "<tr><td>%s</td><td>%s</td><td>%s</td></tr>",
                escapeHtml(profile.name),
                escapeHtml(profile.executable),
                escapeHtml(profile.args.join(" "))
            );
        }

        if (profileRows.length == 0) {
            profileRows = "<tr><td colspan=\"3\">No profiles configured.</td></tr>";
        }

        string noticeMarkup;
        if (notice.length > 0) {
            noticeMarkup = "<p class=\"notice success\">" ~ escapeHtml(notice) ~ "</p>";
        }

        auto body = format(`
            <section>
                <h1>D Language Formatter Service</h1>
                <p>Format D source through API or browser while keeping Clean and Hexagonal boundaries.</p>
                %s
                <p>
                    <a class="btn" href="/format">Format Snippet</a>
                    <a class="btn secondary" href="/health">Health</a>
                </p>
                <table>
                    <thead><tr><th>Profile</th><th>Executable</th><th>Args</th></tr></thead>
                    <tbody>%s</tbody>
                </table>
            </section>
        `, noticeMarkup, profileRows);

        return layout("D Formatter Service", body);
    }

    string renderFormatForm(FormatterProfile[] profiles, string errorText = "", FormatResult* result = null) {
        string options;
        foreach (profile; profiles) {
            options ~= "<option value=\"" ~ escapeHtml(profile.name) ~ "\">"
                ~ escapeHtml(profile.name) ~ "</option>";
        }

        if (options.length == 0) {
            options = "<option value=\"default\">default</option>";
        }

        string feedback;
        if (errorText.length > 0) {
            feedback ~= "<p class=\"notice error\">" ~ escapeHtml(errorText) ~ "</p>";
        }

        if (result !is null) {
            auto statusText = result.success ? "Formatting succeeded" : "Formatting failed";
            feedback ~= "<p class=\"notice " ~ (result.success ? "success" : "error") ~ "\">"
                ~ escapeHtml(statusText) ~ " (exit=" ~ escapeHtml(format("%s", result.exitCode)) ~ ")</p>";
            feedback ~= "<h2>Command</h2><pre>" ~ escapeHtml(result.command) ~ "</pre>";
            feedback ~= "<h2>Formatted code</h2><pre>" ~ escapeHtml(result.formattedCode) ~ "</pre>";
            feedback ~= "<h2>stdout</h2><pre>" ~ escapeHtml(result.stdoutText) ~ "</pre>";
            feedback ~= "<h2>stderr</h2><pre>" ~ escapeHtml(result.stderrText) ~ "</pre>";
        }

        auto body = format(`
            <section>
                <h1>Format D Snippet</h1>
                %s
                <form method="post" action="/format">
                    <label>Profile</label>
                    <select name="profile">%s</select>
                    <label>File Name</label>
                    <input type="text" name="fileName" value="snippet.d" />
                    <label>Source Code</label>
                    <textarea name="sourceCode" rows="16">module snippet;

import std.stdio : writeln;

void main() {
    writeln( "hello from dlang" );
}
</textarea>
                    <button class="btn" type="submit">Format</button>
                </form>
            </section>
            <section>%s</section>
        `, feedback, options, feedback.length > 0 ? feedback : "<p>No formatting result yet.</p>");

        return layout("Format", body);
    }

    private string layout(string title, string body) {
        return format(`
<!doctype html>
<html lang="en">
<head>
  <meta charset="utf-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1" />
  <title>%s</title>
  <style>
        body {
            margin: 0;
            font-family: "IBM Plex Sans", "Segoe UI", sans-serif;
            background: linear-gradient(145deg, #f3f9ff 0%%, #fdf7ef 45%%, #edfdf4 100%%);
            color: #1a2333;
        }
        main {
            max-width: 1100px;
            margin: 2rem auto;
            padding: 0 1rem;
            display: grid;
            gap: 1rem;
        }
        section {
            background: #fff;
            border: 1px solid #d6deea;
            border-radius: 14px;
            box-shadow: 0 16px 36px rgba(21, 33, 52, 0.08);
            padding: 1.5rem;
        }
        table { width: 100%%; border-collapse: collapse; }
        th, td {
            text-align: left;
            border-bottom: 1px solid #e1e8f0;
            padding: 0.6rem;
            vertical-align: top;
        }
        label { display: block; margin: 0.8rem 0 0.2rem; font-weight: 600; }
        input, select, textarea {
            width: 100%%;
            box-sizing: border-box;
            border: 1px solid #bccad9;
            border-radius: 8px;
            padding: 0.55rem;
            font: inherit;
        }
        .btn {
            display: inline-block;
            background: #11437c;
            color: #fff;
            text-decoration: none;
            border: 0;
            border-radius: 8px;
            padding: 0.6rem 0.95rem;
            cursor: pointer;
            font: inherit;
            margin-top: 0.8rem;
        }
        .btn.secondary { background: #0f766e; }
        .notice { border-radius: 8px; padding: 0.7rem; font-weight: 600; }
        .notice.error { background: #fee2e2; color: #7f1d1d; }
        .notice.success { background: #dcfce7; color: #14532d; }
        pre {
            background: #0c1020;
            color: #ebefff;
            border-radius: 10px;
            padding: 1rem;
            overflow: auto;
            white-space: pre-wrap;
        }
  </style>
</head>
<body>
  <main>%s</main>
</body>
</html>
        `, escapeHtml(title), body);
    }

    private string escapeHtml(string value) {
        auto escaped = value.replace("&", "&amp;");
        escaped = escaped.replace("<", "&lt;");
        escaped = escaped.replace(">", "&gt;");
        escaped = escaped.replace("\"", "&quot;");
        escaped = escaped.replace("'", "&#39;");
        return escaped;
    }
}
