import type {
  GovernanceEnvelopeRouteResult,
} from "../routes/governance-envelope-route.js";
import type {
  ProductionLifecycleEntryPointInput,
} from "./production-lifecycle-entry-point.js";
import {
  handoffProductionEnvelopeToLifecycle,
} from "./production-envelope-lifecycle-handoff.js";

export type ProductionPostEnvelopeLifecycleCompositionInput = {
  envelope_result: GovernanceEnvelopeRouteResult;
  lifecycle_input: ProductionLifecycleEntryPointInput;
};

export type ProductionPostEnvelopeLifecycleCompositionResult =
  | {
      ok: true;
      composition: "production_post_envelope_lifecycle";
      handoff: ReturnType<typeof handoffProductionEnvelopeToLifecycle>;
      new_authority_introduced: false;
      findings: string[];
    }
  | {
      ok: false;
      composition: "production_post_envelope_lifecycle";
      handoff?: ReturnType<typeof handoffProductionEnvelopeToLifecycle>;
      new_authority_introduced: false;
      findings: string[];
    };

export function composeProductionPostEnvelopeLifecycle(
  input: ProductionPostEnvelopeLifecycleCompositionInput,
): ProductionPostEnvelopeLifecycleCompositionResult {
  if (!input.envelope_result.ok) {
    return {
      ok: false,
      composition: "production_post_envelope_lifecycle",
      new_authority_introduced: false,
      findings: [
        "Post-envelope lifecycle composition failed closed because the existing Governance Envelope route result was not successful.",
      ],
    };
  }

  const createdEnvelope = input.envelope_result.envelope.envelope;

  if (
    input.lifecycle_input.envelope_id !== createdEnvelope.envelope_id ||
    input.lifecycle_input.envelope.lifecycle_state !==
      createdEnvelope.lifecycle_state
  ) {
    return {
      ok: false,
      composition: "production_post_envelope_lifecycle",
      new_authority_introduced: false,
      findings: [
        "Post-envelope lifecycle composition failed closed because the supplied lifecycle input did not match the completed existing Envelope result.",
      ],
    };
  }

  const handoff = handoffProductionEnvelopeToLifecycle(
    input.lifecycle_input,
  );

  if (!handoff.ok) {
    return {
      ok: false,
      composition: "production_post_envelope_lifecycle",
      handoff,
      new_authority_introduced: false,
      findings: [
        "Post-envelope lifecycle composition failed closed because the existing bounded Envelope-to-Lifecycle handoff rejected the supplied existing lifecycle inputs.",
      ],
    };
  }

  return {
    ok: true,
    composition: "production_post_envelope_lifecycle",
    handoff,
    new_authority_introduced: false,
    findings: [
      "Post-envelope lifecycle composition reused the completed existing Envelope result and already-existing lifecycle inputs without creating new authority.",
    ],
  };
}
