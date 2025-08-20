import fs from 'fs';
import readline from 'readline';
import { embed } from './embed';
import { db } from '../_local/database/db';
import { chunks } from '../_local/database/schema';

export async function learnVectorstore(filePath: string, namespace: string) {
  const rl = readline.createInterface({
    input: fs.createReadStream(filePath),
    crlfDelay: Infinity,
  });

  const batchSize = 10;
  let buffer: { namespace: string; content: string; embedding: string; created_at: string }[] = [];

  for await (const line of rl) {
    const trimmed = line.trim();
    if (!trimmed) continue;

    const { embedding } = await embed(trimmed);
    buffer.push({
      namespace,
      content: trimmed,
      embedding: JSON.stringify(embedding),
      created_at: new Date().toISOString(),
    });

    if (buffer.length >= batchSize) {
      await db.insert(chunks).values(buffer);
      buffer = [];
    }
  }

  if (buffer.length) {
    await db.insert(chunks).values(buffer);
  }

  return { status: 'success', message: 'Vectorstore learning complete.' };
}
