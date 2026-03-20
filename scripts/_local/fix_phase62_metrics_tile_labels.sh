#!/usr/bin/env bash
set -euo pipefail

cd "$(git rev-parse --show-toplevel)"

python3 <<'PY'
from pathlib import Path

targets = [
    Path("public/dashboard.html"),
    Path("public/js/agent-status-row.js"),
    Path("public/bundle.js"),
]

marker = "PHASE62B_METRIC_LABEL_FIX"

js_block = r"""
;/* PHASE62B_METRIC_LABEL_FIX */
(() => {
  if (typeof window === 'undefined') return;
  if (window.__PHASE62B_METRIC_LABEL_FIX__) return;
  window.__PHASE62B_METRIC_LABEL_FIX__ = true;

  const metricNames = [
    "Active Agents",
    "Tasks Running",
    "Success Rate",
    "Latency"
  ];

  const containers = Array.from(
    document.querySelectorAll(
      '.metrics-row > *, #metrics-row > *, .metric-card, .telemetry-tile, .metric-tile'
    )
  ).slice(0,4);

  containers.forEach((el, i) => {
    if (!metricNames[i]) return;

    let label =
      el.querySelector('.metric-label') ||
      el.querySelector('.telemetry-label') ||
      el.querySelector('[data-metric-label]');

    if (!label) {
      label = document.createElement('div');
      label.className = 'metric-label';
      label.style.opacity = '0.7';
      label.style.fontSize = '12px';
      label.style.letterSpacing = '0.08em';
      label.style.textTransform = 'uppercase';
      label.style.marginTop = '6px';

      el.appendChild(label);
    }

    label.textContent = metricNames[i];
  });
})();
"""

for path in targets:
    if not path.exists():
        continue

    if path.suffix == ".html":
        continue

    original = path.read_text()

    if marker in original:
        continue

    path.write_text(original.rstrip() + "\n" + js_block.strip() + "\n")
    print(f"patched {path}")
PY
