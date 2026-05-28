
import {

  normalizeGovernedResponse,

} from "./normalize-governed-response.mjs";

import {

  normalizeReconciliationArtifact,

} from "./normalize-reconciliation-artifact.mjs";

import {

  buildGovernanceAuditLedger,

} from "./build-governance-audit-ledger.mjs";

export function buildGovernedPlanningArtifactBundle({

  pipelineResult = {},

} = {}) {

  const envelopeVersion =

    pipelineResult?.draft?.envelope?.envelope_version || null;

  const phase =

    pipelineResult?.phase ||

    "planning_only";

  const trace =

    Array.isArray(pipelineResult?.trace)

      ? pipelineResult.trace

      : [];

  const response =

    normalizeGovernedResponse({

      ok:

        pipelineResult?.ok === true,

      phase,

      envelope_version:

        envelopeVersion,

      governance_ok:

        pipelineResult?.governance?.ok === true,

      approval_gate_ok:

        pipelineResult?.approval_gate?.ok === true,

      cade_plan_ok:

        pipelineResult?.cade_plan?.ok === true,

      mutation_performed: false,

      shell_execution_performed: false,

      autonomous_execution_performed: false,

      trace,

    });

  const reconciliation =

    normalizeReconciliationArtifact({

      envelope_version:

        envelopeVersion,

      phase:

        "planning_completed",

      governance_ok:

        pipelineResult?.governance?.ok === true,

      approval_gate_ok:

        pipelineResult?.approval_gate?.ok === true,

      cade_plan_ok:

        pipelineResult?.cade_plan?.ok === true,

      mutation_performed: false,

      shell_execution_performed: false,

      autonomous_execution_performed: false,

      reconciliation_entries:

        pipelineResult?.cade_plan?.execution?.planned_patches || [],

      trace,

    });

  const auditLedger =

    buildGovernanceAuditLedger({

      envelope_version:

        envelopeVersion,

      phase:

        "planning_completed",

      governance_ok:

        pipelineResult?.governance?.ok === true,

      approval_gate_ok:

        pipelineResult?.approval_gate?.ok === true,

      cade_plan_ok:

        pipelineResult?.cade_plan?.ok === true,

      reconciliation_schema:

        reconciliation.reconciliation_schema,

      mutation_performed: false,

      shell_execution_performed: false,

      autonomous_execution_performed: false,

      trace,

    });

  return {

    ok: true,

    bundle_schema:

      "governed_planning_artifact_bundle.v1",

    phase:

      "planning_completed",

    envelope_version:

      envelopeVersion,

    response,

    reconciliation,

    audit_ledger:

      auditLedger,

    execution_authority: {

      mutation_performed: false,

      shell_execution_performed: false,

      autonomous_execution_performed: false,

    },

  };

}

