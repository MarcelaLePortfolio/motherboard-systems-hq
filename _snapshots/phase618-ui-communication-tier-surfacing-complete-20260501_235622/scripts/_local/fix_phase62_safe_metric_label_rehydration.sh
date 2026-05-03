#!/usr/bin/env bash
set -euo pipefail

cd "$(git rev-parse --show-toplevel)"

python3 <<'PY'
from pathlib import Path
import re

targets = [
    Path("public/js/agent-status-row.js"),
    Path("public/bundle.js"),
]

marker = "PHASE62B_SAFE_METRIC_LABEL_REHYDRATION"

block = r"""
;/* PHASE62B_SAFE_METRIC_LABEL_REHYDRATION */
(() => {
  if (typeof window === 'undefined') return;
  if (window.__PHASE62B_SAFE_METRIC_LABEL_REHYDRATION__) return;
  window.__PHASE62B_SAFE_METRIC_LABEL_REHYDRATION__ = true;

  const metricNames = [
    'Active Agents',
    'Tasks Running',
    'Success Rate',
    'Latency'
  ];

  const tileSelectors = [
    '#metrics-row > *',
    '.metrics-row > *',
    '.metric-card',
    '.telemetry-tile',
    '.metric-tile',
    '.metrics-tile'
  ].join(',');

  const valueSelectors = [
    '[data-metric-value]',
    '.metric-value',
    '.telemetry-value',
    '.stat-value',
    '.value',
    'h1',
    'h2',
    'h3',
    'strong'
  ].join(',');

  const getTiles = () => {
    const seen = new Set();
    return Array.from(document.querySelectorAll(tileSelectors))
      .filter((el) => {
        if (!el || seen.has(el)) return false;
        seen.add(el);
        return true;
      })
      .slice(0, 4);
  };

  const styleLabel = (el) => {
    el.style.opacity = '0.7';
    el.style.fontSize = '12px';
    el.style.letterSpacing = '0.08em';
    el.style.textTransform = 'uppercase';
    el.style.marginTop = '6px';
    el.style.lineHeight = '1.2';
    el.style.display = 'block';
  };

  const ensureLabel = (tile, index) => {
    const labelText = metricNames[index];
    if (!labelText) return;

    let labelEl =
      tile.querySelector('.phase62-metric-label') ||
      tile.querySelector('.metric-label') ||
      tile.querySelector('.telemetry-label');

    if (!labelEl) {
      labelEl = document.createElement('div');
      labelEl.className = 'phase62-metric-label';
    }

    labelEl.textContent = labelText;
    styleLabel(labelEl);

    const valueEl = tile.querySelector(valueSelectors);
    if (valueEl && valueEl !== labelEl) {
      if (labelEl.parentNode !== tile || labelEl.previousSibling !== valueEl) {
        if (labelEl.parentNode) labelEl.parentNode.removeChild(labelEl);
        tile.insertBefore(labelEl, valueEl.nextSibling);
      }
      return;
    }

    if (labelEl.parentNode !== tile) {
      if (labelEl.parentNode) labelEl.parentNode.removeChild(labelEl);
      tile.appendChild(labelEl);
    }
  };

  const apply = () => {
    getTiles().forEach(ensureLabel);
  };

  if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', apply, { once: true });
  } else {
    apply();
  }

  window.addEventListener('mb:ops:update', apply);
  window.addEventListener('mb.task.event', apply);
  window.setInterval(apply, 1000);

  const metricsRow =
    document.getElementById('metrics-row') ||
    document.querySelector('.metrics-row');

  if (metricsRow && typeof MutationObserver !== 'undefined') {
    const observer = new MutationObserver(() => apply());
    observer.observe(metricsRow, { childList: true, subtree: true });
  }
})();
"""

def remove_marker_block(text: str, marker: str) -> str:
    pattern = re.compile(
        r'\n?;\/\*\s*' + re.escape(marker) + r'\s*\*\/\s*\(\(\)\s*=>\s*\{.*?\}\)\(\);\s*',
        re.DOTALL
    )
    return re.sub(pattern, '\n', text)

for path in targets:
    if not path.exists():
        raise SystemExit(f"missing target: {path}")

    original = path.read_text()
    updated = remove_marker_block(original, marker)
    updated = updated.rstrip() + "\n" + block.strip() + "\n"
    path.write_text(updated)
    print(f"patched {path}")
PY
