/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.infrastructure.archer.domain.ports.repositories.agent;

import uim.infrastructure.archer.domain.entities.agent : ArcherAgent;

interface IAgentRepository {
    ArcherAgent[] list();
    ArcherAgent* findByHost(string host);
}
