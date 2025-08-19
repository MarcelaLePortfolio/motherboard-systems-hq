export type ChunkOptions = {
  chunkSize?: number;
  chunkOverlap?: number;
};

export function chunkText(text: string, opts: ChunkOptions = {}): string[] {
  const size = Math.max(200, Math.min(4000, opts.chunkSize ?? 1000));
  const overlap = Math.max(0, Math.min(size - 1, opts.chunkOverlap ?? Math.floor(size * 0.1)));

  if (!text || typeof text !== 'string') return [];

  const clean = text.replace(/\r\n/g, '\n').trim();
  const chunks: string[] = [];
  let start = 0;

  while (start < clean.length) {
    let end = Math.min(clean.length, start + size);

    if (end < clean.length) {
      const window = clean.slice(start, end);

      const lastBreak = Math.max(
        window.lastIndexOf('\n\n'),
        window.lastIndexOf('. '),
        window.lastIndexOf('! '),
        window.lastIndexOf('? ')
      );

      // Prefer breaking at a natural boundary if it's far enough into the chunk
      if (lastBreak > size * 0.6) {
        end = start + lastBreak + 1;
      }
    }

    const chunk = clean.slice(start, end).trim();
    if (chunk) chunks.push(chunk);

    start = end - overlap;
    if (start < 0) start = 0;
  }

  return chunks;
}