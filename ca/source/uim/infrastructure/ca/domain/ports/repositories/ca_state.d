/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.infrastructure.ca.domain.ports.repositories.ca_state;

import uim.infrastructure.ca.domain.entities.ca_state : CaState;

interface ICaStateRepository {
    void save(in CaState state);
    CaState* get();
    bool isInitialized();
}
