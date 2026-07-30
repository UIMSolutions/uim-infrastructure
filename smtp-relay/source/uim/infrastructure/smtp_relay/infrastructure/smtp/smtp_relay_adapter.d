module uim.infrastructure.smtp_relay.infrastructure.smtp.smtp_relay_adapter;

import uim.infrastructure.smtp_relay.domain.entities.email_message : EmailMessage;
import uim.infrastructure.smtp_relay.domain.ports.services.smtp_relay_port : ISmtpRelayPort;
import std.string : toLower;
import vibe.mail.smtp : Mail, SMTPAuthType, SMTPClientSettings, SMTPConnectionType, sendMail;

class SmtpRelayAdapter : ISmtpRelayPort {
    private SMTPClientSettings settings;

    this(
        string host,
        ushort port,
        string heloDomain = "localhost",
        string securityMode = "plain",
        string authMode = "none",
        string username = "",
        string password = ""
    ) {
        this.settings = new SMTPClientSettings(host, port);
        this.settings.localname = heloDomain;
        this.settings.connectionType = parseConnectionType(securityMode);
        this.settings.authType = parseAuthType(authMode);
        this.settings.username = username;
        this.settings.password = password;
    }

    override void relay(in EmailMessage message) {
        auto mail = new Mail;
        mail.headers["From"] = message.sender;
        mail.headers["To"] = joinRecipients(message.recipients);
        mail.headers["Subject"] = message.subject;
        mail.headers["Content-Type"] = "text/plain; charset=utf-8";
        mail.bodyText = message.body;

        sendMail(settings, mail);
    }

    private string joinRecipients(scope const(string)[] recipients) {
        string outText;
        foreach (index, recipient; recipients) {
            if (index > 0) {
                outText ~= ",";
            }
            outText ~= recipient;
        }
        return outText;
    }

    private SMTPConnectionType parseConnectionType(string mode) {
        switch (mode.toLower()) {
            case "plain":
                return SMTPConnectionType.plain;
            case "starttls":
                return SMTPConnectionType.startTLS;
            case "tls":
                return SMTPConnectionType.tls;
            default:
                throw new Exception("unsupported SMTP_SECURITY mode: " ~ mode);
        }
    }

    private SMTPAuthType parseAuthType(string mode) {
        switch (mode.toLower()) {
            case "none":
                return SMTPAuthType.none;
            case "plain":
                return SMTPAuthType.plain;
            case "login":
                return SMTPAuthType.login;
            case "xoauth2":
                return SMTPAuthType.xoauth2;
            default:
                throw new Exception("unsupported SMTP_AUTH mode: " ~ mode);
        }
    }
}
