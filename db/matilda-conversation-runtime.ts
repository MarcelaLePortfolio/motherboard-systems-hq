import Database from "better-sqlite3";

const sqlite = new Database("db/main.db");

export interface MatildaConversationTurn {
  turn_id: string;
  project_id: string;
  user_message: string;
  assistant_reply: string;
  interpretation_entry_id: string;
  created_at: string;
}

export interface CreateMatildaConversationTurnInput {
  project_id: string;
  user_message: string;
  assistant_reply: string;
  interpretation_entry_id: string;
}

function ensureMatildaConversationTable() {
  sqlite.exec(`
    CREATE TABLE IF NOT EXISTS matilda_conversation_turns (
      turn_id TEXT PRIMARY KEY,
      project_id TEXT NOT NULL,
      user_message TEXT NOT NULL,
      assistant_reply TEXT NOT NULL,
      interpretation_entry_id TEXT NOT NULL,
      created_at TEXT NOT NULL
    );

    CREATE INDEX IF NOT EXISTS idx_matilda_conversation_turns_project_created
    ON matilda_conversation_turns (project_id, created_at);
  `);
}

function requireText(value: unknown, field: string): string {
  if (typeof value !== "string" || !value.trim()) {
    throw new Error(`Missing required Matilda conversation field: ${field}`);
  }

  return value.trim();
}

export function createMatildaConversationTurn(
  input: CreateMatildaConversationTurnInput
): MatildaConversationTurn {
  ensureMatildaConversationTable();

  const record: MatildaConversationTurn = {
    turn_id: `matilda-turn-${Date.now()}-${Math.random()
      .toString(36)
      .slice(2, 8)}`,
    project_id: requireText(input.project_id, "project_id"),
    user_message: requireText(input.user_message, "user_message"),
    assistant_reply: requireText(input.assistant_reply, "assistant_reply"),
    interpretation_entry_id: requireText(
      input.interpretation_entry_id,
      "interpretation_entry_id"
    ),
    created_at: new Date().toISOString(),
  };

  sqlite.prepare(`
    INSERT INTO matilda_conversation_turns (
      turn_id,
      project_id,
      user_message,
      assistant_reply,
      interpretation_entry_id,
      created_at
    ) VALUES (
      @turn_id,
      @project_id,
      @user_message,
      @assistant_reply,
      @interpretation_entry_id,
      @created_at
    )
  `).run(record);

  return record;
}

export function listMatildaConversationTurns(
  projectId: string,
  limit = 20
): MatildaConversationTurn[] {
  ensureMatildaConversationTable();

  const project_id = requireText(projectId, "project_id");
  const boundedLimit = Math.max(1, Math.min(Number(limit) || 20, 100));

  return sqlite.prepare(`
    SELECT
      turn_id,
      project_id,
      user_message,
      assistant_reply,
      interpretation_entry_id,
      created_at
    FROM (
      SELECT
        turn_id,
        project_id,
        user_message,
        assistant_reply,
        interpretation_entry_id,
        created_at
      FROM matilda_conversation_turns
      WHERE project_id = ?
      ORDER BY created_at DESC
      LIMIT ?
    )
    ORDER BY created_at ASC
  `).all(project_id, boundedLimit) as MatildaConversationTurn[];
}
