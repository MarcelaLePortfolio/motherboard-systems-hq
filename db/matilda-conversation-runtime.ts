import Database from "better-sqlite3";

const sqlite = new Database("db/main.db");

export interface MatildaConversation {
  conversation_id: string;
  project_id: string;
  status: string;
  created_at: string;
  updated_at: string;
  last_active_at: string;
}

export interface MatildaConversationTurn {
  turn_id: string;
  project_id: string;
  conversation_id: string;
  user_message: string;
  assistant_reply: string;
  interpretation_entry_id: string;
  created_at: string;
}

export interface CreateMatildaConversationTurnInput {
  project_id: string;
  conversation_id?: string | null;
  user_message: string;
  assistant_reply: string;
  interpretation_entry_id: string;
}

function requireText(value: unknown, field: string): string {
  if (typeof value !== "string" || !value.trim()) {
    throw new Error(`Missing required Matilda conversation field: ${field}`);
  }

  return value.trim();
}

function defaultConversationId(projectId: string): string {
  return `matilda-conversation-${projectId}`;
}

function ensureMatildaConversationTables() {
  sqlite.exec(`
    CREATE TABLE IF NOT EXISTS matilda_conversations (
      conversation_id TEXT PRIMARY KEY,
      project_id TEXT NOT NULL,
      status TEXT NOT NULL DEFAULT 'active',
      created_at TEXT NOT NULL,
      updated_at TEXT NOT NULL,
      last_active_at TEXT NOT NULL
    );

    CREATE UNIQUE INDEX IF NOT EXISTS
      idx_matilda_conversations_one_active_per_project
    ON matilda_conversations (project_id)
    WHERE status = 'active';

    CREATE TABLE IF NOT EXISTS matilda_conversation_turns (
      turn_id TEXT PRIMARY KEY,
      project_id TEXT NOT NULL,
      conversation_id TEXT,
      user_message TEXT NOT NULL,
      assistant_reply TEXT NOT NULL,
      interpretation_entry_id TEXT NOT NULL,
      created_at TEXT NOT NULL
    );
  `);

  const columns = sqlite
    .prepare("PRAGMA table_info(matilda_conversation_turns)")
    .all() as Array<{ name: string }>;

  if (!columns.some((column) => column.name === "conversation_id")) {
    sqlite.exec(`
      ALTER TABLE matilda_conversation_turns
      ADD COLUMN conversation_id TEXT;
    `);
  }

  const projects = sqlite
    .prepare(`
      SELECT DISTINCT project_id
      FROM matilda_conversation_turns
      WHERE project_id IS NOT NULL
        AND TRIM(project_id) <> ''
    `)
    .all() as Array<{ project_id: string }>;

  const timestamp = new Date().toISOString();

  const insertConversation = sqlite.prepare(`
    INSERT OR IGNORE INTO matilda_conversations (
      conversation_id,
      project_id,
      status,
      created_at,
      updated_at,
      last_active_at
    ) VALUES (?, ?, 'active', ?, ?, ?)
  `);

  const backfillTurns = sqlite.prepare(`
    UPDATE matilda_conversation_turns
    SET conversation_id = ?
    WHERE project_id = ?
      AND (
        conversation_id IS NULL
        OR TRIM(conversation_id) = ''
      )
  `);

  const migrate = sqlite.transaction(() => {
    for (const project of projects) {
      const conversationId = defaultConversationId(project.project_id);

      insertConversation.run(
        conversationId,
        project.project_id,
        timestamp,
        timestamp,
        timestamp
      );

      backfillTurns.run(conversationId, project.project_id);
    }
  });

  migrate();

  sqlite.exec(`
    CREATE INDEX IF NOT EXISTS
      idx_matilda_conversation_turns_conversation_created
    ON matilda_conversation_turns (conversation_id, created_at);

    CREATE INDEX IF NOT EXISTS
      idx_matilda_conversation_turns_project_created
    ON matilda_conversation_turns (project_id, created_at);
  `);
}

