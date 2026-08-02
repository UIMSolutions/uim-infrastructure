module uim.infrastructure.unix_auth_service.infrastructure.http.views.html_renderer;

import uim.infrastructure.unix_auth_service.domain.entities.unix_user : UnixUser;
import std.format : format;
import std.string : replace;

class HtmlRenderer {
    string renderHome(UnixUser[] users, string notice = "") {
        string rows;
        foreach (user; users) {
            auto hashState = user.hasShadow ? "present" : "missing";
            rows ~= format(
                "<tr><td><a href=\"/users/%s\">%s</a></td><td>%s</td><td>%s</td><td>%s</td><td>%s</td></tr>",
                escapeHtml(user.passwd.username),
                escapeHtml(user.passwd.username),
                user.passwd.uid,
                user.passwd.gid,
                escapeHtml(user.passwd.loginShell),
                hashState
            );
        }

        if (rows.length == 0) {
            rows = "<tr><td colspan=\"5\">No users available.</td></tr>";
        }

        string noticeMarkup;
        if (notice.length > 0) {
            noticeMarkup = "<p class=\"notice success\">" ~ escapeHtml(notice) ~ "</p>";
        }

        auto body = format(`
            <section>
                <h1>UNIX Authentication Service</h1>
                <p>Inspect POSIX users, create accounts, and manage shadow password hashes.</p>
                %s
                <p>
                    <a class="btn" href="/users/new">Create User</a>
                    <a class="btn secondary" href="/hash">Hash Tool</a>
                    <a class="btn secondary" href="/health">Health</a>
                </p>
                <table>
                    <thead>
                        <tr>
                            <th>User</th><th>UID</th><th>GID</th><th>Shell</th><th>Shadow</th>
                        </tr>
                    </thead>
                    <tbody>%s</tbody>
                </table>
            </section>
        `, noticeMarkup, rows);

        return layout("UNIX Auth Users", body);
    }

    string renderCreateUserForm(string errorText = "", string successText = "") {
        string notices;
        if (errorText.length > 0) {
            notices ~= "<p class=\"notice error\">" ~ escapeHtml(errorText) ~ "</p>";
        }
        if (successText.length > 0) {
            notices ~= "<p class=\"notice success\">" ~ escapeHtml(successText) ~ "</p>";
        }

        auto body = format(`
            <section>
                <h1>Create POSIX User</h1>
                %s
                <form method="post" action="/users/new">
                    <label>Username</label>
                    <input type="text" name="username" required />

                    <label>UID</label>
                    <input type="number" name="uid" value="2000" required />

                    <label>GID</label>
                    <input type="number" name="gid" value="2000" required />

                    <label>GECOS</label>
                    <input type="text" name="gecos" value="Managed by uim-unix-auth-service" />

                    <label>Home Directory</label>
                    <input type="text" name="homeDirectory" value="/home/newuser" required />

                    <label>Login Shell</label>
                    <input type="text" name="loginShell" value="/bin/bash" required />

                    <label>Password</label>
                    <input type="password" name="password" required />

                    <button class="btn" type="submit">Create User</button>
                </form>
            </section>
        `, notices);

        return layout("Create User", body);
    }

    string renderUserDetail(UnixUser user, string jsonPreview, string errorText = "", string successText = "") {
        string notices;
        if (errorText.length > 0) {
            notices ~= "<p class=\"notice error\">" ~ escapeHtml(errorText) ~ "</p>";
        }
        if (successText.length > 0) {
            notices ~= "<p class=\"notice success\">" ~ escapeHtml(successText) ~ "</p>";
        }

        auto body = format(`
            <section>
                <h1>User Detail: %s</h1>
                %s
                <dl class="details">
                    <dt>Username</dt><dd>%s</dd>
                    <dt>UID</dt><dd>%s</dd>
                    <dt>GID</dt><dd>%s</dd>
                    <dt>GECOS</dt><dd>%s</dd>
                    <dt>Home</dt><dd>%s</dd>
                    <dt>Shell</dt><dd>%s</dd>
                    <dt>Shadow Hash</dt><dd>%s</dd>
                    <dt>Password Locked</dt><dd>%s</dd>
                </dl>

                <h2>Set New Password</h2>
                <form method="post" action="/users/%s/password">
                    <label>Algorithm</label>
                    <select name="algorithm">
                      <option value="sha512">sha512</option>
                      <option value="sha256">sha256</option>
                      <option value="md5">md5</option>
                    </select>
                    <label>Password</label>
                    <input type="password" name="password" required />
                    <button class="btn" type="submit">Update Password Hash</button>
                </form>

                <h2>JSON Preview</h2>
                <pre>%s</pre>
                <p><a class="btn secondary" href="/">Back</a></p>
            </section>
        `,
            escapeHtml(user.passwd.username),
            notices,
            escapeHtml(user.passwd.username),
            user.passwd.uid,
            user.passwd.gid,
            escapeHtml(user.passwd.gecos),
            escapeHtml(user.passwd.homeDirectory),
            escapeHtml(user.passwd.loginShell),
            escapeHtml(user.hasShadow ? user.shadow.passwordHash : "<none>"),
            user.hasShadow && user.shadow.locked() ? "yes" : "no",
            escapeHtml(user.passwd.username),
            escapeHtml(jsonPreview)
        );

        return layout("User Detail", body);
    }

    string renderHashTool(
        string errorText = "",
        string successText = "",
        string generatedHash = "",
        string generatedSalt = ""
    ) {
        string notices;
        if (errorText.length > 0) {
            notices ~= "<p class=\"notice error\">" ~ escapeHtml(errorText) ~ "</p>";
        }
        if (successText.length > 0) {
            notices ~= "<p class=\"notice success\">" ~ escapeHtml(successText) ~ "</p>";
        }

        string result;
        if (generatedHash.length > 0) {
            result = "<h2>Generated</h2><pre>salt=" ~ escapeHtml(generatedSalt)
                ~ "\nhash=" ~ escapeHtml(generatedHash) ~ "</pre>";
        }

        auto body = format(`
            <section>
                <h1>Password Hash Tool</h1>
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
                    <button class="btn" type="submit">Generate Hash</button>
                </form>
                %s
                <p><a class="btn secondary" href="/">Back</a></p>
            </section>
        `, notices, result);

        return layout("Password Hash Tool", body);
    }

    string renderNotFound(string message = "Entry not found") {
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
      background: linear-gradient(155deg, #f0f8ff 0%%, #fff7ed 50%%, #f0fdf4 100%%);
      color: #1a2333;
    }
    main { max-width: 1100px; margin: 2rem auto; padding: 0 1rem; }
    section {
      background: #fff;
      border: 1px solid #d6deea;
      border-radius: 14px;
      box-shadow: 0 16px 36px rgba(21, 33, 52, 0.08);
      padding: 1.5rem;
    }
    table { width: 100%%; border-collapse: collapse; }
    th, td { text-align: left; border-bottom: 1px solid #e1e8f0; padding: 0.6rem; }
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
    .details { display: grid; grid-template-columns: 170px 1fr; gap: 0.35rem 1rem; }
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
