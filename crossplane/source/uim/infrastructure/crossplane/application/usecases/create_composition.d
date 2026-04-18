module uim.infrastructure.crossplane.application.usecases.create_composition;

import uim.infrastructure.crossplane.application.dto.commands : CreateCompositionCommand, ComposedTemplateDef;
import uim.infrastructure.crossplane.domain.entities.composition : Composition, ComposedTemplate;
import uim.infrastructure.crossplane.domain.ports.repositories.composition : ICompositionRepository;
import std.datetime.systime : Clock;

class CreateCompositionUseCase {
    private ICompositionRepository repo;

    this(ICompositionRepository repo) { this.repo = repo; }

    Composition execute(CreateCompositionCommand cmd) {
        ComposedTemplate[] resources;
        foreach (r; cmd.resources) {
            string[string] patches;
            foreach (k, v; r.patches) patches[k] = v;
            string[string] base;
            foreach (k, v; r.base) base[k] = v;
            resources ~= ComposedTemplate(r.name, r.kind, r.apiGroup, patches, base);
        }

        string[string] secretsRef;
        foreach (k, v; cmd.writeConnectionSecretsToRef)
            secretsRef[k] = v;

        auto composition = Composition(
            generateId(),
            cmd.name,
            cmd.compositeTypeRef,
            resources,
            secretsRef,
            Clock.currTime.toISOExtString,
            ""
        );
        repo.save(composition);
        return composition;
    }

    private string generateId() {
        import std.uuid : randomUUID;
        return randomUUID().toString();
    }
}
