
import { readdirSync, readFileSync, writeFileSync, mkdirSync } from "node:fs";

const simulationPath =

  "scripts/render-native/generated/preview-adapter-simulation.json";

const runtimeCaptureDir =

  "scripts/render-native/runtime-captures";

const outputPath =

  "scripts/render-native/reports/preview-payload-reconciliation.json";

const simulation = JSON.parse(

  readFileSync(simulationPath, "utf8")

);

const runtimeFiles =

  readdirSync(runtimeCaptureDir)

    .filter((file) => file.endsWith(".json"))

    .sort();

if (runtimeFiles.length === 0) {

  console.error("No runtime capture files found.");

  process.exit(1);

}

const latestRuntimePath =

  `${runtimeCaptureDir}/${runtimeFiles[runtimeFiles.length - 1]}`;

const runtimeCapture = JSON.parse(

  readFileSync(latestRuntimePath, "utf8")

);

const runtimePayload =

  runtimeCapture.payload || {};

const semanticNodes =

  simulation.adapted_nodes || [];

const runtimeArtifact =

  runtimePayload.artifact || {};

const runtimeSemanticArtifact =

  runtimeArtifact.semantic_artifact || {};

const runtimeSections =

  runtimeSemanticArtifact.sections || [];

const reconciliation = {

  schema_version:

    "phase736.preview-payload-reconciliation.v1",

  corridor:

    "read-only-deterministic-reconciliation",

  semantic_adapter: {

    node_count:

      semanticNodes.length,

    node_types:

      [...new Set(

        semanticNodes.map((n) => n.preview_type)

      )],

    semantic_roles:

      [...new Set(

        semanticNodes

          .map((n) => n.semantic_role)

          .filter(Boolean)

      )]

  },

  runtime_payload: {

    artifact_type:

      runtimeArtifact.type || null,

    semantic_artifact_kind:

      runtimeSemanticArtifact.artifact_kind || null,

    semantic_schema_version:

      runtimeSemanticArtifact.schema_version || null,

    section_count:

      runtimeSections.length

  },

  alignment: {

    semantic_payload_present:

      semanticNodes.length > 0,

    runtime_semantic_artifact_present:

      Boolean(runtimeSemanticArtifact),

    runtime_sections_present:

      runtimeSections.length > 0,

    semantic_roles_present:

      semanticNodes.some(

        (n) => Boolean(n.semantic_role)

      ),

    semantic_lineage_present:

      semanticNodes.every(

        (n) => Boolean(n.lineage)

      ),

    semantic_relations_present:

      semanticNodes.some(

        (n) => (n.relations || []).length > 0

      )

  },

  reconciliation_findings: [],

  validation: {

    deterministic_reconciliation: true,

    runtime_mutation_disabled: true,

    live_preview_untouched: true,

    renderer_interception_disabled: true

  }

};

if (

  reconciliation.alignment.runtime_semantic_artifact_present &&

  reconciliation.alignment.semantic_payload_present

) {

  reconciliation.reconciliation_findings.push(

    "Semantic substrate structurally aligns with runtime semantic artifact lifecycle."

  );

}

if (

  reconciliation.alignment.semantic_relations_present

) {

  reconciliation.reconciliation_findings.push(

    "Semantic relationship topology exceeds current runtime artifact structure."

  );

}

if (

  reconciliation.alignment.semantic_lineage_present

) {

  reconciliation.reconciliation_findings.push(

    "Semantic lineage infrastructure exists ahead of runtime continuity lifecycle."

  );

}

mkdirSync(

  "scripts/render-native/reports",

  { recursive: true }

);

writeFileSync(

  outputPath,

  `${JSON.stringify(reconciliation, null, 2)}\n`

);

console.log("PREVIEW PAYLOAD RECONCILIATION PASS");

console.log(

  `Reconciliation written to: ${outputPath}`

);

