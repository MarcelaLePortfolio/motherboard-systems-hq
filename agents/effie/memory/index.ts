/**
 * 🧠 Memory System Scaffolding for Effie
 *
 * This module lays out 3 tiers of memory:
 * 1. Lightweight local cache (for recent task recall)
 * 2. Embedding-based semantic memory (for fuzzy recall)
 * 3. Persistent cloud memory (Supabase/PostgreSQL)
 *
 * Swap in any storage backend as needed—file, vector DB, or SQL.
 */

import fs from "fs";
import path from "path";
import { createClient } from "@supabase/supabase-js"; // Only if using Supabase

const LOCAL_DB_PATH = path.join(process.cwd(), "memory/agent_memory.db");

// ─────────────────────────────────────────────────────────────
// 1️⃣ Lightweight Local Cache (e.g. for task summaries, file ops)
// ─────────────────────────────────────────────────────────────
export function saveLocalMemory(entry: string) {
  const timestamp = new Date().toISOString();
  fs.appendFileSync(LOCAL_DB_PATH, `[${timestamp}] ${entry}\n`);
}

export function getRecentLocalMemory(limit = 10): string[] {
  if (!fs.existsSync(LOCAL_DB_PATH)) return [];
  const lines = fs.readFileSync(LOCAL_DB_PATH, "utf-8").split("\n").filter(Boolean);
  return lines.slice(-limit);
}

// ─────────────────────────────────────────────────────────────
// 2️⃣ Semantic Memory (Embeddings + Vector Search)
// Requires: local embedding model or API, vector db like Chroma, LanceDB, etc.
// ─────────────────────────────────────────────────────────────
export async function storeSemanticMemory(text: string) {
  // ✨ Replace with actual embedding + vector insert
  // const embedding = await embed(text);
  // await vectorDB.insert({ embedding, metadata: { text, timestamp: Date.now() } });
}

export async function searchSemanticMemory(query: string): Promise<string[]> {
  // ✨ Replace with actual embedding + vector search
  // const results = await vectorDB.query(embed(query));
  // return results.map(r => r.metadata.text);
  return [];
}

// ─────────────────────────────────────────────────────────────
// 3️⃣ Persistent Cloud Memory (Supabase / SQL)
// Requires: Supabase project + credentials
// ─────────────────────────────────────────────────────────────
const supabaseUrl = process.env.SUPABASE_URL || "";
const supabaseKey = process.env.SUPABASE_SERVICE_ROLE_KEY || "";
const supabase = createClient(supabaseUrl, supabaseKey);

export async function saveToSupabaseMemory(agent: string, content: string) {
  const { error } = await supabase.from("agent_memory").insert({
    agent,
    content,
    timestamp: new Date().toISOString(),
  });
  if (error) console.error("❌ Supabase memory save failed:", error.message);
}

export async function fetchFromSupabaseMemory(agent: string, limit = 10): Promise<string[]> {
  const { data, error } = await supabase
    .from("agent_memory")
    .select("content")
    .eq("agent", agent)
    .order("timestamp", { ascending: false })
    .limit(limit);

  if (error) {
    console.error("❌ Supabase memory fetch failed:", error.message);
    return [];
  }

  return data.map((row: any) => row.content);
}
