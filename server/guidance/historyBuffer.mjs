// Phase 663 — Guidance History Buffer (READ-ONLY, NOT WIRED)

const MAX_HISTORY = 50;

let history = [];

export function addGuidanceSnapshot(snapshot) {
  if (!snapshot) return;

  history.unshift({
    timestamp: Date.now(),
    snapshot,
  });

  if (history.length > MAX_HISTORY) {
    history = history.slice(0, MAX_HISTORY);
  }
}

export function getGuidanceHistory() {
  return history;
}

export function clearGuidanceHistory() {
  history = [];
}
