export function isExplicitEvidenceRequest(
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
    /^what evidence supports (?:that|this|your conclusion|your recommendation)\??$/,
    /^what repository evidence supports (?:that|this|your conclusion|your recommendation)(?:\s+.+)?\??$/,
    /^what repository evidence shows (?:that|this)(?:\s+.+)?\??$/,
    /^show me the repository evidence\.?$/,
    /^what evidence do we have in the repository\??$/,
  ];

  return explicitPatterns.some((pattern) =>
    pattern.test(normalized),
  );
}
