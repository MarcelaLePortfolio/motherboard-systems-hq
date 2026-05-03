# Phase 487 Operator Guidance Render Contract Audit

Generated: Tue Apr 21 11:30:36 PDT 2026

## Runtime posture

```
?? docs/phase487_operator_guidance_render_contract_audit.md

NAME                                 IMAGE                              COMMAND                  SERVICE     CREATED          STATUS                   PORTS
motherboard_systems_hq-dashboard-1   motherboard_systems_hq-dashboard   "docker-entrypoint.s…"   dashboard   4 minutes ago    Up 4 minutes (healthy)   0.0.0.0:8080->3000/tcp, [::]:8080->3000/tcp
motherboard_systems_hq-postgres-1    postgres:16-alpine                 "docker-entrypoint.s…"   postgres    26 minutes ago   Up 26 minutes            0.0.0.0:5432->5432/tcp, [::]:5432->5432/tcp
```

## Guidance source references

```
public/dashboard.html.phase474_9_pre_body_isolation.bak:129:                      <div id="operator-guidance-panel" class="mt-4 rounded-xl border border-gray-700 bg-gray-900/70 p-4 min-h-[140px]">
public/dashboard.html.phase474_9_pre_body_isolation.bak:130:                        <div class="text-xs uppercase tracking-[0.2em] text-gray-500 mb-3">Operator Guidance</div>
public/dashboard.html.phase474_9_pre_body_isolation.bak:131:                        <div id="operator-guidance-response" class="text-sm text-gray-300 leading-6">
public/dashboard.html.phase474_9_pre_body_isolation.bak:132:                          Awaiting bounded guidance stream.<br>
public/dashboard.html.phase474_9_pre_body_isolation.bak:133:                          Live operator guidance will appear here when visibility wiring is active.
public/dashboard.html.phase474_9_pre_body_isolation.bak:135:                        <div id="operator-guidance-meta" class="mt-3 text-xs text-gray-500 leading-5">
public/dashboard.html.phase474_9_pre_body_isolation.bak:137:                          Sources: diagnostics/system-health
public/dashboard.html.phase474_9_pre_body_isolation.bak:379:    <script id="phase464x-guidance-dom-probe">
public/dashboard.html.phase474_9_pre_body_isolation.bak:436:    const panel = byId("operator-guidance-panel");
public/dashboard.html.phase474_9_pre_body_isolation.bak:437:    const response = byId("operator-guidance-response");
public/dashboard.html.phase474_9_pre_body_isolation.bak:438:    const meta = byId("operator-guidance-meta");
public/dashboard.html.phase474_9_pre_body_isolation.bak:460:    const existing = byId("phase464x-guidance-dom-probe-output");
public/dashboard.html.phase474_9_pre_body_isolation.bak:464:    sink.id = "phase464x-guidance-dom-probe-output";
public/dashboard.html.phase474_9_pre_body_isolation.bak:543:    patchNode(panel, "operator-guidance-panel");
public/dashboard.html.phase474_9_pre_body_isolation.bak:544:    patchNode(response, "operator-guidance-response");
public/dashboard.html.phase474_9_pre_body_isolation.bak:545:    patchNode(meta, "operator-guidance-meta");
public/dashboard.html.phase479_0_pre_phase61_workspace_consolidation_restore.bak:128:                      <div id="operator-guidance-panel" class="mt-4 rounded-xl border border-gray-700 bg-gray-900/70 p-4 min-h-[140px]">
public/dashboard.html.phase479_0_pre_phase61_workspace_consolidation_restore.bak:129:                        <div class="text-xs uppercase tracking-[0.2em] text-gray-500 mb-3">Operator Guidance</div>
public/dashboard.html.phase479_0_pre_phase61_workspace_consolidation_restore.bak:130:                        <div id="operator-guidance-response" class="text-sm text-gray-300 leading-6">
public/dashboard.html.phase479_0_pre_phase61_workspace_consolidation_restore.bak:131:                          Awaiting bounded guidance stream.<br>
public/dashboard.html.phase479_0_pre_phase61_workspace_consolidation_restore.bak:132:                          Live operator guidance will appear here when visibility wiring is active.
public/dashboard.html.phase479_0_pre_phase61_workspace_consolidation_restore.bak:134:                        <div id="operator-guidance-meta" class="mt-3 text-xs text-gray-500 leading-5">
public/dashboard.html.phase479_0_pre_phase61_workspace_consolidation_restore.bak:136:                          Sources: diagnostics/system-health
public/dashboard.html.phase476_6_pre_strip.bak:129:                      <div id="operator-guidance-panel" class="mt-4 rounded-xl border border-gray-700 bg-gray-900/70 p-4 min-h-[140px]">
public/dashboard.html.phase476_6_pre_strip.bak:130:                        <div class="text-xs uppercase tracking-[0.2em] text-gray-500 mb-3">Operator Guidance</div>
public/dashboard.html.phase476_6_pre_strip.bak:131:                        <div id="operator-guidance-response" class="text-sm text-gray-300 leading-6">
public/dashboard.html.phase476_6_pre_strip.bak:132:                          Awaiting bounded guidance stream.<br>
public/dashboard.html.phase476_6_pre_strip.bak:133:                          Live operator guidance will appear here when visibility wiring is active.
public/dashboard.html.phase476_6_pre_strip.bak:135:                        <div id="operator-guidance-meta" class="mt-3 text-xs text-gray-500 leading-5">
public/dashboard.html.phase476_6_pre_strip.bak:137:                          Sources: diagnostics/system-health
public/dashboard.html.phase476_6_pre_strip.bak:379:    <script id="phase464x-guidance-dom-probe">
public/dashboard.html.phase476_6_pre_strip.bak:436:    const panel = byId("operator-guidance-panel");
public/dashboard.html.phase476_6_pre_strip.bak:437:    const response = byId("operator-guidance-response");
public/dashboard.html.phase476_6_pre_strip.bak:438:    const meta = byId("operator-guidance-meta");
public/dashboard.html.phase476_6_pre_strip.bak:460:    const existing = byId("phase464x-guidance-dom-probe-output");
public/dashboard.html.phase476_6_pre_strip.bak:464:    sink.id = "phase464x-guidance-dom-probe-output";
public/dashboard.html.phase476_6_pre_strip.bak:543:    patchNode(panel, "operator-guidance-panel");
public/dashboard.html.phase476_6_pre_strip.bak:544:    patchNode(response, "operator-guidance-response");
public/dashboard.html.phase476_6_pre_strip.bak:545:    patchNode(meta, "operator-guidance-meta");
public/dashboard.html.phase471_4_bundle_boot_neutralized.bak:508:                      <div id="operator-guidance-panel" class="mt-4 rounded-xl border border-gray-700 bg-gray-900/70 p-4 min-h-[140px]">
public/dashboard.html.phase471_4_bundle_boot_neutralized.bak:509:                        <div class="text-xs uppercase tracking-[0.2em] text-gray-500 mb-3">Operator Guidance</div>
public/dashboard.html.phase471_4_bundle_boot_neutralized.bak:510:                        <div id="operator-guidance-response" class="text-sm text-gray-300 leading-6">
public/dashboard.html.phase471_4_bundle_boot_neutralized.bak:511:                          Awaiting bounded guidance stream.<br>
public/dashboard.html.phase471_4_bundle_boot_neutralized.bak:512:                          Live operator guidance will appear here when visibility wiring is active.
public/dashboard.html.phase471_4_bundle_boot_neutralized.bak:514:                        <div id="operator-guidance-meta" class="mt-3 text-xs text-gray-500 leading-5">
public/dashboard.html.phase471_4_bundle_boot_neutralized.bak:516:                          Sources: diagnostics/system-health
public/dashboard.html.phase471_4_bundle_boot_neutralized.bak:758:    <script id="phase464x-guidance-dom-probe">
public/dashboard.html.phase471_4_bundle_boot_neutralized.bak:815:    const panel = byId("operator-guidance-panel");
public/dashboard.html.phase471_4_bundle_boot_neutralized.bak:816:    const response = byId("operator-guidance-response");
public/dashboard.html.phase471_4_bundle_boot_neutralized.bak:817:    const meta = byId("operator-guidance-meta");
public/dashboard.html.phase471_4_bundle_boot_neutralized.bak:839:    const existing = byId("phase464x-guidance-dom-probe-output");
public/dashboard.html.phase471_4_bundle_boot_neutralized.bak:843:    sink.id = "phase464x-guidance-dom-probe-output";
public/dashboard.html.phase471_4_bundle_boot_neutralized.bak:922:    patchNode(panel, "operator-guidance-panel");
public/dashboard.html.phase471_4_bundle_boot_neutralized.bak:923:    patchNode(response, "operator-guidance-response");
public/dashboard.html.phase471_4_bundle_boot_neutralized.bak:924:    patchNode(meta, "operator-guidance-meta");
public/dashboard.html.phase472_1_external_css_neutralized.bak:508:                      <div id="operator-guidance-panel" class="mt-4 rounded-xl border border-gray-700 bg-gray-900/70 p-4 min-h-[140px]">
public/dashboard.html.phase472_1_external_css_neutralized.bak:509:                        <div class="text-xs uppercase tracking-[0.2em] text-gray-500 mb-3">Operator Guidance</div>
public/dashboard.html.phase472_1_external_css_neutralized.bak:510:                        <div id="operator-guidance-response" class="text-sm text-gray-300 leading-6">
public/dashboard.html.phase472_1_external_css_neutralized.bak:511:                          Awaiting bounded guidance stream.<br>
public/dashboard.html.phase472_1_external_css_neutralized.bak:512:                          Live operator guidance will appear here when visibility wiring is active.
public/dashboard.html.phase472_1_external_css_neutralized.bak:514:                        <div id="operator-guidance-meta" class="mt-3 text-xs text-gray-500 leading-5">
public/dashboard.html.phase472_1_external_css_neutralized.bak:516:                          Sources: diagnostics/system-health
public/dashboard.html.phase472_1_external_css_neutralized.bak:758:    <script id="phase464x-guidance-dom-probe">
public/dashboard.html.phase472_1_external_css_neutralized.bak:815:    const panel = byId("operator-guidance-panel");
public/dashboard.html.phase472_1_external_css_neutralized.bak:816:    const response = byId("operator-guidance-response");
public/dashboard.html.phase472_1_external_css_neutralized.bak:817:    const meta = byId("operator-guidance-meta");
public/dashboard.html.phase472_1_external_css_neutralized.bak:839:    const existing = byId("phase464x-guidance-dom-probe-output");
public/dashboard.html.phase472_1_external_css_neutralized.bak:843:    sink.id = "phase464x-guidance-dom-probe-output";
public/dashboard.html.phase472_1_external_css_neutralized.bak:922:    patchNode(panel, "operator-guidance-panel");
public/dashboard.html.phase472_1_external_css_neutralized.bak:923:    patchNode(response, "operator-guidance-response");
public/dashboard.html.phase472_1_external_css_neutralized.bak:924:    patchNode(meta, "operator-guidance-meta");
server/routes/api-guidance.mjs:12:        guidance_available: false,
server/routes/api-guidance.mjs:13:        guidance: null,
server/routes/api-guidance.mjs:19:      guidance_available: true,
server/routes/api-guidance.mjs:20:      guidance: {
server/routes/api-guidance.mjs:28:        note: "minimal_deterministic_guidance_stream"
server/routes/api-guidance.mjs:35:      guidance_available: false,
server/routes/api-guidance.mjs:36:      guidance: null,
public/dashboard.html.bak.1762372376:132:      await updatePanel("system-health-content", "/diagnostics/system-health");
public/dashboard.html.phase478_5_pre_repo_stylesheet_restore.bak:128:                      <div id="operator-guidance-panel" class="mt-4 rounded-xl border border-gray-700 bg-gray-900/70 p-4 min-h-[140px]">
public/dashboard.html.phase478_5_pre_repo_stylesheet_restore.bak:129:                        <div class="text-xs uppercase tracking-[0.2em] text-gray-500 mb-3">Operator Guidance</div>
public/dashboard.html.phase478_5_pre_repo_stylesheet_restore.bak:130:                        <div id="operator-guidance-response" class="text-sm text-gray-300 leading-6">
public/dashboard.html.phase478_5_pre_repo_stylesheet_restore.bak:131:                          Awaiting bounded guidance stream.<br>
public/dashboard.html.phase478_5_pre_repo_stylesheet_restore.bak:132:                          Live operator guidance will appear here when visibility wiring is active.
public/dashboard.html.phase478_5_pre_repo_stylesheet_restore.bak:134:                        <div id="operator-guidance-meta" class="mt-3 text-xs text-gray-500 leading-5">
public/dashboard.html.phase478_5_pre_repo_stylesheet_restore.bak:136:                          Sources: diagnostics/system-health
public/dashboard.html.phase478_4_pre_dashboard_css_restore.bak:128:                      <div id="operator-guidance-panel" class="mt-4 rounded-xl border border-gray-700 bg-gray-900/70 p-4 min-h-[140px]">
public/dashboard.html.phase478_4_pre_dashboard_css_restore.bak:129:                        <div class="text-xs uppercase tracking-[0.2em] text-gray-500 mb-3">Operator Guidance</div>
public/dashboard.html.phase478_4_pre_dashboard_css_restore.bak:130:                        <div id="operator-guidance-response" class="text-sm text-gray-300 leading-6">
public/dashboard.html.phase478_4_pre_dashboard_css_restore.bak:131:                          Awaiting bounded guidance stream.<br>
public/dashboard.html.phase478_4_pre_dashboard_css_restore.bak:132:                          Live operator guidance will appear here when visibility wiring is active.
public/dashboard.html.phase478_4_pre_dashboard_css_restore.bak:134:                        <div id="operator-guidance-meta" class="mt-3 text-xs text-gray-500 leading-5">
public/dashboard.html.phase478_4_pre_dashboard_css_restore.bak:136:                          Sources: diagnostics/system-health
public/dashboard_body_bottom_half_probe.html:111:    <script id="phase464x-guidance-dom-probe">
public/dashboard_body_bottom_half_probe.html:168:    const panel = byId("operator-guidance-panel");
public/dashboard_body_bottom_half_probe.html:169:    const response = byId("operator-guidance-response");
public/dashboard_body_bottom_half_probe.html:170:    const meta = byId("operator-guidance-meta");
public/dashboard_body_bottom_half_probe.html:192:    const existing = byId("phase464x-guidance-dom-probe-output");
public/dashboard_body_bottom_half_probe.html:196:    sink.id = "phase464x-guidance-dom-probe-output";
public/dashboard_body_bottom_half_probe.html:275:    patchNode(panel, "operator-guidance-panel");
public/dashboard_body_bottom_half_probe.html:276:    patchNode(response, "operator-guidance-response");
public/dashboard_body_bottom_half_probe.html:277:    patchNode(meta, "operator-guidance-meta");
public/index.html:161:    #operator-guidance-panel,
public/index.html:316:                    <div id="operator-guidance-panel" class="mt-3 rounded-xl border border-gray-700 bg-gray-900/70 p-4">
public/index.html:317:                      <div class="text-xs uppercase tracking-[0.2em] text-gray-500 mb-2">Operator Guidance</div>
public/index.html:318:                      <div id="operator-guidance-response" class="text-sm text-gray-300 leading-6">
public/index.html:319:                        Awaiting bounded guidance stream.<br />
public/index.html:320:                        Live operator guidance will appear here when visibility wiring is active.
public/index.html:322:                      <div id="operator-guidance-meta" class="mt-3 text-xs text-gray-500 leading-5">
public/index.html:324:                        Sources: diagnostics/system-health
public/index.html:587:    <div style="font-size:14px;margin-bottom:10px;opacity:0.8;">Operator Guidance — Reasoning</div>
public/index.html:591:      • No active guidance stream<br>
public/index.html:597:      • Live guidance stream detected<br>
public/index.html:626:  guidance_availability: null,
public/index.html:647:    • guidance_availability: ${val(s.guidance_availability)}<br>
public/index.html:661:// PHASE 495 — WIRE guidance_availability (SAFE, NO COMPUTATION)
public/index.html:665:    const res = await fetch("/diagnostics/system-health");
public/index.html:670:      window.__PHASE494_SIGNALS__.guidance_availability = "absent";
public/index.html:673:      if (data.operatorGuidance || data.guidanceStream) {
public/index.html:674:        window.__PHASE494_SIGNALS__.guidance_availability = "present";
public/index.html:678:    window.__PHASE494_SIGNALS__.guidance_availability = "unknown";
public/index.html:719:    const res = await fetch("/diagnostics/system-health");
public/index.html:756:    const res = await fetch("/diagnostics/system-health");
public/index.html:805:    const res = await fetch("/diagnostics/system-health");
public/index.html:871:    "guidance_availability",
public/index.html:891:    signals.guidance_availability === "present" &&
public/index.html:903:    signals.guidance_availability === "present" &&
public/index.html:983:// PHASE 509 — WIRE guidance_availability FROM REAL ENDPOINT (NO FAKE SIGNALS)
public/index.html:987:    const res = await fetch("/api/guidance");
public/index.html:993:    window.__PHASE494_SIGNALS__.guidance_availability = "absent";
public/index.html:996:    if (data && data.guidance_available === true) {
public/index.html:997:      window.__PHASE494_SIGNALS__.guidance_availability = "present";
public/index.html:1002:      window.__PHASE494_SIGNALS__.guidance_availability = "unknown";
public/index.html:1133:  #operator-guidance-panel,
public/dashboard.html.bak:205:      await updatePanel("system-health-content", "/diagnostics/system-health");
public/dashboard.html:133:                      <div id="operator-guidance-panel" class="mt-4 rounded-xl border border-gray-700 bg-gray-900/70 p-4 min-h-[140px]">
public/dashboard.html:134:                        <div class="text-xs uppercase tracking-[0.2em] text-gray-500 mb-3">Operator Guidance</div>
public/dashboard.html:135:                        <div id="operator-guidance-response" class="text-sm text-gray-300 leading-6">
public/dashboard.html:136:                          Awaiting bounded guidance stream.<br>
public/dashboard.html:137:                          Live operator guidance will appear here when visibility wiring is active.
public/dashboard.html:139:                        <div id="operator-guidance-meta" class="mt-3 text-xs text-gray-500 leading-5">
public/dashboard.html:141:                          Sources: diagnostics/system-health
public/dashboard.html:275:    var el = document.getElementById("operator-guidance-meta");
public/dashboard.html:294:    <div style="font-size:14px;margin-bottom:10px;opacity:0.8;">Operator Guidance — Reasoning</div>
public/dashboard.html:298:      • No active guidance stream<br>
public/dashboard.html:304:      • Live guidance stream detected<br>
public/dashboard.html:333:  guidance_availability: null,
public/dashboard.html:354:    • guidance_availability: ${val(s.guidance_availability)}<br>
public/dashboard.html:368:// PHASE 495 — WIRE guidance_availability (SAFE, NO COMPUTATION)
public/dashboard.html:372:    const res = await fetch("/diagnostics/system-health");
public/dashboard.html:377:      window.__PHASE494_SIGNALS__.guidance_availability = "absent";
public/dashboard.html:380:      if (data.operatorGuidance || data.guidanceStream) {
public/dashboard.html:381:        window.__PHASE494_SIGNALS__.guidance_availability = "present";
public/dashboard.html:385:    window.__PHASE494_SIGNALS__.guidance_availability = "unknown";
public/dashboard.html:426:    const res = await fetch("/diagnostics/system-health");
public/dashboard.html:463:    const res = await fetch("/diagnostics/system-health");
public/dashboard.html:512:    const res = await fetch("/diagnostics/system-health");
public/dashboard.html:578:    "guidance_availability",
public/dashboard.html:598:    signals.guidance_availability === "present" &&
public/dashboard.html:610:    signals.guidance_availability === "present" &&
public/dashboard.html:697:    const meta = document.getElementById("operator-guidance-meta");
public/dashboard.html:706:        Sources: diagnostics/system-health
public/dashboard.html:715:      "guidance_availability",
public/dashboard.html:729:          Sources: diagnostics/system-health
public/dashboard.html:739:        Sources: diagnostics/system-health
public/dashboard.html:747:      Sources: diagnostics/system-health
public/dashboard.html:761:// PHASE 509 — WIRE guidance_availability FROM REAL ENDPOINT (NO FAKE SIGNALS)
public/dashboard.html:765:    const res = await fetch("/api/guidance");
public/dashboard.html:771:    window.__PHASE494_SIGNALS__.guidance_availability = "absent";
public/dashboard.html:774:    if (data && data.guidance_available === true) {
public/dashboard.html:775:      window.__PHASE494_SIGNALS__.guidance_availability = "present";
public/dashboard.html:780:      window.__PHASE494_SIGNALS__.guidance_availability = "unknown";
scripts/_local/phase457t_apply_ops_renderer_fix_and_verify.sh:29:  grep -n 'operator-guidance-panel' "$TMP_HTML" || true
scripts/_local/phase457t_apply_ops_renderer_fix_and_verify.sh:30:  grep -n 'operator-guidance-response' "$TMP_HTML" || true
scripts/_local/phase457t_apply_ops_renderer_fix_and_verify.sh:31:  grep -n 'operator-guidance-meta' "$TMP_HTML" || true
scripts/_local/phase457t_apply_ops_renderer_fix_and_verify.sh:64:  echo "EXPECTED=operator guidance should remain in structured multiline form without alternating"
public/dashboard_body_q1_probe.html:134:                      <div id="operator-guidance-panel" class="mt-4 rounded-xl border border-gray-700 bg-gray-900/70 p-4 min-h-[140px]">
public/dashboard_body_q1_probe.html:135:                        <div class="text-xs uppercase tracking-[0.2em] text-gray-500 mb-3">Operator Guidance</div>
public/dashboard_body_q1_probe.html:136:                        <div id="operator-guidance-response" class="text-sm text-gray-300 leading-6">
public/dashboard_body_q1_probe.html:137:                          Awaiting bounded guidance stream.<br>
public/dashboard_body_q1_probe.html:138:                          Live operator guidance will appear here when visibility wiring is active.
public/dashboard_body_q1_probe.html:140:                        <div id="operator-guidance-meta" class="mt-3 text-xs text-gray-500 leading-5">
public/dashboard_body_q1_probe.html:142:                          Sources: diagnostics/system-health
public/dashboard.html.phase477_2_pre_probe_banner_removal.bak:137:                      <div id="operator-guidance-panel" class="mt-4 rounded-xl border border-gray-700 bg-gray-900/70 p-4 min-h-[140px]">
public/dashboard.html.phase477_2_pre_probe_banner_removal.bak:138:                        <div class="text-xs uppercase tracking-[0.2em] text-gray-500 mb-3">Operator Guidance</div>
public/dashboard.html.phase477_2_pre_probe_banner_removal.bak:139:                        <div id="operator-guidance-response" class="text-sm text-gray-300 leading-6">
public/dashboard.html.phase477_2_pre_probe_banner_removal.bak:140:                          Awaiting bounded guidance stream.<br>
public/dashboard.html.phase477_2_pre_probe_banner_removal.bak:141:                          Live operator guidance will appear here when visibility wiring is active.
public/dashboard.html.phase477_2_pre_probe_banner_removal.bak:143:                        <div id="operator-guidance-meta" class="mt-3 text-xs text-gray-500 leading-5">
public/dashboard.html.phase477_2_pre_probe_banner_removal.bak:145:                          Sources: diagnostics/system-health
public/dashboard.html.phase477_2_pre_probe_banner_removal.bak:400:    <script id="phase464x-guidance-dom-probe">
public/dashboard.html.phase477_2_pre_probe_banner_removal.bak:460:    const panel = byId("operator-guidance-panel");
public/dashboard.html.phase477_2_pre_probe_banner_removal.bak:461:    const response = byId("operator-guidance-response");
public/dashboard.html.phase477_2_pre_probe_banner_removal.bak:462:    const meta = byId("operator-guidance-meta");
public/dashboard.html.phase477_2_pre_probe_banner_removal.bak:484:    const existing = byId("phase464x-guidance-dom-probe-output");
public/dashboard.html.phase477_2_pre_probe_banner_removal.bak:488:    sink.id = "phase464x-guidance-dom-probe-output";
public/dashboard.html.phase477_2_pre_probe_banner_removal.bak:567:    patchNode(panel, "operator-guidance-panel");
public/dashboard.html.phase477_2_pre_probe_banner_removal.bak:568:    patchNode(response, "operator-guidance-response");
public/dashboard.html.phase477_2_pre_probe_banner_removal.bak:569:    patchNode(meta, "operator-guidance-meta");
public/dashboard_body_q3_probe.html:113:    <script id="phase464x-guidance-dom-probe">
public/dashboard.html.phase473_9_pre_styles_restore.bak:508:                      <div id="operator-guidance-panel" class="mt-4 rounded-xl border border-gray-700 bg-gray-900/70 p-4 min-h-[140px]">
public/dashboard.html.phase473_9_pre_styles_restore.bak:509:                        <div class="text-xs uppercase tracking-[0.2em] text-gray-500 mb-3">Operator Guidance</div>
public/dashboard.html.phase473_9_pre_styles_restore.bak:510:                        <div id="operator-guidance-response" class="text-sm text-gray-300 leading-6">
public/dashboard.html.phase473_9_pre_styles_restore.bak:511:                          Awaiting bounded guidance stream.<br>
public/dashboard.html.phase473_9_pre_styles_restore.bak:512:                          Live operator guidance will appear here when visibility wiring is active.
public/dashboard.html.phase473_9_pre_styles_restore.bak:514:                        <div id="operator-guidance-meta" class="mt-3 text-xs text-gray-500 leading-5">
public/dashboard.html.phase473_9_pre_styles_restore.bak:516:                          Sources: diagnostics/system-health
public/dashboard.html.phase473_9_pre_styles_restore.bak:758:    <script id="phase464x-guidance-dom-probe">
public/dashboard.html.phase473_9_pre_styles_restore.bak:815:    const panel = byId("operator-guidance-panel");
public/dashboard.html.phase473_9_pre_styles_restore.bak:816:    const response = byId("operator-guidance-response");
public/dashboard.html.phase473_9_pre_styles_restore.bak:817:    const meta = byId("operator-guidance-meta");
public/dashboard.html.phase473_9_pre_styles_restore.bak:839:    const existing = byId("phase464x-guidance-dom-probe-output");
public/dashboard.html.phase473_9_pre_styles_restore.bak:843:    sink.id = "phase464x-guidance-dom-probe-output";
public/dashboard.html.phase473_9_pre_styles_restore.bak:922:    patchNode(panel, "operator-guidance-panel");
public/dashboard.html.phase473_9_pre_styles_restore.bak:923:    patchNode(response, "operator-guidance-response");
public/dashboard.html.phase473_9_pre_styles_restore.bak:924:    patchNode(meta, "operator-guidance-meta");
public/js/phase457_neutralize_legacy_observational_consumers.js:8:  // Disable operator guidance normalization ONLY
public/dashboard_body_q4_probe.html:32:    const panel = byId("operator-guidance-panel");
public/dashboard_body_q4_probe.html:33:    const response = byId("operator-guidance-response");
public/dashboard_body_q4_probe.html:34:    const meta = byId("operator-guidance-meta");
```

