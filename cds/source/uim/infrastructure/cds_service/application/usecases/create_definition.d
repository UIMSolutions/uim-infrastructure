module uim.infrastructure.cds_service.application.usecases.create_definition;

import uim.infrastructure.cds_service.application.dto.definition_command : CdsFieldCommand,
    CreateDefinitionCommand;
import uim.infrastructure.cds_service.domain.entities.cds_definition : CdsDefinition, CdsField;
import uim.infrastructure.cds_service.domain.ports.repositories.cds_definition_repository :
    ICdsDefinitionRepository;
import std.conv : to;
import std.datetime.systime : Clock;
import std.string : replace, strip, toLower;

class CreateDefinitionUseCase {
    private ICdsDefinitionRepository repository;

    this(ICdsDefinitionRepository repository) {
        this.repository = repository;
    }

    CdsDefinition execute(CreateDefinitionCommand command) {
        auto namespaceName = command.namespaceName.strip;
        auto name = command.name.strip;

        if (namespaceName.length == 0) {
            throw new Exception("namespace is required");
        }
        if (name.length == 0) {
            throw new Exception("name is required");
        }
        if (command.fields.length == 0) {
            throw new Exception("at least one field is required");
        }

        CdsField[] fields;
        foreach (fieldCommand; command.fields) {
            fields ~= buildField(fieldCommand);
        }

        auto definition = CdsDefinition(
            generateId(namespaceName, name),
            namespaceName,
            name,
            command.modelVersion.strip.length == 0 ? "1.0.0" : command.modelVersion.strip,
            command.deprecated_,
            fields,
            Clock.currTime()
        );

        return repository.add(definition);
    }

    private CdsField buildField(CdsFieldCommand command) {
        auto name = command.name.strip;
        auto typeName = command.typeName.strip;

        if (name.length == 0) {
            throw new Exception("field name is required");
        }
        if (typeName.length == 0) {
            throw new Exception("field type is required");
        }

        return CdsField(name, typeName, command.nullable, command.key);
    }

    private string generateId(string namespaceName, string name) {
        auto base = (namespaceName ~ "-" ~ name).toLower;
        base = base.replace(".", "-").replace(" ", "-").strip;
        return base ~ "-" ~ Clock.currTime().stdTime.to!string;
    }
}
