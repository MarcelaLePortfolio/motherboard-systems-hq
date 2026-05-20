
import fs from "fs";

import path from "path";

function readJson(filePath) {

  return JSON.parse(fs.readFileSync(filePath, "utf8"));

}

function classifyPath(filePath) {

  const normalized = filePath.replace(/\\/g, "/");

  if (normalized.startsWith("scripts/")) {

    return "tooling";

  }

  if (normalized.startsWith("ARTIFACT_SNAPSHOTS/")) {

    return "artifact-snapshot";

  }

  if (normalized.startsWith("ARTIFACT_DIFFS/")) {

    return "artifact-diff";

  }

  if (normalized.startsWith("DISASTER_RECOVERY/")) {

    return "disaster-recovery";

  }

  if (

    normalized.startsWith("public/") ||

    normalized.startsWith("app/") ||

    normalized.startsWith("components/")

  ) {

    return "ui";

  }

  if (

    normalized.includes("docker") ||

    normalized === "docker-compose.yml" ||

    normalized.endsWith(".Dockerfile")

  ) {

    return "infrastructure";

  }

  if (

    normalized.includes("worker") ||

    normalized.includes("runtime") ||

    normalized.includes("server")

  ) {

    return "runtime";

  }

  if (

    normalized.includes("semantic") ||

    normalized.includes("classifier") ||

    normalized.includes("metadata")

  ) {

    return "semantic";

  }

  if (

    normalized.includes("preview") ||

    normalized.includes("renderer") ||

    normalized.includes("visual")

  ) {

    return "preview-renderer";

  }

  if (

    normalized.endsWith(".md") ||

    normalized.includes("docs/") ||

    normalized.includes("README")

  ) {

    return "documentation";

  }

  if (

    normalized.includes("package.json") ||

    normalized.includes("package-lock.json") ||

    normalized.includes("pnpm-lock.yaml")

  ) {

    return "dependency";

  }

  return "unclassified";

}

function classifyRisk(category, changeType, artifactPath) {

  if (category === "disaster-recovery" || category === "documentation") {

    return "low";

  }

  if (category === "artifact-snapshot" || category === "artifact-diff") {

    return "low";

  }

  if (category === "tooling" || category === "semantic") {

    return "medium";

  }

  if (category === "preview-renderer" || category === "ui") {

    return "medium";

  }

  if (category === "runtime" || category === "infrastructure" || category === "dependency") {

    return "high";

  }

  if (artifactPath.includes(".env")) {

    return "high";

  }

  if (changeType === "removed") {

    return "medium";

  }

  return "medium";

}

function normalizeChange(changeType, item) {

  if (changeType === "changed") {

    return {

      type: changeType,

      path: item.path,

      before: item.before,

      after: item.after,

    };

  }

  return {

    type: changeType,

    path: item.path,

    artifact: item,

  };

}

function classifyDiff(diff) {

  const classifiedChanges = [];

  const categoryCounts = {};

  const riskCounts = {};

  for (const changeType of ["added", "removed", "changed"]) {

    for (const item of diff.changes?.[changeType] || []) {

      const artifactPath = changeType === "changed" ? item.path : item.path;

      const category = classifyPath(artifactPath);

      const risk = classifyRisk(category, changeType, artifactPath);

      const normalizedChange = normalizeChange(changeType, item);

      categoryCounts[category] = (categoryCounts[category] || 0) + 1;

      riskCounts[risk] = (riskCounts[risk] || 0) + 1;

      classifiedChanges.push({

        ...normalizedChange,

        semanticCategory: category,

        executionRisk: risk,

      });

    }

  }

  return {

    schemaVersion: "phase735.artifact-diff-classification.v1",

    generatedAt: new Date().toISOString(),

    mode: "read-only",

    sourceDiff: {

      schemaVersion: diff.schemaVersion || null,

      generatedAt: diff.generatedAt || null,

      before: diff.before || null,

      after: diff.after || null,

      summary: diff.summary || null,

    },

    classificationSummary: {

      totalClassifiedChanges: classifiedChanges.length,

      categoryCounts,

      riskCounts,

      hasHighRiskChanges: Boolean(riskCounts.high),

      hasRuntimeOrInfrastructureChanges: Boolean(

        categoryCounts.runtime ||

        categoryCounts.infrastructure ||

        categoryCounts.dependency

      ),

      hasPreviewRendererChanges: Boolean(categoryCounts["preview-renderer"]),

      hasDisasterRecoveryChanges: Boolean(categoryCounts["disaster-recovery"]),

      hasArtifactLayerChanges: Boolean(

        categoryCounts["artifact-snapshot"] ||

        categoryCounts["artifact-diff"]

      ),

    },

    classifiedChanges,

  };

}

function usage() {

  console.error("Usage: node scripts/artifact-diff-classifier.mjs <diff-file.json> [output-file.json]");

  process.exit(1);

}

const [diffFile, outputFile] = process.argv.slice(2);

if (!diffFile) {

  usage();

}

const diffPath = path.resolve(diffFile);

const diff = readJson(diffPath);

const classification = classifyDiff(diff);

classification.sourceDiff.file = diffPath;

const output = `${JSON.stringify(classification, null, 2)}\n`;

if (outputFile) {

  const resolvedOutput = path.resolve(outputFile);

  fs.mkdirSync(path.dirname(resolvedOutput), { recursive: true });

  fs.writeFileSync(resolvedOutput, output);

  console.log(`Artifact diff classification written: ${resolvedOutput}`);

} else {

  process.stdout.write(output);

}

