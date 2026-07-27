/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.infrastructure.waf.domain.ports.repositories.waf_event;

import uim.infrastructure.waf.domain.entities.waf_event : WafEvent;

interface IWafEventRepository {
    void save(in WafEvent event);
    WafEvent[] list();
    WafEvent[] findBySourceIp(string sourceIp);
    WafEvent[] findByRuleId(string ruleId);
}
