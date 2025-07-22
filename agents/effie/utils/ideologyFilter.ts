export const BLOCKLIST = [
  "patriot",
  "woke",
  "feminist",
  "anti",
  "loyalty",
  "conservative",
  "liberal"
];

export function isBlocked(output: string): string | null {
  if (process.env.EFFIE_FILTER === "false") return null;

  for (const flag of BLOCKLIST) {
    if (output.toLowerCase().includes(flag)) {
      return flag;
    }
  }
  return null;
}
