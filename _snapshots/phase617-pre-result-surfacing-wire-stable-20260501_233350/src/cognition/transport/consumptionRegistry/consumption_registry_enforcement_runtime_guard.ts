import {
  createConsumptionRegistryEnforcementBundle,
  type ConsumptionRegistryEnforcementBundle,
} from "./consumption_registry_enforcement_bundle";

export interface ConsumptionRegistryEnforcementRuntimeGuardResult {
  ok: boolean;
  bundle: ConsumptionRegistryEnforcementBundle;
  message: string;
}

export function runConsumptionRegistryEnforcementRuntimeGuard(): ConsumptionRegistryEnforcementRuntimeGuardResult {
  const bundle = createConsumptionRegistryEnforcementBundle();
  const ok = bundle.ok === true;

  return {
    ok,
    bundle,
    message: ok
      ? "consumption registry enforcement runtime guard passed"
      : "consumption registry enforcement runtime guard failed",
  };
}
