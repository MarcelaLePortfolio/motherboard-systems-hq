import Database from "better-sqlite3";

import type { MatildaProjectContextRetrievalResult } from "../server/matilda-project-context-retrieval";

const sqlite = new Database("db/main.db");

export interface MatildaConversation {
  conversation_id: string;
  project_id: string;
  status: string;
  created_at: string;
  updated_at: string;
  last_active_at: string;
}

export interface MatildaActiveConversationContext {
  project_id: string;
  conversation_id: string;
  source: string;
  action: string;
  updated_at: string;
}

export interface MatildaConversationSummary extends MatildaConversation {
  title: string;
  turn_count: number;
  is_active: boolean;
}

export interface MatildaProjectContextEvidenceTrace {
  trace_id: string;
  project_id: string;
  conversation_id: string;
  interpretation_entry_id: string;
  retrieval: MatildaProjectContextRetrievalResult;
  artifact_classification_status: "not_performed";
  conflict_observation_status: "not_evaluated";
  authority_resolution_status: "not_performed";
  created_at: string;
}

export interface MatildaConversationTurn {
  turn_id: string;
  project_id: string;
  conversation_id: string;
  user_message: string;
  assistant_reply: string;
  interpretation_entry_id: string;
  project_context_evidence_trace: MatildaProjectContextEvidenceTrace | null;
  created_at: string;
}

export interface CreateMatildaConversationTurnInput {
  project_id: string;
  conversation_id?: string | null;
  user_message: string;
  assistant_reply: string;
  interpretation_entry_id: string;
  project_context_retrieval: MatildaProjectContextRetrievalResult;
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

    DROP INDEX IF EXISTS
      idx_matilda_conversations_one_active_per_project;

    CREATE INDEX IF NOT EXISTS
      idx_matilda_conversations_project_activity
    ON matilda_conversations (project_id, last_active_at DESC);

    CREATE TABLE IF NOT EXISTS matilda_active_conversation_context (
      project_id TEXT PRIMARY KEY,
      conversation_id TEXT NOT NULL,
      source TEXT NOT NULL DEFAULT 'system',
      action TEXT NOT NULL DEFAULT 'seed',
      updated_at TEXT NOT NULL
    );

