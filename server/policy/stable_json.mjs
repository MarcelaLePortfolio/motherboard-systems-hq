export function stableStringify(value) {
  return JSON.stringify(sortDeep(value));
}

function sortDeep(x) {
  if (x === null || typeof x !== 'object') return x;

  if (Array.isArray(x)) {
    // Preserve array order (policy order is meaningful); but make elements stable.
    return x.map(sortDeep);
  }

  const out = {};
  for (const k of Object.keys(x).sort()) {
    out[k] = sortDeep(x[k]);
  }
  return out;
}
