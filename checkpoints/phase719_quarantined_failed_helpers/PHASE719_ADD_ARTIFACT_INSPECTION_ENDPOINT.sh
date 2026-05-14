
#!/usr/bin/env bash

set -euo pipefail

echo "===== PHASE 719 ADD ARTIFACT INSPECTION ENDPOINT ====="

ROUTE_FILE="server/routes/api-tasks-postgres.mjs"

echo ""

echo "[1] Appending artifact inspection endpoint"

cat << 'CODE' >> "$ROUTE_FILE"

/**

 * Phase 719 — Artifact Inspection Endpoint (READ-ONLY)

 * GET /api/artifacts/:task_id

 */

app.get("/api/artifacts/:task_id", async (req, res) => {

  try {

    const task_id = req.params.task_id;

    const result = await pool.query(

      \`

      SELECT

        te.payload->>'artifact' AS artifact,

        te.payload->>'artifacts' AS artifacts,

        te.payload->>'outcome_preview' AS outcome_preview,

        te.payload->>'explanation_preview' AS explanation_preview,

        te.payload

      FROM task_events te

      WHERE te.task_id = $1

        AND te.kind = 'task.completed'

      ORDER BY te.id DESC

      LIMIT 1

      \`,

      [task_id]

    );

    if (!result.rows.length) {

      return res.status(404).json({

        ok: false,

        error: "artifact_not_found"

      });

    }

    const row = result.rows[0];

    res.json({

      ok: true,

      task_id,

      artifact: row.artifact,

      artifacts: row.artifacts,

      outcome_preview: row.outcome_preview,

      explanation_preview: row.explanation_preview

    });

  } catch (err) {

    console.error("[artifact-inspection] error:", err);

    res.status(500).json({ ok: false, error: "internal_error" });

  }

});

CODE

echo ""

echo "[2] Rebuild + restart"

docker compose build dashboard

docker compose up -d

echo ""

echo "[3] Verify endpoint exists (no task execution)"

curl -s http://localhost:3000/api/artifacts/test | head -c 300 || true

echo ""

echo "[4] Git commit"

git add server/routes/api-tasks-postgres.mjs

git commit -m "Phase 719: add read-only artifact inspection endpoint"

git push origin dev

echo ""

echo "===== ARTIFACT INSPECTION ENDPOINT DEPLOYED ====="

