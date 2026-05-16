import { createRequire } from "module";
const require = createRequire(import.meta.url);
require("../worker_retry_enforcer.js");
const { Pool } = require("pg");
import fs from "fs";
import path from "path";
import crypto from "crypto";
import { emitTaskEvent } from "../task_events_emit.mjs";
import { resolveExecutionPolicy } from "./execution_policy_resolver.mjs";
import { logExecutionPolicyRuntime } from "./execution_policy_runtime_logger.mjs";
import { executeTaskWithContract } from "./execute_task_with_contract.mjs";

let prepareArtifactSemanticMetadata = null;
try {
  ({ prepareArtifactSemanticMetadata } = require("../../worker/semantic/prepareArtifactSemanticMetadata.js"));
} catch {
  prepareArtifactSemanticMetadata = null;
}

const POSTGRES_URL =
  process.env.POSTGRES_URL ||
  process.env.DATABASE_URL ||
  "postgresql://postgres:postgres@postgres:5432/postgres";

const WORKER_DIR = path.resolve("/app/server/worker");
const OWNER = `worker-${crypto.randomUUID()}`;
const CLAIM_INTERVAL_MS = 5000;

function resolveSqlContracts() {
  let files = [];
  try {
    files = fs.readdirSync(WORKER_DIR);
  } catch (e) {
    throw new Error(`Worker directory not found: ${WORKER_DIR}`);
  }

  const phase32 = files.filter(f => f.startsWith("phase32_") && f.endsWith(".sql"));
  const phase27 = files.filter(f => f.startsWith("phase27_") && f.endsWith(".sql"));

  if (phase32.length > 0) {
    return {
      phase: "32",
      root: WORKER_DIR,
      files: phase32
    };
  }

  if (phase27.length > 0) {
    return {
      phase: "27",
      root: WORKER_DIR,
      files: phase27
    };
  }

  throw new Error("No SQL contracts found (expected phase32_* or phase27_* in /app/server/worker)");
}

function readSql(name) {
  return fs.readFileSync(path.join(WORKER_DIR, name), "utf8");
}

const SQL = resolveSqlContracts();
const CLAIM_SQL = readSql(`phase${SQL.phase}_claim_one.sql`);
const MARK_SUCCESS_SQL = readSql(`phase${SQL.phase}_mark_success.sql`);

console.log("[worker] resolved sql contracts:", {
  phase: SQL.phase,
  count: SQL.files.length
});

for (const f of SQL.files) {
  console.log("[worker] contract:", f);
}

async function claimOnce(pool) {
  const runId = `run_${crypto.randomUUID()}`;
  const result = await pool.query(CLAIM_SQL, [runId, OWNER]);

  const task = result.rows?.[0];

  if (!task) {
    return null;
  }

  console.log("[worker] claimed task", {
    id: task.id,
    task_id: task.task_id,
    status: task.status,
    run_id: task.run_id,
    claimed_by: task.claimed_by
  });

  return task;
}

