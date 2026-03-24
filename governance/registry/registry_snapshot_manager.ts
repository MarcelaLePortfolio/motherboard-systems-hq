/*
Phase 151C/151G — Registry Snapshot Surface

Purpose:
Define deterministic snapshot structure required before any mutation may execute.

Phase 151G expands snapshot content so rollback can restore the
metadata-only registry state.

This does NOT introduce generalized registry mutation.
Snapshot scaffold + metadata-state capture only.
*/

import { CapabilityMetadata } from "./registry_owner"

export type RegistrySnapshot = {
  snapshot_id: string
  timestamp: string
  registry_owner: string
  capability_ids: string[]
  governance_classes: string[]
  authorization_model_version: string
  registry_version: string
  capabilities: CapabilityMetadata[]
}

export class RegistrySnapshotManager {
  private snapshots: RegistrySnapshot[] = []

  createSnapshot(snapshot: RegistrySnapshot): void {
    // Phase 151C/151G rule:
    // Append-only snapshot model

    this.snapshots.push({
      ...snapshot,
      capability_ids: [...snapshot.capability_ids],
      governance_classes: [...snapshot.governance_classes],
      capabilities: snapshot.capabilities.map((capability) => ({ ...capability }))
    })
  }

  getSnapshots(): RegistrySnapshot[] {
    // Read-only exposure

    return this.snapshots.map((snapshot) => ({
      ...snapshot,
      capability_ids: [...snapshot.capability_ids],
      governance_classes: [...snapshot.governance_classes],
      capabilities: snapshot.capabilities.map((capability) => ({ ...capability }))
    }))
  }

  getLatestSnapshot(): RegistrySnapshot | undefined {
    const snapshot = this.snapshots[this.snapshots.length - 1]
    if (!snapshot) {
      return undefined
    }

    return {
      ...snapshot,
      capability_ids: [...snapshot.capability_ids],
      governance_classes: [...snapshot.governance_classes],
      capabilities: snapshot.capabilities.map((capability) => ({ ...capability }))
    }
  }
}
