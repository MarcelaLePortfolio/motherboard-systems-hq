export function isExplicitExplanationRequest(
  message: string,
): boolean {
  const normalized = message
    .trim()
    .toLowerCase()
    .replace(/\s+/g, " ");

  if (!normalized) {
    return false;
  }

  const explicitPatterns = [
    /^why\??$/,
    /^why is that\??$/,
    /^why do you (?:recommend|say|think) that\??$/,
    /^explain(?: that| this| your recommendation| your conclusion)?\.?$/,
    /^please explain(?: that| this| your recommendation| your conclusion)?\.?$/,
    /^what evidence supports (?:that|this|your conclusion|your recommendation)\??$/,
    /^what supports (?:that|this|your conclusion|your recommendation)\??$/,
    /^walk me through the trade-?offs?\.?$/,
    /^walk me through why(?: you recommend that| that is the conclusion)?\.?$/,
    /^give me the engineering justification\.?$/,
    /^what is the engineering justification\??$/,
  ];

  return explicitPatterns.some((pattern) =>
    pattern.test(normalized),
  );
}