async function completeSuccess(pool, task, executionResult = null) {
  if (!task?.task_id) return null;

  const result = await pool.query(MARK_SUCCESS_SQL, [
    task.task_id,
    task.run_id ?? null,
    OWNER
  ]);

  const completed = result.rows?.[0] || null;

  if (completed) {
    console.log("[worker] completed task", {
      id: completed.id,
      task_id: completed.task_id,
      status: completed.status,
      run_id: completed.run_id,
      claimed_by: completed.claimed_by,
      completed_at: completed.completed_at
    });

    function safeArtifactName(value = "") {

      return String(value)

        .replace(/[^a-zA-Z0-9._-]/g, "_")

        .replace(/_+/g, "_")

        .slice(0, 120);

    }

    function persistTaskArtifact({ task, completed, executionResult }) {

      const taskId = completed?.task_id ?? task?.task_id ?? `task_${Date.now()}`;

      const runId = completed?.run_id ?? task?.run_id ?? "run_unknown";

      const artifactDir = process.env.MB_ARTIFACT_DIR || "/app/data/artifacts";

      fs.mkdirSync(artifactDir, { recursive: true });

      const filename = `${safeArtifactName(taskId)}_${safeArtifactName(runId)}.md`;

      const artifactPath = path.join(artifactDir, filename);

      const outcome = executionResult?.communicationResult?.outcome?.content ?? "";

      const explanation = executionResult?.communicationResult?.explanation?.content ?? "";

      const systemTrace = executionResult?.communicationResult?.systemTrace?.content ?? {};

      const taskTitle = String(task?.title ?? task?.payload?.title ?? taskId);

      const taskStatus = String(completed?.status ?? "completed");

      const artifactSummary = outcome || `Execution completed for: ${taskTitle}`;

      const artifactDeliverable = outcome || "No deliverable summary was produced.";

      const artifactDetails = [

        `Task: ${taskTitle}`,

        `Status: ${taskStatus}`,

        explanation ? `Execution notes: ${explanation}` : null,

        systemTrace?.strategy_applied ? `Strategy applied: ${systemTrace.strategy_applied}` : null

      ].filter(Boolean).join("\n");

      const artifactRecommendations = [

        "Review the generated artifact preview in the operator console.",

        "Use the execution trace only when deeper debugging is needed."

      ].join("\n");

      const artifactNextSteps = [

        "Confirm the artifact content matches the operator intent.",

        "If richer deliverable content is needed, refine the worker artifact contract before expanding renderer behavior."

      ].join("\n");

      const semanticEnvelope = [

        "<!-- MB_SEMANTIC_ARTIFACT_V1",

        JSON.stringify({

          artifact_kind: "task_execution_summary",

          semantic_version: "1.0",

          task_summary: artifactSummary,

          execution_plan: artifactRecommendations,

          actionable_outputs: [artifactDeliverable],

          evidence_notes: artifactDetails

            .split("\n")

            .map((line) => line.trim())

            .filter(Boolean),

          operator_next_steps: artifactNextSteps,

          raw_markdown_fallback: true

        }, null, 2),

        "-->"

      ].join("\n");

      const content = [

        semanticEnvelope,

        "",

        "# Task Artifact",

        "",

        "## Task",

        taskTitle,

        "",

        "## Status",

        taskStatus,

        "",

        "## Summary",

        artifactSummary,

        "",

        "## Deliverable",

        artifactDeliverable,

        "",

        "## Details",

        artifactDetails || "No additional details were produced.",

        "",

        "## Recommendations",

        artifactRecommendations,

        "",

        "## Next Steps",

        artifactNextSteps,

        "",

        "## Outcome",

        outcome || "No outcome content was produced.",

        "",

        "## Explanation",

        explanation || "No explanation content was produced.",

        "",

        "## Execution Trace",

        "```json",

        JSON.stringify(systemTrace, null, 2),

        "```",

        ""

      ].join("\n");

      fs.writeFileSync(artifactPath, content, "utf8");

      const semanticMetadata =
        typeof prepareArtifactSemanticMetadata === "function"
          ? prepareArtifactSemanticMetadata(`${taskTitle}\n\n${artifactSummary}\n\n${artifactDeliverable}`)
          : null;

      return {

        type: "markdown",

        filename,

        path: artifactPath,

        size_bytes: Buffer.byteLength(content, "utf8"),

        created_at: new Date().toISOString(),

        source: "worker",

        ...(semanticMetadata ? semanticMetadata : {})

      };

    }

    const artifact = persistTaskArtifact({ task, completed, executionResult });

    await emitTaskEvent({
      pool,
      kind: "task.completed",
      task_id: completed.task_id,
      run_id: completed.run_id ?? task.run_id ?? null,
      actor: OWNER,
      payload: {
        status: completed.status,
        source: "worker",

        ...(semanticMetadata ? semanticMetadata : {}),
        claimed_by: completed.claimed_by,
        completed_at: completed.completed_at,
        communicationResult: executionResult?.communicationResult ?? null,
        outcome_preview: executionResult?.communicationResult?.outcome?.content ?? null,
        explanation_preview: executionResult?.communicationResult?.explanation?.content ?? null,
        artifact,
        artifacts: [artifact]
      }
    });
  }

  return completed;
}

async function main() {
  console.log("[worker] started with POSTGRES_URL:", POSTGRES_URL);
  console.log("[worker] running in phase:", SQL.phase);
  console.log("[worker] owner:", OWNER);

  const pool = new Pool({ connectionString: POSTGRES_URL });

  await pool.query("select 1");

  setInterval(() => {
    console.log("[worker] heartbeat");
  }, 30000);

  setInterval(async () => {
    try {
      const task = await claimOnce(pool);
      if (task) {
        try {
          const policy = resolveExecutionPolicy(task);

          logExecutionPolicyRuntime(task, policy);
        } catch (err) {
          console.warn("[worker][execution-policy] failed to resolve policy");
        }

        const executionResult = executeTaskWithContract(task);

        await completeSuccess(pool, task, executionResult);
      }
    } catch (err) {
      console.error("[worker] claim loop error:", err?.message || err);
    }
  }, CLAIM_INTERVAL_MS);
}

main().catch(err => {
  console.error("[worker] fatal error:", err);
  process.exit(1);
});
