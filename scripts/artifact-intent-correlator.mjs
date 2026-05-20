
import fs from "fs";

import path from "path";

function readJson(filePath) {

  return JSON.parse(fs.readFileSync(filePath, "utf8"));

}

function normalize(text) {

  return String(text || "").toLowerCase();

}

function inferIntentSignals(intentText) {

  const intent = normalize(intentText);

  return {

    mentionsSnapshot: /\bsnapshot|artifact|state|inventory|hash|graph\b/.test(intent),

    mentionsDiff: /\bdiff|compare|comparison|changed|added|removed|delta\b/.test(intent),

    mentionsSemantic: /\bsemantic|classify|classification|meaning|interpret|category\b/.test(intent),

    mentionsPreview: /\bpreview|renderer|visual|modal|display\b/.test(intent),

    mentionsRuntime: /\bruntime|server|worker|docker|container|execution|execute\b/.test(intent),

    mentionsDisasterRecovery: /\bbackup|disaster|recovery|restore|vault|external|drive\b/.test(intent),

    mentionsDocumentation: /\bdoc|docs|readme|handoff|protocol|summary\b/.test(intent),

    mentionsUI: /\bui|interface|dashboard|component|screen|button\b/.test(intent),

    mentionsDependency: /\bdependency|package|npm|pnpm|install|lockfile\b/.test(intent),

  };

}

function expectedCategoriesFromSignals(signals) {

  const expected = new Set();

  if (signals.mentionsSnapshot) expected.add("artifact-snapshot");

  if (signals.mentionsDiff) expected.add("artifact-diff");

  if (signals.mentionsSemantic) expected.add("semantic");

  if (signals.mentionsPreview) expected.add("preview-renderer");

  if (signals.mentionsRuntime) expected.add("runtime");

  if (signals.mentionsRuntime) expected.add("infrastructure");

  if (signals.mentionsDisasterRecovery) expected.add("disaster-recovery");

  if (signals.mentionsDocumentation) expected.add("documentation");

  if (signals.mentionsUI) expected.add("ui");

  if (signals.mentionsDependency) expected.add("dependency");

  if (expected.size === 0) {

    expected.add("tooling");

    expected.add("semantic");

  }

  return [...expected];

}

function scoreAlignment(expectedCategories, actualCategoryCounts) {

  const actualCategories = Object.keys(actualCategoryCounts || {});

  const matched = actualCategories.filter((category) => expectedCategories.includes(category));

  const unexpected = actualCategories.filter((category) => !expectedCategories.includes(category));

  const totalActualChanges = Object.values(actualCategoryCounts || {}).reduce((sum, count) => sum + count, 0);

  const matchedChanges = matched.reduce((sum, category) => sum + actualCategoryCounts[category], 0);

  const alignmentScore = totalActualChanges === 0

    ? 1

    : Number((matchedChanges / totalActualChanges).toFixed(4));

  return {

    alignmentScore,

    matchedCategories: matched,

    unexpectedCategories: unexpected,

    totalActualChanges,

    matchedChanges,

  };

}

function correlateIntent(intentText, classification) {

  const signals = inferIntentSignals(intentText);

  const expectedCategories = expectedCategoriesFromSignals(signals);

  const actualCategoryCounts = classification.classificationSummary?.categoryCounts || {};

  const riskCounts = classification.classificationSummary?.riskCounts || {};

  const alignment = scoreAlignment(expectedCategories, actualCategoryCounts);

  const hasHighRiskUnexpectedChanges = alignment.unexpectedCategories.some((category) => {

    return ["runtime", "infrastructure", "dependency"].includes(category);

  });

  const driftDetected = alignment.unexpectedCategories.length > 0 && alignment.totalActualChanges > 0;

  return {

    schemaVersion: "phase735.artifact-intent-correlation.v1",

    generatedAt: new Date().toISOString(),

    mode: "read-only",

    intent: {

      raw: intentText,

      inferredSignals: signals,

      expectedSemanticCategories: expectedCategories,

    },

    sourceClassification: {

      schemaVersion: classification.schemaVersion || null,

      generatedAt: classification.generatedAt || null,

      sourceDiff: classification.sourceDiff || null,

      classificationSummary: classification.classificationSummary || null,

    },

    correlationSummary: {

      alignmentScore: alignment.alignmentScore,

      totalActualChanges: alignment.totalActualChanges,

      matchedChanges: alignment.matchedChanges,

      matchedCategories: alignment.matchedCategories,

      unexpectedCategories: alignment.unexpectedCategories,

      riskCounts,

      driftDetected,

      hasHighRiskUnexpectedChanges,

      advisoryStatus:

        alignment.totalActualChanges === 0

          ? "no-change-baseline"

          : driftDetected

            ? "requires-review"

            : "aligned",

    },

    advisoryNotes: [

      "This artifact is read-only and does not authorize execution.",

      "Intent correlation is advisory and must not bypass Matilda validation.",

      "Unexpected runtime, infrastructure, or dependency categories require elevated review before execution.",

    ],

  };

}

function usage() {

  console.error("Usage: node scripts/artifact-intent-correlator.mjs <classification-file.json> <intent-text> [output-file.json]");

  process.exit(1);

}

const [classificationFile, intentText, outputFile] = process.argv.slice(2);

if (!classificationFile || !intentText) {

  usage();

}

const classificationPath = path.resolve(classificationFile);

const classification = readJson(classificationPath);

const correlation = correlateIntent(intentText, classification);

correlation.sourceClassification.file = classificationPath;

const output = `${JSON.stringify(correlation, null, 2)}\n`;

if (outputFile) {

  const resolvedOutput = path.resolve(outputFile);

  fs.mkdirSync(path.dirname(resolvedOutput), { recursive: true });

  fs.writeFileSync(resolvedOutput, output);

  console.log(`Artifact intent correlation written: ${resolvedOutput}`);

} else {

  process.stdout.write(output);

}

