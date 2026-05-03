import { getGovernanceExecutionEligibilitySnapshot } from "../../../governance/cognition";
import {
  createConsumptionRegistryEnforcementReadonlyView,
  type ConsumptionRegistryEnforcementReadonlyView,
} from "./consumption_registry_enforcement_readonly_view";

export interface ConsumptionRegistryEnforcementEntrypointResult {
  ok: boolean;
  blockedByGovernance: boolean;
  governanceReason: string | null;
  view: ConsumptionRegistryEnforcementReadonlyView;
}

export function runConsumptionRegistryEnforcementEntrypoint(): ConsumptionRegistryEnforcementEntrypointResult {
  const governance = getGovernanceExecutionEligibilitySnapshot();
  const view = createConsumptionRegistryEnforcementReadonlyView();

  if (!governance.authorizationEligible) {
    return {
      ok: false,
      blockedByGovernance: true,
      governanceReason: governance.governanceReason,
      view,
    };
  }

  return {
    ok: view.ok,
    blockedByGovernance: false,
    governanceReason: null,
    view,
  };
}
