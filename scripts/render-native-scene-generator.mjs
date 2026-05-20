
import fs from "fs";

import path from "path";

function readJson(filePath) {

  return JSON.parse(fs.readFileSync(filePath, "utf8"));

}

function statusTone(status) {

  const normalized = String(status || "").toLowerCase();

  if (normalized.includes("ready") || normalized.includes("pass")) return "ready";

  if (normalized.includes("blocked") || normalized.includes("not active")) return "blocked";

  if (normalized.includes("required") || normalized.includes("pending")) return "warning";

  if (normalized.includes("critical")) return "critical";

  return "info";

}

function buildScene(previewRunDir) {

  const overlay = readJson(path.join(previewRunDir, "04-preview-overlay.json"));

  const interpretation = readJson(path.join(previewRunDir, "05-matilda-interpretation.json"));

  const recommendation = readJson(path.join(previewRunDir, "06-execution-recommendation.json"));

  const governance = readJson(path.join(previewRunDir, "07-human-governance-boundary.json"));

  const readiness = readJson(path.join(previewRunDir, "08-execution-readiness.json"));

  const reconciliation = readJson(path.join(previewRunDir, "09-reconciliation-validation.json"));

  const changeSummary = overlay.changeSummary || {};

  const gateDecision = interpretation.gateDecision || {};

  const rec = recommendation.recommendation || {};

  const gov = governance.governanceDecision || {};

  const readinessSummary = readiness.readiness || {};

  const reconciliationSummary = reconciliation.reconciliation || {};

  return {

    schemaVersion: "phase736.render-native-scene-instance.v1",

    generatedAt: new Date().toISOString(),

    mode: "read-only",

    sceneType: "executiveDashboard",

    title: "Execution Bridge Readiness Command Center",

    subtitle: "Governed visual scene generated from full preview pipeline output",

    statusBadge: "READ-ONLY / NO MUTATION",

    theme: {

      background: "navy-glass",

      accents: ["teal", "violet", "amber", "coral", "emerald"],

      density: "executive",

      hierarchy: "command-center",

    },

    regions: [

      {

        type: "hero",

        title: "Execution Bridge Readiness Command Center",

        subtitle: "Motherboard Systems governed preview substrate",

        badges: [

          { label: "READ-ONLY", tone: "info" },

          { label: "NO MUTATION", tone: "blocked" },

          { label: "HUMAN APPROVAL REQUIRED", tone: "warning" },

        ],

      },

      {

        type: "status-grid",

        title: "Readiness Matrix",

        cards: [

          {

            label: "Snapshot Layer",

            status: "READY",

            tone: "ready",

            detail: "Artifact state capture is operational.",

          },

          {

            label: "Diff Layer",

            status: "READY",

            tone: "ready",

            detail: "Snapshot comparison is operational.",

          },

          {

            label: "Matilda Interpretation",

            status: String(gateDecision.decision || "UNKNOWN").toUpperCase(),

            tone: statusTone(gateDecision.decision),

            detail: gateDecision.reason || "Semantic interpretation generated.",

          },

          {

            label: "Human Approval Boundary",

            status: String(gov.approvalStatus || "REQUIRED").toUpperCase(),

            tone: "warning",

            detail: "Approval remains mandatory before execution.",

          },

          {

            label: "Execution Bridge",

            status: String(rec.executionReadiness || "NOT ACTIVE").toUpperCase(),

            tone: statusTone(rec.executionReadiness || "blocked"),

            detail: "Execution authority is not delegated.",

          },

          {

            label: "Reconciliation",

            status: String(reconciliationSummary.status || "REQUIRED").toUpperCase(),

            tone: statusTone(reconciliationSummary.status || "required"),

            detail: "Post-execution validation remains required.",

          },

        ],

      },

      {

        type: "orchestration-map",

        title: "Governed Execution Flow",

        nodes: [

          "Intent",

          "Snapshot",

          "Diff",

          "Classification",

          "Intent Correlation",

          "Preview Overlay",

          "Matilda",

          "Human Approval",

          "Execution Bridge",

          "Reconciliation",

        ].map((label, index) => ({

          label,

          stage: index + 1,

          status:

            label === "Execution Bridge"

              ? "blocked"

              : label === "Human Approval"

                ? "required"

                : "ready",

          tone:

            label === "Execution Bridge"

              ? "blocked"

              : label === "Human Approval"

                ? "warning"

                : "ready",

        })),

      },

      {

        type: "governance-boundary",

        title: "Governance Boundary",

        tone: "warning",

        requirements: [

          "Human approval required",

          "Execution remains blocked",

          "Rollback path required",

          "Reconciliation required after mutation",

          "Advisory cognition does not grant execution authority",

        ],

      },

      {

        type: "risk-zones",

        title: "Semantic Risk Zones",

        risks: [

          {

            label: "Runtime Mutation Risk",

            severity: "high",

            description: "Execution bridge is not active and mutation remains blocked.",

            mitigation: "Require explicit approval, rollback path, and reconciliation.",

          },

          {

            label: "Renderer Fallback Risk",

            severity: "medium",

            description: "Dashboard may still fall back to semantic artifact shell.",

            mitigation: "Route render-native scene graph to a dedicated visual renderer.",

          },

          {

            label: "Governance Bypass Risk",

            severity: "critical",

            description: "Any execution without approval violates system invariants.",

            mitigation: "Keep human approval boundary structurally enforced.",

          },

          {

            label: "Reconciliation Drift Risk",

            severity: "medium",

            description: "Future execution must compare intended and actual post-state.",

            mitigation: "Require post-execution snapshot and reconciliation validator.",

          },

        ],

      },

      {

        type: "executive-summary",

        title: "Executive Summary",

        body:

          "The system is ready for governed preview reasoning and render-native scene planning, but runtime mutation is not authorized. The next architectural target is renderer consumption of structured scene graphs instead of markdown fallback shells.",

        highlights: [

          `Alignment score: ${changeSummary.alignmentScore ?? "unknown"}`,

          `Gate decision: ${gateDecision.decision || "unknown"}`,

          `Execution readiness: ${rec.executionReadiness || "unknown"}`,

          `Readiness blocked: ${readinessSummary.executionBlockedUntilApproval ?? true}`,

        ],

      },

    ],

    governanceRules: {

      executionAuthorized: false,

      mutationPermitted: false,

      humanApprovalRequired: true,

      reconciliationRequired: true,

      advisoryOnly: true,

    },

    sourcePreviewRun: path.resolve(previewRunDir),

  };

}

function usage() {

  console.error("Usage: node scripts/render-native-scene-generator.mjs <full-preview-run-dir> [output-file.json]");

  process.exit(1);

}

const [previewRunDir, outputFile] = process.argv.slice(2);

if (!previewRunDir) {

  usage();

}

const resolvedPreviewRunDir = path.resolve(previewRunDir);

const scene = buildScene(resolvedPreviewRunDir);

const output = `${JSON.stringify(scene, null, 2)}\n`;

if (outputFile) {

  const resolvedOutput = path.resolve(outputFile);

  fs.mkdirSync(path.dirname(resolvedOutput), { recursive: true });

  fs.writeFileSync(resolvedOutput, output);

  console.log(`Render-native scene written: ${resolvedOutput}`);

} else {

  process.stdout.write(output);

}

