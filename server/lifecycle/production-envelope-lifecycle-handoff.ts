import {
  invokeProductionLifecycleEntryPoint,
  type ProductionLifecycleEntryPointInput,
  type ProductionLifecycleEntryPointResult,
} from "./production-lifecycle-entry-point.js";

export type ProductionEnvelopeLifecycleHandoffInput =
  ProductionLifecycleEntryPointInput;

export type ProductionEnvelopeLifecycleHandoffResult =
  ProductionLifecycleEntryPointResult & {
    handoff: "production_envelope_to_lifecycle";
    new_authority_introduced: false;
  };

export function handoffProductionEnvelopeToLifecycle(
  input: ProductionEnvelopeLifecycleHandoffInput,
): ProductionEnvelopeLifecycleHandoffResult {
  const result = invokeProductionLifecycleEntryPoint(input);

  return {
    ...result,
    handoff: "production_envelope_to_lifecycle",
    new_authority_introduced: false,
  };
}
