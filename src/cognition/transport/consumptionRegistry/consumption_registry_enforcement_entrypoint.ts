import {
  createConsumptionRegistryEnforcementReadonlyView,
  type ConsumptionRegistryEnforcementReadonlyView,
} from "./consumption_registry_enforcement_readonly_view";

export interface ConsumptionRegistryEnforcementEntrypointResult {
  ok: boolean;
  view: ConsumptionRegistryEnforcementReadonlyView;
}

export function runConsumptionRegistryEnforcementEntrypoint(): ConsumptionRegistryEnforcementEntrypointResult {
  const view = createConsumptionRegistryEnforcementReadonlyView();

  return {
    ok: view.ok,
    view,
  };
}