## Served bundle guidance references

```
public/index.html:324:                        Sources: diagnostics/system-health
public/index.html:665:    const res = await fetch("/diagnostics/system-health");
public/index.html:719:    const res = await fetch("/diagnostics/system-health");
public/index.html:756:    const res = await fetch("/diagnostics/system-health");
public/index.html:805:    const res = await fetch("/diagnostics/system-health");
public/index.html:987:    const res = await fetch("/api/guidance");
public/index.html:996:    if (data && data.guidance_available === true) {
public/dashboard.html:141:                          Sources: diagnostics/system-health
public/dashboard.html:372:    const res = await fetch("/diagnostics/system-health");
public/dashboard.html:426:    const res = await fetch("/diagnostics/system-health");
public/dashboard.html:463:    const res = await fetch("/diagnostics/system-health");
public/dashboard.html:512:    const res = await fetch("/diagnostics/system-health");
public/dashboard.html:706:        Sources: diagnostics/system-health
public/dashboard.html:729:          Sources: diagnostics/system-health
public/dashboard.html:739:        Sources: diagnostics/system-health
public/dashboard.html:747:      Sources: diagnostics/system-health
public/dashboard.html:765:    const res = await fetch("/api/guidance");
public/dashboard.html:774:    if (data && data.guidance_available === true) {
```

## Likely diagnosis

- /api/guidance is live but currently returns guidance_available=false.
- /diagnostics/system-health is live and returns a usable situationSummary.
- If the UI does not already fall back to situationSummary, the remaining issue is a UI render contract gap, not a missing backend route.
- Safe next patch corridor: render Operator Guidance from /api/guidance when available, otherwise fall back to /diagnostics/system-health.situationSummary.
