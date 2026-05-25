
import fs from "fs";

const payloadPath = "SANDBOX_PREVIEW_SAMPLE_PAYLOAD_PHASE739.json";

const requiredTopLevelFields = [

  "schema_version",

  "artifact_id",

  "intent_summary",

  "components",

  "interaction_annotations",

  "inspection_metadata",

  "validation_state"

];

const requiredInspectionMetadata = {

  sandbox_only: true,

  runtime_authority: false,

  preview_authority: false,

  execution_authority: false

};

const failures = [];

if (!fs.existsSync(payloadPath)) {

  failures.push(`Missing payload file: ${payloadPath}`);

} else {

  const raw = fs.readFileSync(payloadPath, "utf8");

  let payload;

  try {

    payload = JSON.parse(raw);

  } catch (error) {

    failures.push(`Invalid JSON: ${error.message}`);

  }

  if (payload) {

    for (const field of requiredTopLevelFields) {

      if (!(field in payload)) failures.push(`Missing top-level field: ${field}`);

    }

    if (payload.schema_version !== "sandbox-preview-payload.v1") {

      failures.push("Invalid schema_version");

    }

    const componentIds = new Set();

    if (!Array.isArray(payload.components)) {

      failures.push("components must be an array");

    } else {

      for (const component of payload.components) {

        if (!component.component_id) failures.push("Component missing component_id");

        if (!component.component_type) failures.push("Component missing component_type");

        if (!component.semantic_role) failures.push("Component missing semantic_role");

        if (component.component_id) {

          if (componentIds.has(component.component_id)) {

            failures.push(`Duplicate component_id: ${component.component_id}`);

          }

          componentIds.add(component.component_id);

        }

      }

    }

    if (!Array.isArray(payload.interaction_annotations)) {

      failures.push("interaction_annotations must be an array");

    } else {

      for (const annotation of payload.interaction_annotations) {

        if (!annotation.annotation_id) failures.push("Annotation missing annotation_id");

        if (!annotation.annotation_type) failures.push("Annotation missing annotation_type");

        if (!annotation.target_component_id) failures.push("Annotation missing target_component_id");

        if (annotation.target_component_id && !componentIds.has(annotation.target_component_id)) {

          failures.push(`Annotation targets missing component: ${annotation.target_component_id}`);

        }

      }

    }

    if (!payload.inspection_metadata || typeof payload.inspection_metadata !== "object") {

      failures.push("inspection_metadata must be an object");

    } else {

      for (const [key, expectedValue] of Object.entries(requiredInspectionMetadata)) {

        if (payload.inspection_metadata[key] !== expectedValue) {

          failures.push(`inspection_metadata.${key} must be ${expectedValue}`);

        }

      }

    }

  }

}

if (failures.length > 0) {

  console.log("❌ Phase 739 sample payload validation FAILED");

  for (const failure of failures) console.log(`- ${failure}`);

  process.exit(1);

}

console.log("✅ Phase 739 sample payload validation PASSED");

console.log(`Validated: ${payloadPath}`);

