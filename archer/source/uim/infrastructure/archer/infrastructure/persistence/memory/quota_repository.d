/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.infrastructure.archer.infrastructure.persistence.memory.quota_repository;

import core.sync.mutex : Mutex;
import uim.infrastructure.archer.domain.entities.quota : ArcherQuota;
import uim.infrastructure.archer.domain.ports.repositories.quota : IQuotaRepository;

class InMemoryQuotaRepository : IQuotaRepository {
    private ArcherQuota[] quotas;
    private Mutex mutex;

    this() {
        mutex = new Mutex;
    }

    override void save(in ArcherQuota quota) {
        synchronized (mutex) {
            foreach (i, ref existing; quotas) {
                if (existing.projectId == quota.projectId) {
                    quotas[i] = copyQuota(quota);
                    return;
                }
            }
            quotas ~= copyQuota(quota);
        }
    }

    override ArcherQuota[] list() {
        synchronized (mutex) {
            return quotas.dup;
        }
    }

    override ArcherQuota* findByProjectId(string projectId) {
        synchronized (mutex) {
            foreach (ref quota; quotas) {
                if (quota.projectId == projectId) return &quota;
            }
            return null;
        }
    }

    override void remove(string projectId) {
        synchronized (mutex) {
            ArcherQuota[] filtered;
            foreach (quota; quotas) {
                if (quota.projectId != projectId) filtered ~= quota;
            }
            quotas = filtered;
        }
    }

    private ArcherQuota copyQuota(in ArcherQuota src) {
        ArcherQuota dst;
        dst.service = src.service;
        dst.endpoint = src.endpoint;
        dst.inUseService = src.inUseService;
        dst.inUseEndpoint = src.inUseEndpoint;
        dst.projectId = src.projectId;
        return dst;
    }
}
