module uim.infrastructure.cds_service.infrastructure.http.views.html_renderer;

import uim.infrastructure.cds_service.domain.entities.cds_definition : CdsDefinition, CdsField;
import std.datetime.systime : SysTime;
import std.format : format;
import std.string : replace;

class HtmlRenderer {
    string renderDefinitions(CdsDefinition[] definitions, string notice = "") {
        string rows;
        foreach (definition; definitions) {
            rows ~= format(
                "<tr><td><a href=\"/definitions/%s\">%s</a></td><td>%s</td><td>%s</td><td>%s</td></tr>",
                escapeHtml(definition.id),
                escapeHtml(definition.name),
                escapeHtml(definition.namespaceName),
                escapeHtml(definition.modelVersion),
                escapeHtml(toTimestamp(definition.createdAt))
            );
        }

        if (rows.length == 0) {
            rows = "<tr><td colspan=\"5\">No definitions available.</td></tr>";
        }

        string noticeMarkup;
        if (notice.length > 0) {
            noticeMarkup = "<p class=\"notice\">" ~ escapeHtml(notice) ~ "</p>";
        }

        auto body = format(`
            <section>
                <h1>CDS Definition Catalog</h1>
                <p>Create and inspect Core Data Services style models.</p>
                %s
                <p>
                    <a class="btn" href="/definitions/new">New Definition</a>
                    <a class="btn secondary" href="/health">Health</a>
                </p>
                <table>
                    <thead>
                        <tr>
                            <th>Name</th>
                            <th>Namespace</th>
                            <th>Version</th>
                            <th>Created</th>
                            <th>State</th>
                        </tr>
                    </thead>
                    <tbody>%s</tbody>
                </table>
            </section>
        `,
            noticeMarkup,
            decorateRows(definitions, rows)
        );

        return layout("CDS Definitions", body);
    }

    string renderCreateForm(string defaultNamespace, string defaultVersion, string errorText = "", string successText = "") {
        string notices;
        if (errorText.length > 0) {
            notices ~= "<p class=\"notice error\">" ~ escapeHtml(errorText) ~ "</p>";
        }
        if (successText.length > 0) {
            notices ~= "<p class=\"notice success\">" ~ escapeHtml(successText) ~ "</p>";
        }

        auto body = format(`
            <section>
                <h1>Create CDS Definition</h1>
                %s
                <form method="post" action="/definitions/new">
                    <label>Namespace</label>
                    <input type="text" name="namespace" value="%s" required />

                    <label>Name</label>
                    <input type="text" name="name" placeholder="Books" required />

                    <label>Version</label>
                    <input type="text" name="modelVersion" value="%s" />

                    <label>Deprecated</label>
                    <select name="deprecated">
                      <option value="false" selected>false</option>
                      <option value="true">true</option>
                    </select>

                    <label>Fields</label>
                    <textarea name="fields" rows="8" placeholder="ID:UUID:key\ntitle:String:required\ncreatedAt:Timestamp" required></textarea>
                    <p class="hint">Format: name:type[:key][:required]. Without required, field is nullable.</p>

                    <button type="submit" class="btn">Create Definition</button>
                </form>
            </section>
        `, notices, escapeHtml(defaultNamespace), escapeHtml(defaultVersion));

        return layout("Create Definition", body);
    }

    string renderDefinitionDetail(CdsDefinition definition, string cdsSource) {
        auto body = format(`
            <section>
                <h1>%s</h1>
                <dl class="details">
                    <dt>ID</dt><dd>%s</dd>
                    <dt>Namespace</dt><dd>%s</dd>
                    <dt>Version</dt><dd>%s</dd>
                    <dt>Deprecated</dt><dd>%s</dd>
                    <dt>Created</dt><dd>%s</dd>
                </dl>

                <h2>Fields</h2>
                <table>
                    <thead>
                        <tr><th>Name</th><th>Type</th><th>Key</th><th>Nullable</th></tr>
                    </thead>
                    <tbody>%s</tbody>
                </table>

                <h2>CDS Representation</h2>
                <pre>%s</pre>

                <p><a class="btn secondary" href="/">Back to Catalog</a></p>
            </section>
        `,
            escapeHtml(definition.name),
            escapeHtml(definition.id),
            escapeHtml(definition.namespaceName),
            escapeHtml(definition.modelVersion),
            definition.deprecated_ ? "true" : "false",
            escapeHtml(toTimestamp(definition.createdAt)),
            renderFieldRows(definition.fields),
            escapeHtml(cdsSource)
        );

        return layout("Definition Detail", body);
    }

