export function deriveDecisionListTitle(value: string): string {
  const normalized = value.trim().replace(/\s+/g, " ");

  if (normalized.length <= 64) {
    return normalized;
  }

  const bounded = normalized.slice(0, 64);
  const finalWhitespaceIndex = bounded.lastIndexOf(" ");
  const prefix =
    finalWhitespaceIndex > 0
      ? bounded.slice(0, finalWhitespaceIndex)
      : bounded;

  return `${prefix}…`;
}
