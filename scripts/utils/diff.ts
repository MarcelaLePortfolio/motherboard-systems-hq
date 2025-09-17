// scripts/utils/diff.ts
export function generateDiff(oldText: string, newText: string): string {
  const oldLines = oldText.split('\n');
  const newLines = newText.split('\n');
  const max = Math.max(oldLines.length, newLines.length);
  const lines = [];

  for (let i = 0; i < max; i++) {
    const oldLine = oldLines[i] ?? '';
    const newLine = newLines[i] ?? '';
    if (oldLine !== newLine) {
      lines.push(`- ${oldLine}`);
      lines.push(`+ ${newLine}`);
    }
  }

  return lines.length ? lines.join('\n') : '🟢 No changes detected.';
}
