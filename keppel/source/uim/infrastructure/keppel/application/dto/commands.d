/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.infrastructure.keppel.application.dto.commands;

struct CreateRepositoryCommand {
    string name;
    string projectId;
    string visibility;
}

struct UpsertTagCommand {
    string repositoryName;
    string tag;
    string digest;
    long sizeBytes;
    string mediaType;
}