    string renderNotFound() {
        return layout("Not Found", "<section><h1>Definition not found</h1><p><a href=\"/\">Back</a></p></section>");
    }

    private string renderFieldRows(CdsField[] fields) {
        string rows;
        foreach (field; fields) {
            rows ~= format(
                "<tr><td>%s</td><td>%s</td><td>%s</td><td>%s</td></tr>",
                escapeHtml(field.name),
                escapeHtml(field.typeName),
                field.key ? "true" : "false",
                field.nullable ? "true" : "false"
            );
        }

        if (rows.length == 0) {
            rows = "<tr><td colspan=\"4\">No fields.</td></tr>";
        }

        return rows;
    }

    private string decorateRows(CdsDefinition[] definitions, string rows) {
        if (definitions.length == 0) {
            return rows;
        }

        string stateRows;
        foreach (definition; definitions) {
            auto state = definition.deprecated_ ? "deprecated" : "active";
            stateRows ~= format(
                "<tr><td><a href=\"/definitions/%s\">%s</a></td><td>%s</td><td>%s</td><td>%s</td><td>%s</td></tr>",
                escapeHtml(definition.id),
                escapeHtml(definition.name),
                escapeHtml(definition.namespaceName),
                escapeHtml(definition.modelVersion),
                escapeHtml(toTimestamp(definition.createdAt)),
                state
            );
        }

        return stateRows;
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
      background: radial-gradient(circle at 20%% 20%%, #dff3ff 0, transparent 42%%),
                  radial-gradient(circle at 80%% 0%%, #ffe7d1 0, transparent 38%%),
                  #f4f7fb;
      color: #172033;
    }
    main {
      max-width: 1100px;
      margin: 2rem auto;
      padding: 0 1rem;
    }
    section {
      background: #ffffff;
      border: 1px solid #d7e0ea;
      border-radius: 14px;
      box-shadow: 0 18px 40px rgba(20, 35, 56, 0.08);
      padding: 1.5rem;
    }
    h1, h2 { margin-top: 0; }
    .btn {
      display: inline-block;
      background: #0f4c81;
      color: #fff;
      text-decoration: none;
      padding: 0.6rem 1rem;
      border: 0;
      border-radius: 8px;
      cursor: pointer;
      font: inherit;
    }
    .btn.secondary { background: #0f766e; }
    label { display: block; margin: 0.9rem 0 0.2rem; font-weight: 600; }
    input, select, textarea {
      width: 100%%;
      box-sizing: border-box;
      border: 1px solid #b9c9d8;
      border-radius: 8px;
      padding: 0.6rem;
      font: inherit;
      background: #fff;
    }
    .hint { color: #556173; font-size: 0.9rem; }
    table { width: 100%%; border-collapse: collapse; }
    th, td {
      text-align: left;
      border-bottom: 1px solid #e0e7ef;
      padding: 0.65rem;
      vertical-align: top;
    }
    .notice {
      border-radius: 8px;
      padding: 0.75rem;
      background: #e0f2fe;
      color: #0c4a6e;
      font-weight: 600;
    }
    .notice.error { background: #fee2e2; color: #7f1d1d; }
    .notice.success { background: #dcfce7; color: #14532d; }
    .details {
      display: grid;
      grid-template-columns: 180px 1fr;
      gap: 0.35rem 1rem;
    }
    .details dt { font-weight: 700; }
    pre {
      background: #0b1021;
      color: #e6ecff;
      padding: 1rem;
      border-radius: 10px;
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

    private string toTimestamp(SysTime value) {
        return value.toISOExtString();
    }
}
