/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.infrastructure.keppel.domain.entities.repository;

import uim.infrastructure.keppel.domain.entities.image_tag : ImageTag;

enum RepositoryVisibility {
    private_,
    public_
}

struct Repository {
    string name;
    string projectId;
    RepositoryVisibility visibility;
    string createdAt;
    string updatedAt;
    ImageTag[] tags;
}
