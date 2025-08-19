import fs from 'fs';
import path from 'path';
import { OllamaClient } from '../../../src/lib/ollamaClient';
import { LearnDB } from '../../../src/lib/learn/db';
import { chunkText } from '../../../src/lib/learn/chunker';

export type LearnInput = {
  targetPath: string;
  namespace?: string;
  embedModel?: string;
};

export type LearnResult = {
  ok: boolean;
  namespace: string;
  model: string;
  docs: number;
  chunks: number;
  embeddings: number;
  message?: string;
};

function isTextLike(filePath: string) {
  const exts = ['.md', '.txt', '.rtf', '.html', '.htm', '.json', '.ts', '.tsx', '.js', '.jsx', '.py', '.sh', '.yml', '.yaml', '.toml', '.sql', '.csv'];
  return exts.includes(path.extname(filePath).toLowerCase());
}

function readFileSafe(p: string) {
  try {
    const stat = fs.statSync(p);
    if (!stat.isFile()) return null;
    if (!isTextLike(p)) return null;
    return fs.readFileSync(p, 'utf8');
  } catch {
    return null;
  }
}

function collectFiles(root: string): string[] {
  const out: string[] = [];
  const stat = fs.statSync(root);
  if (stat.isFile()) {
    if (isTextLike(root)) out.push(root);
    return out;
  }
  const entries = fs.readdirSync(root);
  for (const e of entries) {
    const fp = path.join(root, e);
    try {
      const st = fs.statSync(fp);
      if (st.isDirectory()) out.push(...collectFiles(fp));
      else if (st.isFile() && isTextLike(fp)) out.push(fp);
    } catch {}
  }
  return out;
}

export async function handleLearn(input: LearnInput): Promise<LearnResult> {
  const cwd = process.cwd();
  const target = path.resolve(cwd, input.targetPath);
  if (!target.startsWith(cwd)) {
    return { ok: false, namespace: input.namespace || 'default', model: input.embedModel || 'nomic-embed-text', docs: 0, chunks: 0, embeddings: 0, message: 'Unsafe file path.' };
  }

  if (!fs.existsSync(target)) {
    return { ok: false, namespace: input.namespace || 'default', model: input.embedModel || 'nomic-embed-text', docs: 0, chunks: 0, embeddings: 0, message: 'Target path does not exist.' };
  }

  const files = collectFiles(target);
  if (files.length === 0) {
    return { ok: false, namespace: input.namespace || 'default', model: input.embedModel || 'nomic-embed-text', docs: 0, chunks: 0, embeddings: 0, message: 'No ingestible text files found.' };
  }

  const namespace = input.namespace || 'default';
  const model = input.embedModel || 'nomic-embed-text';

  const db = new LearnDB(path.join('memory', 'learn.db'));
  db.init();

  const ollama = new OllamaClient(process.env.OLLAMA_HOST || 'http://127.0.0.1:11434');

  let docCount = 0;
  let chunkCount = 0;
  let embedCount = 0;

  for (const fp of files) {
    const content = readFileSafe(fp);
    if (!content) continue;

    const relPath = path.relative(cwd, fp);
    const docId = db.upsertDocument({
      namespace,
      source_path: relPath,
      mime_type: 'text/plain',
      bytes: Buffer.byteLength(content, 'utf8'),
      hash: db.hashContent(content),
    });
    docCount++;

    const chunks = chunkText(content, { chunkSize: 1200, chunkOverlap: 120 });
    const insertedChunkIds: number[] = [];
    for (let i = 0; i < chunks.length; i++) {
      const ch = chunks[i];
      const chunkId = db.insertChunk({
        document_id: docId,
        namespace,
        ord: i,
        text: ch,
      });
      insertedChunkIds.push(chunkId);
    }
    chunkCount += insertedChunkIds.length;

    const batchSize = 32;
    for (let i = 0; i < insertedChunkIds.length; i += batchSize) {
      const ids = insertedChunkIds.slice(i, i + batchSize);
      const texts = ids.map(id => db.getChunkText(id) || '');
      const vectors = await ollama.embed({ model, input: texts });
      if (!vectors || vectors.length !== ids.length) {
        throw new Error('Embedding vector count mismatch.');
      }
      for (let j = 0; j < ids.length; j++) {
        db.insertEmbedding({
          chunk_id: ids[j],
          model,
          vector: vectors[j],
        });
        embedCount++;
      }
    }
  }

  return {
    ok: true,
    namespace,
    model,
    docs: docCount,
    chunks: chunkCount,
    embeddings: embedCount,
    message: `Ingested ${docCount} docs, ${chunkCount} chunks, ${embedCount} embeddings.`,
  };
}
