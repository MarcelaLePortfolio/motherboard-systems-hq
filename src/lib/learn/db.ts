import crypto from 'crypto';
import fs from 'fs';
import path from 'path';
import Database from 'better-sqlite3';

export type DocumentRow = {
  id?: number;
  namespace: string;
  source_path: string;
  mime_type: string;
  bytes: number;
  hash: string;
  created_at?: string;
};

export type ChunkRow = {
  id?: number;
  document_id: number;
  namespace: string;
  ord: number;
  text: string;
};

export type EmbeddingRow = {
  id?: number;
  chunk_id: number;
  model: string;
  vector: number[];
};

export class LearnDB {
  private dbPath: string;
  private db!: Database.Database;

  constructor(dbPath: string) {
    this.dbPath = dbPath;
    const dir = path.dirname(dbPath);
    if (!fs.existsSync(dir)) fs.mkdirSync(dir, { recursive: true });
  }

  init() {
    this.db = new Database(this.dbPath);
    this.db.pragma('journal_mode = WAL');
    this.db.exec(`
      CREATE TABLE IF NOT EXISTS documents (
        id INTEGER PRIMARY KEY,
        namespace TEXT NOT NULL,
        source_path TEXT NOT NULL,
        mime_type TEXT NOT NULL,
        bytes INTEGER NOT NULL,
        hash TEXT NOT NULL,
        created_at TEXT NOT NULL DEFAULT (datetime('now'))
      );

      CREATE UNIQUE INDEX IF NOT EXISTS idx_documents_unique
        ON documents(namespace, source_path, hash);

      CREATE TABLE IF NOT EXISTS chunks (
        id INTEGER PRIMARY KEY,
        document_id INTEGER NOT NULL,
        namespace TEXT NOT NULL,
        ord INTEGER NOT NULL,
        text TEXT NOT NULL,
        FOREIGN KEY(document_id) REFERENCES documents(id) ON DELETE CASCADE
      );

      CREATE INDEX IF NOT EXISTS idx_chunks_doc ON chunks(document_id);
      CREATE INDEX IF NOT EXISTS idx_chunks_ns ON chunks(namespace);

      CREATE TABLE IF NOT EXISTS embeddings (
        id INTEGER PRIMARY KEY,
        chunk_id INTEGER NOT NULL,
        model TEXT NOT NULL,
        vector BLOB NOT NULL,
        FOREIGN KEY(chunk_id) REFERENCES chunks(id) ON DELETE CASCADE
      );

      CREATE UNIQUE INDEX IF NOT EXISTS idx_embeddings_unique
        ON embeddings(chunk_id, model);
    `);
  }

  hashContent(txt: string): string {
    return crypto.createHash('sha256').update(txt, 'utf8').digest('hex');
  }

  upsertDocument(doc: DocumentRow): number {
    const insert = this.db.prepare(`
      INSERT OR IGNORE INTO documents(namespace, source_path, mime_type, bytes, hash)
      VALUES (@namespace, @source_path, @mime_type, @bytes, @hash)
    `);
    insert.run(doc);
    const row = this.db.prepare(
      `SELECT id FROM documents WHERE namespace = ? AND source_path = ? AND hash = ?`
    ).get(doc.namespace, doc.source_path, doc.hash) as { id: number } | undefined;
    if (!row) throw new Error('Failed to upsert document row');
    return row.id;
  }

  insertChunk(ch: ChunkRow): number {
    const stmt = this.db.prepare(`
      INSERT INTO chunks(document_id, namespace, ord, text)
      VALUES (@document_id, @namespace, @ord, @text)
    `);
    const info = stmt.run(ch);
    return Number(info.lastInsertRowid);
  }

  getChunkText(id: number): string | null {
    const row = this.db.prepare(`SELECT text FROM chunks WHERE id = ?`).get(id) as { text: string } | undefined;
    return row ? row.text : null;
  }

  insertEmbedding(e: EmbeddingRow) {
    const buf = Buffer.from(Float32Array.from(e.vector).buffer);
    const stmt = this.db.prepare(`
      INSERT OR REPLACE INTO embeddings(chunk_id, model, vector)
      VALUES (@chunk_id, @model, @vector)
    `);
    stmt.run({ chunk_id: e.chunk_id, model: e.model, vector: buf });
  }

  search(namespace: string, model: string, queryVec: number[], limit = 8) {
    const rows = this.db.prepare(
      `SELECT c.id, c.text
       FROM chunks c
       WHERE c.namespace = ?
       ORDER BY c.id DESC
       LIMIT ?`
    ).all(namespace, limit) as { id: number; text: string }[];
    return rows;
  }
}