    CREATE TABLE IF NOT EXISTS matilda_conversation_turns (
      turn_id TEXT PRIMARY KEY,
      project_id TEXT NOT NULL,
      conversation_id TEXT,
      user_message TEXT NOT NULL,
      assistant_reply TEXT NOT NULL,
      interpretation_entry_id TEXT NOT NULL,
      project_context_evidence_trace_json TEXT,
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

  if (
    !columns.some(
      (column) => column.name === "project_context_evidence_trace_json"
    )
  ) {
    sqlite.exec(`
      ALTER TABLE matilda_conversation_turns
      ADD COLUMN project_context_evidence_trace_json TEXT;
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

  const seedActiveConversation = sqlite.prepare(`
    INSERT OR IGNORE INTO matilda_active_conversation_context (
      project_id,
      conversation_id,
      source,
      action,
      updated_at
    ) VALUES (?, ?, 'migration', 'seed_active_conversation', ?)
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
      seedActiveConversation.run(
        project.project_id,
        conversationId,
        timestamp
      );
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

function getConversationForProject(
  projectId: string,
  conversationId: string
): MatildaConversation | null {
  ensureMatildaConversationTables();

  const project_id = requireText(projectId, "project_id");
  const conversation_id = requireText(
    conversationId,
    "conversation_id"
  );

  return (
    sqlite
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
          AND conversation_id = ?
        LIMIT 1
      `)
      .get(project_id, conversation_id) as
      | MatildaConversation
      | undefined
  ) ?? null;
}

function requireConversationForProject(
  projectId: string,
  conversationId: string
): MatildaConversation {
  const project_id = requireText(projectId, "project_id");
  const conversation_id = requireText(
    conversationId,
    "conversation_id"
  );
  const conversation = getConversationForProject(
    project_id,
    conversation_id
  );

  if (!conversation || conversation.status !== "active") {
    throw new Error(
      "Matilda conversation is unavailable for the requested project."
    );
  }

  return conversation;
}

export function getOrCreateActiveMatildaConversation(
  projectId: string
): MatildaConversation {
  ensureMatildaConversationTables();

  const project_id = requireText(projectId, "project_id");

  const selected = sqlite
    .prepare(`
      SELECT
        c.conversation_id,
        c.project_id,
        c.status,
        c.created_at,
        c.updated_at,
        c.last_active_at
      FROM matilda_active_conversation_context AS context
      JOIN matilda_conversations AS c
        ON c.conversation_id = context.conversation_id
       AND c.project_id = context.project_id
      WHERE context.project_id = ?
      LIMIT 1
    `)
    .get(project_id) as MatildaConversation | undefined;

  if (selected) {
    return selected;
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

  const transaction = sqlite.transaction(() => {
    sqlite.prepare(`
      INSERT OR IGNORE INTO matilda_conversations (
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

    sqlite.prepare(`
      INSERT OR REPLACE INTO matilda_active_conversation_context (
        project_id,
        conversation_id,
        source,
        action,
        updated_at
      ) VALUES (?, ?, 'system', 'initialize_active_conversation', ?)
    `).run(project_id, conversation.conversation_id, timestamp);
  });

  transaction();

  return getConversationForProject(
    project_id,
    conversation.conversation_id
  ) as MatildaConversation;
}

export function requireActiveMatildaConversation(
  projectId: string,
  conversationId: string
): MatildaConversation {
  const project_id = requireText(projectId, "project_id");
  const conversation = requireConversationForProject(
    project_id,
    conversationId
  );
  const active = getOrCreateActiveMatildaConversation(project_id);

  if (active.conversation_id !== conversation.conversation_id) {
    throw new Error(
      "Matilda conversation does not match the active project conversation."
    );
  }

  return active;
}

export function listMatildaConversations(
  projectId: string
): MatildaConversationSummary[] {
  ensureMatildaConversationTables();

  const project_id = requireText(projectId, "project_id");
  const activeConversation =
    getOrCreateActiveMatildaConversation(project_id);

  return sqlite
    .prepare(`
      SELECT
        c.conversation_id,
        c.project_id,
        c.status,
        c.created_at,
        c.updated_at,
        c.last_active_at,
        COALESCE(
          (
            SELECT NULLIF(TRIM(t.user_message), '')
            FROM matilda_conversation_turns AS t
            WHERE t.project_id = c.project_id
              AND t.conversation_id = c.conversation_id
            ORDER BY t.created_at ASC
            LIMIT 1
          ),
          'New conversation'
        ) AS title,
        (
          SELECT COUNT(*)
          FROM matilda_conversation_turns AS t
          WHERE t.project_id = c.project_id
            AND t.conversation_id = c.conversation_id
        ) AS turn_count,
        CASE
          WHEN c.conversation_id = ? THEN 1
          ELSE 0
        END AS is_active
      FROM matilda_conversations AS c
      WHERE c.project_id = ?
        AND c.status = 'active'
      ORDER BY
        is_active DESC,
        c.last_active_at DESC,
        c.created_at DESC
    `)
    .all(
      activeConversation.conversation_id,
      project_id
    ) as MatildaConversationSummary[];
}

export function createMatildaConversation(
  projectId: string
): MatildaConversation {
  ensureMatildaConversationTables();

  const project_id = requireText(projectId, "project_id");
  const timestamp = new Date().toISOString();
  const conversation: MatildaConversation = {
    conversation_id: `matilda-conversation-${project_id}-${Date.now()}-${Math.random()
      .toString(36)
      .slice(2, 8)}`,
    project_id,
    status: "active",
    created_at: timestamp,
    updated_at: timestamp,
    last_active_at: timestamp,
  };

  const transaction = sqlite.transaction(() => {
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

    sqlite.prepare(`
      INSERT OR REPLACE INTO matilda_active_conversation_context (
        project_id,
        conversation_id,
        source,
        action,
        updated_at
      ) VALUES (?, ?, 'dashboard', 'create_conversation', ?)
    `).run(project_id, conversation.conversation_id, timestamp);
  });

  transaction();

  return conversation;
}

export function setActiveMatildaConversation(
  projectId: string,
  conversationId: string
): MatildaConversation {
  ensureMatildaConversationTables();

  const project_id = requireText(projectId, "project_id");
  const conversation_id = requireText(
    conversationId,
    "conversation_id"
  );
  const conversation = getConversationForProject(
    project_id,
    conversation_id
  );

  if (!conversation || conversation.status !== "active") {
    throw new Error(
      "Matilda conversation is unavailable for the requested project."
    );
  }

  const timestamp = new Date().toISOString();

  const transaction = sqlite.transaction(() => {
    sqlite.prepare(`
      INSERT OR REPLACE INTO matilda_active_conversation_context (
        project_id,
        conversation_id,
        source,
        action,
        updated_at
      ) VALUES (?, ?, 'dashboard', 'switch_conversation', ?)
    `).run(project_id, conversation_id, timestamp);

    sqlite.prepare(`
      UPDATE matilda_conversations
      SET last_active_at = ?
      WHERE project_id = ?
        AND conversation_id = ?
    `).run(timestamp, project_id, conversation_id);
  });

  transaction();

  return getConversationForProject(
    project_id,
    conversation_id
  ) as MatildaConversation;
}

function parseProjectContextEvidenceTrace(
  value: string | null
): MatildaProjectContextEvidenceTrace | null {
  if (!value) {
    return null;
  }

  try {
    const parsed = JSON.parse(value) as unknown;

    if (
      typeof parsed !== "object" ||
      parsed === null ||
      !("trace_id" in parsed) ||
      typeof parsed.trace_id !== "string"
    ) {
      return null;
    }

    return parsed as MatildaProjectContextEvidenceTrace;
  } catch {
    return null;
  }
}

export function createMatildaConversationTurn(
  input: CreateMatildaConversationTurnInput
): MatildaConversationTurn {
  ensureMatildaConversationTables();

  const project_id = requireText(input.project_id, "project_id");
  const explicitConversationId = input.conversation_id
    ? requireText(input.conversation_id, "conversation_id")
    : null;
  const activeConversation = getOrCreateActiveMatildaConversation(project_id);
  const conversation_id =
    explicitConversationId ?? activeConversation.conversation_id;

  if (explicitConversationId) {
    requireConversationForProject(
      project_id,
      explicitConversationId
    );
  } else {
    requireActiveMatildaConversation(
      project_id,
      conversation_id
    );
  }

  if (input.project_context_retrieval.projectId.trim() !== project_id) {
    throw new Error(
      "Matilda project-context retrieval does not match the turn project."
    );
  }

  const timestamp = new Date().toISOString();
  const interpretation_entry_id = requireText(
    input.interpretation_entry_id,
    "interpretation_entry_id"
  );

  const projectContextEvidenceTrace: MatildaProjectContextEvidenceTrace = {
    trace_id: `matilda-context-trace-${Date.now()}-${Math.random()
      .toString(36)
      .slice(2, 8)}`,
    project_id,
    conversation_id,
    interpretation_entry_id,
    retrieval: input.project_context_retrieval,
    artifact_classification_status: "not_performed",
    conflict_observation_status: "not_evaluated",
    authority_resolution_status: "not_performed",
    created_at: timestamp,
  };

  const record: MatildaConversationTurn = {
    turn_id: `matilda-turn-${Date.now()}-${Math.random()
      .toString(36)
      .slice(2, 8)}`,
    project_id,
    conversation_id,
    user_message: requireText(input.user_message, "user_message"),
    assistant_reply: requireText(input.assistant_reply, "assistant_reply"),
    interpretation_entry_id,
    project_context_evidence_trace: projectContextEvidenceTrace,
    created_at: timestamp,
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
        project_context_evidence_trace_json,
        created_at
      ) VALUES (
        @turn_id,
        @project_id,
        @conversation_id,
        @user_message,
        @assistant_reply,
        @interpretation_entry_id,
        @project_context_evidence_trace_json,
        @created_at
      )
    `).run({
      turn_id: record.turn_id,
      project_id: record.project_id,
      conversation_id: record.conversation_id,
      user_message: record.user_message,
      assistant_reply: record.assistant_reply,
      interpretation_entry_id: record.interpretation_entry_id,
      project_context_evidence_trace_json: JSON.stringify(
        projectContextEvidenceTrace
      ),
      created_at: record.created_at,
    });

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
  const explicitConversationId = conversationId
    ? requireText(conversationId, "conversation_id")
    : null;
  const activeConversation = getOrCreateActiveMatildaConversation(project_id);
  const conversation_id =
    explicitConversationId ?? activeConversation.conversation_id;

  if (explicitConversationId) {
    requireConversationForProject(
      project_id,
      explicitConversationId
    );
  } else {
    requireActiveMatildaConversation(
      project_id,
      conversation_id
    );
  }

  const boundedLimit = Math.max(1, Math.min(Number(limit) || 20, 100));

  const rows = sqlite.prepare(`
    SELECT
      turn_id,
      project_id,
      conversation_id,
      user_message,
      assistant_reply,
      interpretation_entry_id,
      project_context_evidence_trace_json,
      created_at
    FROM (
      SELECT
        turn_id,
        project_id,
        conversation_id,
        user_message,
        assistant_reply,
        interpretation_entry_id,
        project_context_evidence_trace_json,
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
  ) as Array<{
    turn_id: string;
    project_id: string;
    conversation_id: string;
    user_message: string;
    assistant_reply: string;
    interpretation_entry_id: string;
    project_context_evidence_trace_json: string | null;
    created_at: string;
  }>;

  return rows.map((row) => ({
    turn_id: row.turn_id,
    project_id: row.project_id,
    conversation_id: row.conversation_id,
    user_message: row.user_message,
    assistant_reply: row.assistant_reply,
    interpretation_entry_id: row.interpretation_entry_id,
    project_context_evidence_trace: parseProjectContextEvidenceTrace(
      row.project_context_evidence_trace_json
    ),
    created_at: row.created_at,
  }));
}
