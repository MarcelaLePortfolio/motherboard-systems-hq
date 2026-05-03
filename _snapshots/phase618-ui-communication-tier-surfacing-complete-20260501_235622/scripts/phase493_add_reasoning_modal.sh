#!/usr/bin/env bash
set -euo pipefail

TARGET="public/dashboard.html"

STAMP="$(date +%Y%m%d_%H%M%S)"
BACKUP="/tmp/dashboard_pre_phase493_${STAMP}.bak"

cp "${TARGET}" "${BACKUP}"

# Insert button inside operator guidance panel
sed -i '' 's/Confidence: limited/<span>Confidence: limited<\/span><br><button id="phase493-view-reasoning" style="margin-top:6px;font-size:12px;opacity:0.8;">View reasoning<\/button>/' "${TARGET}"

# Append modal before </body>
cat >> "${TARGET}" << 'MODAL'

<!-- PHASE 493 REASONING MODAL -->
<div id="phase493-reasoning-modal" style="display:none;position:fixed;top:0;left:0;width:100%;height:100%;background:rgba(0,0,0,0.6);z-index:9999;">
  <div style="position:absolute;top:50%;left:50%;transform:translate(-50%,-50%);background:#111;padding:20px;border-radius:10px;width:90%;max-width:500px;color:#ddd;">
    
    <div style="font-size:14px;margin-bottom:10px;opacity:0.8;">Operator Guidance — Reasoning</div>

    <div style="font-size:13px;line-height:1.6;">
      <strong>Why confidence is limited:</strong><br>
      • No active guidance stream<br>
      • No evidence linked to request<br>
      • Governance not yet resolved<br>
      • Execution readiness unknown<br><br>

      <strong>What would increase confidence:</strong><br>
      • Live guidance stream detected<br>
      • Evidence attached to request<br>
      • Governance produces resolved output<br>
      • Execution path validated
    </div>

    <button id="phase493-close-modal" style="margin-top:12px;font-size:12px;">Close</button>
  </div>
</div>

<script>
// PHASE 493 MODAL CONTROL (SAFE - NO LOGIC)
document.addEventListener("DOMContentLoaded", function () {
  const btn = document.getElementById("phase493-view-reasoning");
  const modal = document.getElementById("phase493-reasoning-modal");
  const close = document.getElementById("phase493-close-modal");

  if (btn && modal && close) {
    btn.onclick = () => modal.style.display = "block";
    close.onclick = () => modal.style.display = "none";
    modal.onclick = (e) => { if (e.target === modal) modal.style.display = "none"; };
  }
});
</script>

MODAL

echo "Phase 493 modal patch applied to ${TARGET}"
