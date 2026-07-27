/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.infrastructure.ca.infrastructure.persistence.memory.ca_state_repository;

import core.sync.mutex : Mutex;
import uim.infrastructure.ca.domain.entities.ca_state : CaState;
import uim.infrastructure.ca.domain.ports.repositories.ca_state : ICaStateRepository;

class InMemoryCaStateRepository : ICaStateRepository {
    private CaState state;
    private bool initialized;
    private Mutex mutex;

    this() {
        mutex = new Mutex;
    }

    override void save(in CaState state) {
        synchronized (mutex) {
            this.state = copyState(state);
            this.initialized = true;
        }
    }

    override CaState* get() {
        synchronized (mutex) {
            if (!initialized) return null;
            return &state;
        }
    }

    override bool isInitialized() {
        synchronized (mutex) {
            return initialized;
        }
    }

    private CaState copyState(in CaState src) {
        CaState dst;
        dst.id = src.id;
        dst.name = src.name;
        dst.commonName = src.commonName;
        dst.certPem = src.certPem;
        dst.keyPem = src.keyPem;
        dst.serialNumber = src.serialNumber;
        dst.createdAt = src.createdAt;
        dst.validDays = src.validDays;
        return dst;
    }
}
