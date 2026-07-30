module uim.infrastructure.smtp_relay.infrastructure.http.views.html_renderer;

import uim.infrastructure.smtp_relay.domain.entities.email_message : EmailMessage;
import std.conv : to;
import std.datetime.systime : SysTime;
import std.format : format;
import std.string : replace;

class HtmlRenderer {
    string renderHome() {
        auto body = `
            <section class="hero">
                <h1>SMTP Relay Service</h1>
                <p>Relay email messages through an SMTP target and inspect relay history.</p>
                <div class="actions">
                    <a class="btn" href="/compose">Compose Message</a>
                    <a class="btn secondary" href="/messages">View Relay Queue</a>
                </div>
            </section>
        `;

        return layout("SMTP Relay", body);
    }

    string renderCompose(string defaultSender, string errorText = "", string successText = "") {
        string notices;
        if (errorText.length > 0) {
            notices ~= "<p class=\"notice error\">" ~ escapeHtml(errorText) ~ "</p>";
        }
        if (successText.length > 0) {
            notices ~= "<p class=\"notice success\">" ~ escapeHtml(successText) ~ "</p>";
        }

        auto body = format(`
            <section>
                <h1>Compose Relay Message</h1>
                %s
                <form method="post" action="/compose" class="compose-form">
                    <label>Sender</label>
                    <input type="email" name="sender" value="%s" placeholder="noreply@uim.local" />

                    <label>Recipients (comma separated)</label>
                    <input type="text" name="recipients" placeholder="alice@example.com,bob@example.com" required />

                    <label>Subject</label>
                    <input type="text" name="subject" required />

                    <label>Body</label>
                    <textarea name="body" rows="10" required></textarea>

                    <button type="submit">Relay Message</button>
                </form>
            </section>
        `, notices, escapeHtml(defaultSender));

        return layout("Compose", body);
    }

    string renderMessages(EmailMessage[] messages) {
        string rows;

        foreach (message; messages) {
            rows ~= format(
                "<tr><td><a href=\"/messages/%s\">%s</a></td><td>%s</td><td>%s</td><td>%s</td><td>%s</td></tr>",
                escapeHtml(message.id),
                escapeHtml(message.id),
                escapeHtml(message.sender),
                escapeHtml(joinRecipients(message.recipients)),
                escapeHtml(message.status.to!string),
                escapeHtml(toTimestamp(message.createdAt))
            );
        }

        if (rows.length == 0) {
            rows = "<tr><td colspan=\"5\">No relay messages yet.</td></tr>";
        }

        auto body = format(`
            <section>
                <h1>Relay Queue</h1>
                <p><a class="btn" href="/compose">Compose Message</a></p>
                <table>
                    <thead>
                        <tr>
                            <th>ID</th>
                            <th>Sender</th>
                            <th>Recipients</th>
                            <th>Status</th>
                            <th>Created</th>
                        </tr>
                    </thead>
                    <tbody>%s</tbody>
                </table>
            </section>
        `, rows);

        return layout("Messages", body);
    }

    string renderMessageDetail(EmailMessage message) {
        auto body = format(`
            <section>
                <h1>Message Details</h1>
                <dl class="details">
                    <dt>ID</dt><dd>%s</dd>
                    <dt>Sender</dt><dd>%s</dd>
                    <dt>Recipients</dt><dd>%s</dd>
                    <dt>Status</dt><dd>%s</dd>
                    <dt>Created</dt><dd>%s</dd>
                    <dt>Subject</dt><dd>%s</dd>
                    <dt>Relay Error</dt><dd>%s</dd>
                </dl>
                <h2>Body</h2>
                <pre>%s</pre>
                <p><a class="btn secondary" href="/messages">Back</a></p>
            </section>
        `,
            escapeHtml(message.id),
            escapeHtml(message.sender),
            escapeHtml(joinRecipients(message.recipients)),
            escapeHtml(message.status.to!string),
            escapeHtml(toTimestamp(message.createdAt)),
            escapeHtml(message.subject),
            message.relayError.length == 0 ? "-" : escapeHtml(message.relayError),
            escapeHtml(message.body)
        );

        return layout("Message Detail", body);
    }

    string renderNotFound() {
        return layout("Not Found", "<h1>Message not found</h1><p><a href=\"/messages\">Back to queue</a></p>");
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
    :root { color-scheme: light; }
    body {
      margin: 0;
      font-family: "Source Sans 3", "Segoe UI", sans-serif;
      background: linear-gradient(145deg, #f2f7f5, #e9eef8);
      color: #18202a;
    }
    main {
      max-width: 1024px;
      margin: 2.5rem auto;
      padding: 0 1rem;
    }
    section {
      background: #ffffff;
      border-radius: 12px;
      box-shadow: 0 14px 30px rgba(31, 42, 55, 0.08);
      padding: 1.5rem;
    }
    h1, h2 { margin-top: 0; }
    .btn {
      display: inline-block;
      background: #115e59;
      color: #fff;
      padding: 0.6rem 1rem;
      border-radius: 8px;
      text-decoration: none;
      border: 0;
      cursor: pointer;
    }
    .btn.secondary { background: #2563eb; }
    .actions { display: flex; gap: 0.6rem; }
    label { display: block; margin: 0.8rem 0 0.2rem; }
    input, textarea {
      width: 100%;
      border: 1px solid #cad5e2;
      border-radius: 8px;
      padding: 0.65rem;
      box-sizing: border-box;
      font: inherit;
    }
    button { margin-top: 1rem; }
    table {
      width: 100%;
      border-collapse: collapse;
      background: white;
    }
    th, td {
      border-bottom: 1px solid #e4ebf3;
      padding: 0.65rem;
      text-align: left;
      vertical-align: top;
    }
    .notice {
      border-radius: 8px;
      padding: 0.8rem;
      font-weight: 600;
    }
    .notice.error {
      background: #fee2e2;
      color: #7f1d1d;
    }
    .notice.success {
      background: #dcfce7;
      color: #14532d;
    }
    .details {
      display: grid;
      grid-template-columns: 180px 1fr;
      gap: 0.4rem 1rem;
    }
    .details dt { font-weight: 700; }
    pre {
      background: #111827;
      color: #f9fafb;
      border-radius: 8px;
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

    private string joinRecipients(string[] recipients) {
        string outValue;
        foreach (index, recipient; recipients) {
            if (index > 0) {
                outValue ~= ", ";
            }
            outValue ~= recipient;
        }
        return outValue;
    }

    private string toTimestamp(SysTime value) {
        return value.toISOExtString();
    }
}
