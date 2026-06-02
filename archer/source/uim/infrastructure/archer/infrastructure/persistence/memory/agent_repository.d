module uim.infrastructure.archer.infrastructure.persistence.memory.agent_repository;

import core.sync.mutex : Mutex;
import std.datetime : Clock;
import uim.infrastructure.archer.domain.entities.agent : ArcherAgent, AgentProvider;
import uim.infrastructure.archer.domain.ports.repositories.agent : IAgentRepository;

class InMemoryAgentRepository : IAgentRepository {
    private ArcherAgent[] agents;
    private Mutex mutex;

    this() {
        mutex = new Mutex;
        auto now = Clock.currTime.toISOExtString();
        agents ~= ArcherAgent("agent-host-01", "AZ-A", AgentProvider.tenant, true, "physnet0", now, now, now, 4);
        agents ~= ArcherAgent("agent-host-02", "AZ-A", AgentProvider.cp, true, "physnet1", now, now, now, 2);
    }

    override ArcherAgent[] list() {
        synchronized (mutex) {
            return agents.dup;
        }
    }

    override ArcherAgent* findByHost(string host) {
        synchronized (mutex) {
            foreach (ref agent; agents) {
                if (agent.host == host) return &agent;
            }
            return null;
        }
    }
}
