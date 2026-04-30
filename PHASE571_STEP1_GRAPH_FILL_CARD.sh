#!/bin/bash
set -e

echo "Adding graph fill-card layout override..."

cat > public/js/phase571_graph_fill_card.js << 'JS'
(function () {
  function applyGraphFill() {
    const canvas = document.getElementById("task-activity-graph");
    if (!canvas) return;

    const wrapper = canvas.parentElement;
    const card = document.getElementById("task-activity-card");
    const panel = document.getElementById("obs-panel-activity");

    if (panel) {
      panel.style.minHeight = "0";
      panel.style.height = "100%";
    }

    if (card) {
      card.style.display = "flex";
      card.style.flexDirection = "column";
      card.style.minHeight = "0";
      card.style.height = "100%";
    }

    if (wrapper) {
      wrapper.style.flex = "1 1 auto";
      wrapper.style.minHeight = "0";
      wrapper.style.height = "100%";
      wrapper.style.display = "flex";
    }

    canvas.style.flex = "1 1 auto";
    canvas.style.width = "100%";
    canvas.style.height = "100%";
    canvas.style.minHeight = "0";
  }

  if (document.readyState === "loading") {
    document.addEventListener("DOMContentLoaded", applyGraphFill, { once: true });
  } else {
    applyGraphFill();
  }
})();
JS

python3 - << 'PY'
from pathlib import Path

path = Path("public/index.html")
text = path.read_text()

needle = '  <script defer src="js/dashboard-graph.js"></script>'
insert = needle + '\n  <script defer src="js/phase571_graph_fill_card.js"></script>'

if 'phase571_graph_fill_card.js' not in text:
    if needle not in text:
        raise SystemExit("dashboard-graph.js script anchor not found")
    text = text.replace(needle, insert, 1)
    path.write_text(text)
    print("Inserted phase571_graph_fill_card.js")
else:
    print("phase571_graph_fill_card.js already loaded")
PY

node --check public/js/phase571_graph_fill_card.js
docker compose up -d --build dashboard

git add public/index.html public/js/phase571_graph_fill_card.js PHASE571_STEP1_GRAPH_FILL_CARD.sh
git commit -m "Phase 571: make task activity graph fill telemetry card"
git push
