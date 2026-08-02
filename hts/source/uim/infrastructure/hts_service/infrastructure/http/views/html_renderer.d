module uim.infrastructure.hts_service.infrastructure.http.views.html_renderer;

import uim.infrastructure.hts_service.domain.entities.hts_record : HtsRecord;
import uim.infrastructure.hts_service.domain.entities.unix_user : UnixUser;
import std.format : format;
import std.string : replace;

class HtmlRenderer {
    string renderHome(string[] datasets, string notice = "") {
        string rows;
        foreach (name; datasets) {
            rows ~= format("<tr><td><a href=\"/datasets/%s\">%s</a></td></tr>", escapeHtml(name), escapeHtml(name));
        }

        if (rows.length == 0) {
            rows = "<tr><td>No datasets ingested yet.</td></tr>";
        }

        string noticeMarkup;
        if (notice.length > 0) {
            noticeMarkup = "<p class=\"notice success\">" ~ escapeHtml(notice) ~ "</p>";
        }

        auto body = format(`
            <section>
                <h1>HTS Service Catalog</h1>
                <p>Ingest and query SAM, VCF, and FASTQ datasets through a clean + hexagonal service.</p>
                %s
                <p>
                    <a class="btn" href="/datasets/new">Ingest Dataset</a>
                    <a class="btn secondary" href="/users">UNIX Users</a>
                    <a class="btn secondary" href="/hash">Hash Tool</a>
                </p>
                <table>
                    <thead><tr><th>Dataset ID</th></tr></thead>
                    <tbody>%s</tbody>
                </table>
            </section>
        `, noticeMarkup, rows);

        return layout("HTS Datasets", body);
    }

    string renderIngestForm(string errorText = "", string successText = "") {
        string notices;
        if (errorText.length > 0) notices ~= "<p class=\"notice error\">" ~ escapeHtml(errorText) ~ "</p>";
        if (successText.length > 0) notices ~= "<p class=\"notice success\">" ~ escapeHtml(successText) ~ "</p>";

        auto body = format(`
            <section>
                <h1>Ingest HTS Dataset</h1>
                %s
                <form method="post" action="/datasets/new">
                    <label>Dataset ID</label>
                    <input type="text" name="datasetId" required />

                    <label>Format</label>
                    <select name="format">
                      <option value="sam">sam</option>
                      <option value="vcf">vcf</option>
                      <option value="fastq">fastq</option>
                    </select>

                    <label>Raw Content</label>
                    <textarea name="rawContent" rows="12" placeholder="Paste SAM/VCF/FASTQ content"></textarea>

                    <button class="btn" type="submit">Ingest</button>
                </form>
            </section>
        `, notices);

        return layout("Ingest Dataset", body);
    }

    string renderDatasetDetail(string datasetId, HtsRecord[] records, string referenceFilter = "") {
        string rows;
        foreach (record; records) {
            rows ~= format(
                "<tr><td>%s</td><td>%s</td><td>%s</td><td>%s</td><td><pre>%s</pre></td></tr>",
                escapeHtml(record.id),
                escapeHtml(record.referenceName),
                record.position,
                escapeHtml(record.sampleName),
                escapeHtml(record.payload)
            );
        }

        if (rows.length == 0) {
            rows = "<tr><td colspan=\"5\">No matching records.</td></tr>";
        }

        auto body = format(`
            <section>
                <h1>Dataset: %s</h1>
                <form method="get" action="/datasets/%s">
                    <label>Reference Filter</label>
                    <input type="text" name="reference" value="%s" placeholder="chr1" />
                    <button class="btn secondary" type="submit">Filter</button>
                </form>
                <table>
                    <thead>
                      <tr><th>ID</th><th>Reference</th><th>Position</th><th>Sample</th><th>Payload</th></tr>
                    </thead>
                    <tbody>%s</tbody>
                </table>
                <p><a class="btn secondary" href="/">Back</a></p>
            </section>
        `, escapeHtml(datasetId), escapeHtml(datasetId), escapeHtml(referenceFilter), rows);

        return layout("Dataset Detail", body);
    }

    string renderUnixUsers(UnixUser[] users) {
        string rows;
        foreach (user; users) {
            rows ~= format(
                "<tr><td><a href=\"/users/%s\">%s</a></td><td>%s</td><td>%s</td><td>%s</td></tr>",
                escapeHtml(user.passwd.username),
                escapeHtml(user.passwd.username),
                user.passwd.uid,
                user.passwd.gid,
                escapeHtml(user.passwd.loginShell)
            );
        }

        if (rows.length == 0) {
            rows = "<tr><td colspan=\"4\">No users found.</td></tr>";
        }

        auto body = format(`
            <section>
                <h1>UNIX User Catalog</h1>
                <p>
                    <a class="btn" href="/users/new">Create User</a>
                    <a class="btn secondary" href="/">Back to datasets</a>
                </p>
                <table>
                    <thead><tr><th>User</th><th>UID</th><th>GID</th><th>Shell</th></tr></thead>
                    <tbody>%s</tbody>
                </table>
            </section>
        `, rows);

        return layout("UNIX Users", body);
    }

