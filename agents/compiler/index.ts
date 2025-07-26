export function compileInstruction(input: string): { steps: string[] } {
  const simplified = input
    .replace(/[.?!]/g, '')
    .split(/then|and|,|\n/)
    .map(s => s.trim())
    .filter(Boolean);

  return { steps: simplified };
}
