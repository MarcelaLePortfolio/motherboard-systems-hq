/*
Phase 151B — Registry Mutation Logging Surface

Purpose:
Define deterministic mutation logging structure before any mutation may execute.

NO mutation execution enabled.
Logging scaffold only.
*/

export type RegistryMutationLog = {
  mutation_id: string
  operator_id: string
  capability_id: string
  mutation_type: string
  governance_class: string
  timestamp: string
  snapshot_id?: string
  verification_state: "pending" | "verified" | "rejected"
  result: "accepted" | "rejected"
  reason?: string
}

export class RegistryMutationLogger {

  private logs: RegistryMutationLog[] = []

  record(log: RegistryMutationLog): void {

    // Phase 151B rule:
    // Append-only log model

    this.logs.push(log)

  }

  getLogs(): RegistryMutationLog[] {

    // Read-only exposure

    return [...this.logs]

  }

}