    string renderCreateUserForm(string errorText = "", string successText = "") {
        string notices;
        if (errorText.length > 0) notices ~= "<p class=\"notice error\">" ~ escapeHtml(errorText) ~ "</p>";
        if (successText.length > 0) notices ~= "<p class=\"notice success\">" ~ escapeHtml(successText) ~ "</p>";

        auto body = format(`
            <section>
                <h1>Create UNIX User</h1>
                %s
                <form method="post" action="/users/new">
                    <label>Username</label><input type="text" name="username" required />
                    <label>UID</label><input type="number" name="uid" value="3000" required />
                    <label>GID</label><input type="number" name="gid" value="3000" required />
                    <label>GECOS</label><input type="text" name="gecos" value="HTS Managed User" />
                    <label>Home Directory</label>
                    <input type="text" name="homeDirectory" value="/home/htsuser" required />
                    <label>Login Shell</label><input type="text" name="loginShell" value="/bin/bash" required />
                    <label>Password</label><input type="password" name="password" required />
                    <button class="btn" type="submit">Create User</button>
                </form>
            </section>
        `, notices);

        return layout("Create UNIX User", body);
    }

    string renderUnixUserDetail(UnixUser user, string errorText = "", string successText = "") {
        string notices;
        if (errorText.length > 0) notices ~= "<p class=\"notice error\">" ~ escapeHtml(errorText) ~ "</p>";
        if (successText.length > 0) notices ~= "<p class=\"notice success\">" ~ escapeHtml(successText) ~ "</p>";

        auto body = format(`
            <section>
                <h1>User Detail: %s</h1>
                %s
                <dl class="details">
                    <dt>UID</dt><dd>%s</dd>
                    <dt>GID</dt><dd>%s</dd>
                    <dt>Home</dt><dd>%s</dd>
                    <dt>Shell</dt><dd>%s</dd>
                    <dt>Hash</dt><dd>%s</dd>
                </dl>
                <h2>Set Password</h2>
                <form method="post" action="/users/%s/password">
                    <label>Algorithm</label>
                    <select name="algorithm">
                      <option value="sha512">sha512</option>
                      <option value="sha256">sha256</option>
                      <option value="md5">md5</option>
                    </select>
                    <label>Password</label>
                    <input type="password" name="password" required />
                    <button class="btn" type="submit">Update Hash</button>
                </form>
                <p><a class="btn secondary" href="/users">Back</a></p>
            </section>
        `,
            escapeHtml(user.passwd.username),
            notices,
            user.passwd.uid,
            user.passwd.gid,
            escapeHtml(user.passwd.homeDirectory),
            escapeHtml(user.passwd.loginShell),
            escapeHtml(user.hasShadow ? user.shadow.passwordHash : "<none>"),
            escapeHtml(user.passwd.username)
        );

        return layout("UNIX User Detail", body);
    }

    string renderHashTool(
        string errorText = "",
        string successText = "",
        string generatedSalt = "",
        string generatedHash = ""
    ) {
        string notices;
        if (errorText.length > 0) notices ~= "<p class=\"notice error\">" ~ escapeHtml(errorText) ~ "</p>";
        if (successText.length > 0) notices ~= "<p class=\"notice success\">" ~ escapeHtml(successText) ~ "</p>";

        string output;
        if (generatedHash.length > 0) {
            output = "<h2>Result</h2><pre>salt=" ~ escapeHtml(generatedSalt)
                ~ "\nhash=" ~ escapeHtml(generatedHash) ~ "</pre>";
        }

        auto body = format(`
            <section>
                <h1>UNIX Hash Generator</h1>
                %s
                <form method="post" action="/hash">
                    <label>Algorithm</label>
                    <select name="algorithm">
                      <option value="sha512">sha512</option>
                      <option value="sha256">sha256</option>
                      <option value="md5">md5</option>
                    </select>
                    <label>Password</label>
                    <input type="password" name="password" required />
                    <button class="btn" type="submit">Generate</button>
                </form>
                %s
            </section>
        `, notices, output);

        return layout("Hash Tool", body);
    }

    string renderNotFound(string message) {
        return layout(
            "Not Found",
            "<section><h1>Not Found</h1><p>" ~ escapeHtml(message)
                ~ "</p><p><a href=\"/\">Back</a></p></section>"
        );
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
            background: linear-gradient(145deg, #edf6ff 0%%, #fff7ed 45%%, #f0fdf4 100%%);
            color: #1a2333;
        }
        main { max-width: 1200px; margin: 2rem auto; padding: 0 1rem; }
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
            margin-right: 0.4rem;
            margin-top: 0.8rem;
        }
        .btn.secondary { background: #0f766e; }
        .notice { border-radius: 8px; padding: 0.7rem; font-weight: 600; }
        .notice.error { background: #fee2e2; color: #7f1d1d; }
        .notice.success { background: #dcfce7; color: #14532d; }
        .details {
            display: grid;
            grid-template-columns: 170px 1fr;
            gap: 0.35rem 1rem;
        }
        .details dt { font-weight: 700; }
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
