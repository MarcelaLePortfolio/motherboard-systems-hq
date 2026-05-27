export function computeBackoffMs({
  attempt = 1,
  baseMs = 1000,
  capMs = 5 * 60 * 1000,
  jitterPct = 0.2,
} = {}) {
  const a = Math.max(1, Number(attempt) || 1);
  const base = Math.max(1, Number(baseMs) || 1000);
  const cap = Math.max(base, Number(capMs) || base);
  const pct = Math.min(1, Math.max(0, Number(jitterPct) || 0));

  let backoff = base * Math.pow(2, a - 1);
  if (!Number.isFinite(backoff) || backoff < 0) backoff = base;
  if (backoff > cap) backoff = cap;

  const jitterMax = Math.floor(backoff * pct);
  const jitter = jitterMax > 0 ? Math.floor(Math.random() * (jitterMax + 1)) : 0;

  return Math.floor(backoff + jitter);
}
