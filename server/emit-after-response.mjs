/**
 * Wrap res.json so we can run a hook after the handler sends its JSON response.
 * This avoids rewriting the existing /api/* task routes.
 */
export function emitAfterJson(res, afterFn) {
  const orig = res.json.bind(res);
  res.json = (body) => {
    try { afterFn(body); } catch {}
    return orig(body);
  };
}
