module uim.infrastructure.acdoca_service.infrastructure.http.views.html_renderer;

import uim.infrastructure.acdoca_service.domain.entities.journal_entry : DebitCreditIndicator,
    JournalEntry;
import std.format : format;
import std.string : replace;

class HtmlRenderer {
    string renderHome(JournalEntry[] entries, string notice = "") {
        string rows;
        foreach (entry; entries) {
            rows ~= format(
                "<tr><td><a href=\"/entries/%s\">%s</a></td><td>%s</td><td>%s</td><td>%s</td><td>%s</td><td>%s</td></tr>",
                escapeHtml(entry.id),
                escapeHtml(entry.id),
                escapeHtml(entry.companyCode),
                entry.fiscalYear,
                entry.documentNumber,
                escapeHtml(entry.glAccount),
                escapeHtml(toIndicator(entry.indicator))
            );
        }

        if (rows.length == 0) {
            rows = "<tr><td colspan=\"7\">No journal entries yet.</td></tr>";
        }

        string noticeMarkup;
        if (notice.length > 0) {
            noticeMarkup = "<p class=\"notice success\">" ~ escapeHtml(notice) ~ "</p>";
        }

        auto body = format(`
            <section>
                <h1>Universal Journal (ACDOCA) Catalog</h1>
                <p>Post and inspect accounting line items using a clean and hexagonal service.</p>
                %s
                <p>
                  <a class="btn" href="/entries/new">Post Journal Entry</a>
                  <a class="btn secondary" href="/health">Health</a>
                </p>
                <table>
                    <thead>
                        <tr>
                            <th>ID</th><th>Company</th><th>Year</th><th>Doc</th><th>G/L</th><th>Dr/Cr</th><th>Amount</th>
                        </tr>
                    </thead>
                    <tbody>%s</tbody>
                </table>
            </section>
        `, noticeMarkup, appendAmount(entries, rows));

        return layout("ACDOCA Journal", body);
    }

    string renderCreateForm(string defaultCompanyCode, string errorText = "", string successText = "") {
        string notices;
        if (errorText.length > 0) {
            notices ~= "<p class=\"notice error\">" ~ escapeHtml(errorText) ~ "</p>";
        }
        if (successText.length > 0) {
            notices ~= "<p class=\"notice success\">" ~ escapeHtml(successText) ~ "</p>";
        }

        auto body = format(`
            <section>
                <h1>Post Journal Entry</h1>
                %s
                <form method="post" action="/entries/new">
                    <label>Company Code</label>
                    <input type="text" name="companyCode" value="%s" required />

                    <label>Fiscal Year</label>
                    <input type="number" name="fiscalYear" value="2026" required />

                    <label>Document Number</label>
                    <input type="number" name="documentNumber" value="1" required />

                    <label>Line Item</label>
                    <input type="number" name="lineItem" value="1" required />

                    <label>G/L Account</label>
                    <input type="text" name="glAccount" placeholder="400000" required />

                    <label>Currency</label>
                    <input type="text" name="currency" value="EUR" required />

                    <label>Amount</label>
                    <input type="number" step="0.01" name="amount" value="100.00" required />

                    <label>Indicator</label>
                    <select name="indicator">
                      <option value="debit">debit</option>
                      <option value="credit">credit</option>
                    </select>

                    <label>Posting Date (YYYY-MM-DD)</label>
                    <input type="text" name="postingDate" value="2026-01-01" />

                    <label>Text</label>
                    <textarea name="text" rows="4" placeholder="Invoice posting"></textarea>

                    <button class="btn" type="submit">Post Entry</button>
                </form>
            </section>
        `, notices, escapeHtml(defaultCompanyCode));

        return layout("Post Journal Entry", body);
    }

    string renderEntryDetail(JournalEntry entry, string jsonPreview) {
        auto body = format(`
            <section>
                <h1>Journal Entry Detail</h1>
                <dl class="details">
                  <dt>ID</dt><dd>%s</dd>
                  <dt>Company Code</dt><dd>%s</dd>
                  <dt>Fiscal Year</dt><dd>%s</dd>
                  <dt>Document Number</dt><dd>%s</dd>
                  <dt>Line Item</dt><dd>%s</dd>
                  <dt>G/L Account</dt><dd>%s</dd>
                  <dt>Currency</dt><dd>%s</dd>
                  <dt>Amount</dt><dd>%0.2f</dd>
                  <dt>Indicator</dt><dd>%s</dd>
                  <dt>Posting Date</dt><dd>%s</dd>
                  <dt>Text</dt><dd>%s</dd>
                </dl>
                <h2>JSON Representation</h2>
                <pre>%s</pre>
                <p><a class="btn secondary" href="/">Back to list</a></p>
            </section>
        `,
            escapeHtml(entry.id),
            escapeHtml(entry.companyCode),
            entry.fiscalYear,
            entry.documentNumber,
            entry.lineItem,
            escapeHtml(entry.glAccount),
            escapeHtml(entry.currency),
            entry.amount,
            escapeHtml(toIndicator(entry.indicator)),
            escapeHtml(entry.postingDate.toISOExtString()),
            escapeHtml(entry.text),
            escapeHtml(jsonPreview)
        );

        return layout("Entry Detail", body);
    }

    string renderNotFound() {
        return layout("Not Found", "<section><h1>Entry not found</h1><p><a href=\"/\">Back</a></p></section>");
    }

    private string appendAmount(JournalEntry[] entries, string rows) {
        if (entries.length == 0) {
            return rows;
        }

        string rewritten;
        foreach (entry; entries) {
            rewritten ~= format(
                "<tr><td><a href=\"/entries/%s\">%s</a></td><td>%s</td><td>%s</td><td>%s</td><td>%s</td><td>%s</td><td>%0.2f %s</td></tr>",
                escapeHtml(entry.id),
                escapeHtml(entry.id),
                escapeHtml(entry.companyCode),
                entry.fiscalYear,
                entry.documentNumber,
                escapeHtml(entry.glAccount),
                escapeHtml(toIndicator(entry.indicator)),
                entry.amount,
                escapeHtml(entry.currency)
            );
        }

        return rewritten;
    }

    private string toIndicator(DebitCreditIndicator indicator) {
        return indicator == DebitCreditIndicator.debit ? "debit" : "credit";
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
      background: linear-gradient(160deg, #f2f6ff 0%%, #fff4e6 55%%, #eef9f1 100%%);
      color: #172033;
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
      background: #0d4d84;
      color: #fff;
      text-decoration: none;
      border: 0;
      border-radius: 8px;
      padding: 0.6rem 0.95rem;
      cursor: pointer;
      font: inherit;
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
