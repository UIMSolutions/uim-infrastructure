module uim.infrastructure.smtp_relay.domain.ports.services.smtp_relay_port;

import uim.infrastructure.smtp_relay.domain.entities.email_message : EmailMessage;

interface ISmtpRelayPort {
    void relay(in EmailMessage message);
}