export function getOrCreateActiveMatildaConversation(
  projectId: string
): MatildaConversation {
  ensureMatildaConversationTables();

  const project_id = requireText(projectId, "project_id");

  const existing = sqlite
    .prepare(`
      SELECT
        conversation_id,
        project_id,
        status,
        created_at,
        updated_at,
        last_active_at
      FROM matilda_conversations
      WHERE project_id = ?
        AND status = 'active'
      LIMIT 1
    `)
    .get(project_id) as MatildaConversation | undefined;

  if (existing) {
    return existing;
  }

  const timestamp = new Date().toISOString();
  const conversation: MatildaConversation = {
    conversation_id: defaultConversationId(project_id),
    project_id,
    status: "active",
    created_at: timestamp,
    updated_at: timestamp,
    last_active_at: timestamp,
  };

  sqlite.prepare(`
    INSERT INTO matilda_conversations (
      conversation_id,
      project_id,
      status,
      created_at,
      updated_at,
      last_active_at
    ) VALUES (
      @conversation_id,
      @project_id,
      @status,
      @created_at,
      @updated_at,
      @last_active_at
    )
  `).run(conversation);

  return conversation;
}

export function createMatildaConversationTurn(
  input: CreateMatildaConversationTurnInput
): MatildaConversationTurn {
  ensureMatildaConversationTables();

  const project_id = requireText(input.project_id, "project_id");
  const activeConversation = getOrCreateActiveMatildaConversation(project_id);
  const conversation_id = input.conversation_id
    ? requireText(input.conversation_id, "conversation_id")
    : activeConversation.conversation_id;

  if (conversation_id !== activeConversation.conversation_id) {
    throw new Error(
      "Matilda conversation does not match the active project conversation."
    );
  }

  const record: MatildaConversationTurn = {
    turn_id: `matilda-turn-${Date.now()}-${Math.random()
      .toString(36)
      .slice(2, 8)}`,
    project_id,
    conversation_id,
    user_message: requireText(input.user_message, "user_message"),
    assistant_reply: requireText(input.assistant_reply, "assistant_reply"),
    interpretation_entry_id: requireText(
      input.interpretation_entry_id,
      "interpretation_entry_id"
    ),
    created_at: new Date().toISOString(),
  };

  const transaction = sqlite.transaction(() => {
    sqlite.prepare(`
      INSERT INTO matilda_conversation_turns (
        turn_id,
        project_id,
        conversation_id,
        user_message,
        assistant_reply,
        interpretation_entry_id,
        created_at
      ) VALUES (
        @turn_id,
        @project_id,
        @conversation_id,
        @user_message,
        @assistant_reply,
        @interpretation_entry_id,
        @created_at
      )
    `).run(record);

    sqlite.prepare(`
      UPDATE matilda_conversations
      SET
        updated_at = ?,
        last_active_at = ?
      WHERE conversation_id = ?
    `).run(record.created_at, record.created_at, conversation_id);
  });

  transaction();

  return record;
}

export function listMatildaConversationTurns(
  projectId: string,
  limit = 20,
  conversationId?: string | null
): MatildaConversationTurn[] {
  ensureMatildaConversationTables();

  const project_id = requireText(projectId, "project_id");
  const activeConversation = getOrCreateActiveMatildaConversation(project_id);
  const conversation_id = conversationId
    ? requireText(conversationId, "conversation_id")
    : activeConversation.conversation_id;

  if (conversation_id !== activeConversation.conversation_id) {
    throw new Error(
      "Matilda conversation does not match the active project conversation."
    );
  }

  const boundedLimit = Math.max(1, Math.min(Number(limit) || 20, 100));

  return sqlite.prepare(`
    SELECT
      turn_id,
      project_id,
      conversation_id,
      user_message,
      assistant_reply,
      interpretation_entry_id,
      created_at
    FROM (
      SELECT
        turn_id,
        project_id,
        conversation_id,
        user_message,
        assistant_reply,
        interpretation_entry_id,
        created_at
      FROM matilda_conversation_turns
      WHERE project_id = ?
        AND conversation_id = ?
      ORDER BY created_at DESC
      LIMIT ?
    )
    ORDER BY created_at ASC
  `).all(
    project_id,
    conversation_id,
    boundedLimit
  ) as MatildaConversationTurn[];
}
