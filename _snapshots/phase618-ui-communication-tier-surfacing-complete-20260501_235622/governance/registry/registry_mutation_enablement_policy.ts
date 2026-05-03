/*
Phase 151F — Registry Mutation Enablement Policy

Purpose:
Define the explicit governance gate that determines whether registry mutation
is even eligible for consideration.

This phase does NOT enable live mutation execution.
It only introduces the policy surface and default-disabled gate.
*/

export type MutationEnablementPolicy = {
  registry_mutation_enabled: boolean
  allowed_governance_classes: string[]
  authorization_required: boolean
  policy_version: string
}

export class RegistryMutationEnablementPolicyManager {
  private policy: MutationEnablementPolicy

  constructor(policy?: MutationEnablementPolicy) {
    this.policy = policy ?? {
      registry_mutation_enabled: false,
      allowed_governance_classes: [],
      authorization_required: true,
      policy_version: "phase151f-default-disabled"
    }
  }

  getPolicy(): MutationEnablementPolicy {
    return { ...this.policy }
  }

  setPolicy(policy: MutationEnablementPolicy): void {
    this.policy = {
      registry_mutation_enabled: policy.registry_mutation_enabled,
      allowed_governance_classes: [...policy.allowed_governance_classes],
      authorization_required: policy.authorization_required,
      policy_version: policy.policy_version
    }
  }

  isMutationEnabled(): boolean {
    return this.policy.registry_mutation_enabled
  }

  isGovernanceClassAllowed(governanceClass: string): boolean {
    return this.policy.allowed_governance_classes.includes(governanceClass)
  }
}
