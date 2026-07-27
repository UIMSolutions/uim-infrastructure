/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.infrastructure.scim.application.usecases.list_groups;

import std.string : toLower;
import uim.infrastructure.scim.domain.entities.group : ScimGroup;
import uim.infrastructure.scim.domain.ports.repositories.group : IGroupRepository;

class ListGroupsUseCase {
    private IGroupRepository repository;

    this(IGroupRepository repository) {
        this.repository = repository;
    }

    ScimGroup[] execute(string filterAttribute = "", string filterValue = "") {
        auto groups = repository.list();
        if (filterAttribute.length == 0 || filterValue.length == 0) {
            return groups;
        }

        ScimGroup[] filtered;
        foreach (group; groups) {
            switch (toLower(filterAttribute)) {
                case "displayname":
                    if (toLower(group.displayName) == toLower(filterValue)) {
                        filtered ~= group;
                    }
                    break;
                case "externalid":
                    if (toLower(group.externalId) == toLower(filterValue)) {
                        filtered ~= group;
                    }
                    break;
                default:
                    return groups;
            }
        }
        return filtered;
    }
}
