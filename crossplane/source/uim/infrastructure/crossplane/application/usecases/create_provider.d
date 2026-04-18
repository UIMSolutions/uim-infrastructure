module uim.infrastructure.crossplane.application.usecases.create_provider;

import uim.infrastructure.crossplane.application.dto.commands : CreateProviderCommand, CredentialDef;
import uim.infrastructure.crossplane.domain.entities.provider : Provider, ProviderType, ProviderStatus, ProviderCredential;
import uim.infrastructure.crossplane.domain.ports.repositories.provider : IProviderRepository;
import std.conv : to;
import std.datetime.systime : Clock;

class CreateProviderUseCase {
    private IProviderRepository repo;

    this(IProviderRepository repo) { this.repo = repo; }

    Provider execute(CreateProviderCommand cmd) {
        ProviderCredential[] creds;
        foreach (c; cmd.credentials)
            creds ~= ProviderCredential(c.key, c.secretRef);

        auto provider = Provider(
            generateId(),
            cmd.name,
            cmd.providerType.to!ProviderType,
            cmd.packageRef,
            ProviderStatus.INSTALLING,
            cmd.region,
            creds,
            cmd.config.dup,
            Clock.currTime.toISOExtString
        );
        repo.save(provider);
        return provider;
    }

    private string generateId() {
        import std.uuid : randomUUID;
        return randomUUID().toString();
    }
}
