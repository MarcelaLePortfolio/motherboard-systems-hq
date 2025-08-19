import fs from 'fs';
import readline from 'readline';
import { chunkText } from '../../src/lib/learn/chunker';

const CHUNK_SIZE = 500;
const CHUNK_OVERLAP = 50;
const INPUT_FILE = 'BASTION-9_ACTIVESESSION_SUMMONCARD.TXT';
const OUTPUT_FILE = 'chunks_output.txt';

(async () => {
  const rl = readline.createInterface({
    input: fs.createReadStream(INPUT_FILE),
    crlfDelay: Infinity,
  });

  let currentChunk = '';
  let overlapBuffer = '';
  let chunkCount = 0;
  const chunks: string[] = [];

  // Reset output file
  fs.writeFileSync(OUTPUT_FILE, '');

  for await (const line of rl) {
    const lineWithNewline = line + '\n';

    if (currentChunk.length + lineWithNewline.length > CHUNK_SIZE) {
      const fullChunk = currentChunk.trim();
      if (fullChunk) {
        chunkCount++;
        if (chunkCount === 1) {
          console.log('📦 First chunk preview:\n', fullChunk.slice(0, 200));
        }
        chunks.push(fullChunk);

        // ✅ Append to file
        fs.appendFileSync(OUTPUT_FILE, `\n\n--- Chunk #${chunkCount} ---\n${fullChunk}`);
      }

      // Start next chunk with overlap
      currentChunk = overlapBuffer + lineWithNewline;
    } else {
      currentChunk += lineWithNewline;
    }

    // Update overlap buffer
    if (currentChunk.length > CHUNK_OVERLAP) {
      overlapBuffer = currentChunk.slice(-CHUNK_OVERLAP);
    } else {
      overlapBuffer = currentChunk;
    }
  }

  // Final flush
  const lastChunk = currentChunk.trim();
  if (lastChunk) {
    chunkCount++;
    chunks.push(lastChunk);
    fs.appendFileSync(OUTPUT_FILE, `\n\n--- Chunk #${chunkCount} ---\n${lastChunk}`);
  }

  console.log('✅ Streamed chunking complete');
  console.log(`<0001f9e9> Total chunks: ${chunkCount}`);
})();
