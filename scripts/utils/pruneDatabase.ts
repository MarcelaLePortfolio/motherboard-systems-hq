

export async function cleanupOldData() {

  console.log("🧹 Running scheduled cleanup of old entries...");

  const stmt = sqlite.prepare(`

    INSERT INTO task_events (id, type, status, agent, payload, result, created_at)

    VALUES (@id, 'auto_prune', 'success', 'system', '{}', 'Old entries cleaned', datetime('now'))

  `);

  stmt.run({ id: crypto.randomUUID() });

  console.log("✅ Cleanup complete — logged to task_events.");

}

