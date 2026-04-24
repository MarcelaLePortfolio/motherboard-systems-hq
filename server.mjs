$(sed '1,420!d' server.mjs)

    let waitingOn = null;

    try {
      const db = globalThis.__DB_POOL;
      if (db) {
        const r2 = await db.query(
          `SELECT status, claimed_by FROM tasks ORDER BY updated_at DESC LIMIT 1`
        );
        if (r2.rows && r2.rows.length > 0) {
          const row2 = r2.rows[0];
          if (row2.status === "queued") {
            waitingOn = "task execution";
          } else if (row2.status === "in_progress") {
            waitingOn = "agent completion";
          } else if (row2.status === "failed") {
            waitingOn = "error resolution";
          } else if (row2.status === "completed") {
            waitingOn = "new task";
          }
        }
      }
    } catch (e) {
      console.warn("[PHASE493] waiting_on probe failed", e?.message || e);
    }

$(sed '421,490!d' server.mjs | sed 's/Context: .*/Context: ${runSummary || "No recent run context."} Waiting on: ${waitingOn || "unknown"}\`,/')

