#!/usr/bin/env bash
set -euo pipefail

cd "$(git rev-parse --show-toplevel)"

cat > db/mission-read-model-assembler.ts << 'TS'
import type {
  MissionReadModel,
  MissionStage,
  MissionOwner,
  MissionHealth,
} from "./mission-read-model-types.js";

export interface MissionLifecycleEvidence {
  transition_authorization: string;
  persisted_at: string;
}

export interface MissionAssemblyInput {
  package_id: string;
  package_version: number;
  project_id: string | null;
  conversation_id: string | null;
  requested_outcome: string;

  authorization_state: string | null;
  validation_status: string | null;
  gate_status: string | null;
  lifecycle_state: string | null;

  lifecycle_event_count: number;
  lifecycle_events?: readonly MissionLifecycleEvidence[];

  integrity_warnings?: readonly string[];
}

function deriveStage(input: MissionAssemblyInput): MissionStage {
  if (input.lifecycle_state === "ASSIGNED") {
    return input.lifecycle_event_count > 0 ? "ASSIGNED" : "UNKNOWN";
  }

  if (input.lifecycle_state === "ENVELOPE_CREATED") {
    return "ENVELOPE_CREATED";
  }

  if (input.gate_status === "OPEN") {
    return "ENVELOPE_GATE";
  }

  if (input.validation_status === "VALIDATION_PASSED") {
    return "ENVELOPE_GATE";
  }

  if (input.authorization_state === "AUTHORIZED") {
    return "GOVERNANCE_VALIDATION";
  }

  if (
    input.authorization_state === null &&
    input.validation_status === null &&
    input.gate_status === null &&
    input.lifecycle_state === null
  ) {
    return "AWAITING_DELEGATION";
  }

  return "UNKNOWN";
}

function deriveIntegrityWarnings(
  input: MissionAssemblyInput,
): string[] {
  const warnings = [...(input.integrity_warnings ?? [])];

  if (
    input.validation_status !== null &&
    input.authorization_state !== "AUTHORIZED"
  ) {
    warnings.push(
      "Validation state exists without an authorized delegation.",
    );
  }

  if (
    input.gate_status !== null &&
    input.validation_status !== "VALIDATION_PASSED"
  ) {
    warnings.push(
      "Envelope gate state exists without passed governance validation.",
    );
  }

  if (
    input.lifecycle_state !== null &&
    input.lifecycle_state !== "ASSIGNED" &&
    input.gate_status !== "OPEN"
  ) {
    warnings.push(
      "Envelope lifecycle state exists without an open envelope gate.",
    );
  }

  return warnings;
}

function assembleTimeline(
  events: readonly MissionLifecycleEvidence[],
): MissionReadModel["timeline"] {
  return events
    .map((event, sourceIndex) => ({
      event,
      sourceIndex,
    }))
    .sort((left, right) => {
      const timestampOrder = left.event.persisted_at.localeCompare(
        right.event.persisted_at,
      );

      return timestampOrder !== 0
        ? timestampOrder
        : left.sourceIndex - right.sourceIndex;
    })
    .map(({ event }) => ({
      event_type: event.transition_authorization,
      timestamp: event.persisted_at,
    }));
}

export function assembleMissionReadModel(
  input: MissionAssemblyInput,
): MissionReadModel {
  const stage = deriveStage(input);
  const integrityWarnings = deriveIntegrityWarnings(input);

  const owner: MissionOwner =
    stage === "AWAITING_DELEGATION"
      ? "UNASSIGNED"
      : stage === "GOVERNANCE_VALIDATION" ||
          stage === "ENVELOPE_GATE" ||
          stage === "ENVELOPE_CREATED"
        ? "GOVERNANCE"
        : stage === "ASSIGNED"
          ? "DEPARTMENT"
          : "UNKNOWN";

  const health: MissionHealth =
    integrityWarnings.length > 0
      ? "NEEDS_ATTENTION"
      : stage === "AWAITING_DELEGATION"
        ? "WAITING"
        : "HEALTHY";

  const awaiting =
    stage === "AWAITING_DELEGATION"
      ? "Delegation authorization"
      : stage === "GOVERNANCE_VALIDATION"
        ? "Governance validation"
        : stage === "ENVELOPE_GATE"
          ? "Envelope creation"
          : null;

  return {
    identity: {
      package_id: input.package_id,
      package_version: input.package_version,
      project_id: input.project_id,
      conversation_id: input.conversation_id,
    },

    requested_outcome: input.requested_outcome,

    stage,

    owner,

    health,

    awaiting,

    evidence: {
      artifact_count: 0,
      lifecycle_event_count: input.lifecycle_event_count,
      integrity_warnings: integrityWarnings,
      latest_timestamp: null,
    },

    timeline: assembleTimeline(input.lifecycle_events ?? []),
  };
}
TS

cat > db/mission-read-repository.ts << 'TS'
/*
 * Mission Read Repository
 *
 * Read-only persistence adapter for the Mission Read Model.
 * This layer retrieves authoritative governance evidence only.
 * State derivation remains the responsibility of the assembler.
 */

import type { Database } from "better-sqlite3";
import type { MissionAssemblyInput } from "./mission-read-model-assembler";

export interface MissionReadRepository {
  loadMission(
    packageId: string,
  ): Promise<MissionAssemblyInput | null>;
}

export function createMissionReadRepository(
  db: Database,
): MissionReadRepository {
  const packageStatement = db.prepare(`
    SELECT
      package_id,
      package_version,
      project_id,
      conversation_id,
      requested_outcome
    FROM governance_packages
    WHERE package_id = ?
    LIMIT 1
  `);

  const delegationStatement = db.prepare(`
    SELECT authorization_state
    FROM governance_delegations
    WHERE package_id = ?
      AND package_version = ?
    ORDER BY created_at DESC
    LIMIT 1
  `);

  const validationStatement = db.prepare(`
    SELECT validation_status
    FROM governance_validation_results
    WHERE package_id = ?
      AND package_version = ?
    ORDER BY created_at DESC
    LIMIT 1
  `);

  const gateStatement = db.prepare(`
    SELECT gate_status
    FROM governance_envelope_gates
    WHERE package_id = ?
      AND package_version = ?
    ORDER BY created_at DESC
    LIMIT 1
  `);

  const envelopeStatement = db.prepare(`
    SELECT
      envelope_id,
      lifecycle_state
    FROM governance_envelopes
    WHERE package_id = ?
      AND package_version = ?
    ORDER BY created_at DESC
    LIMIT 1
  `);

  const lifecycleEventsStatement = db.prepare(`
    SELECT
      transition_authorization,
      persisted_at
    FROM governance_lifecycle_events
    WHERE envelope_id = ?
    ORDER BY persisted_at ASC, event_id ASC
  `);

  return {
    async loadMission(
      packageId: string,
    ): Promise<MissionAssemblyInput | null> {
      const pkg = packageStatement.get(packageId) as
        | {
            package_id: string;
            package_version: number;
            project_id: string | null;
            conversation_id: string | null;
            requested_outcome: string;
          }
        | undefined;

      if (!pkg) {
        return null;
      }

      const delegation = delegationStatement.get(
        pkg.package_id,
        pkg.package_version,
      ) as
        | { authorization_state: string }
        | undefined;

      const validation = validationStatement.get(
        pkg.package_id,
        pkg.package_version,
      ) as
        | { validation_status: string }
        | undefined;

      const gate = gateStatement.get(
        pkg.package_id,
        pkg.package_version,
      ) as
        | { gate_status: string }
        | undefined;

      const envelope = envelopeStatement.get(
        pkg.package_id,
        pkg.package_version,
      ) as
        | {
            envelope_id: string;
            lifecycle_state: string | null;
          }
        | undefined;

      const lifecycleEvents = envelope
        ? (lifecycleEventsStatement.all(envelope.envelope_id) as Array<{
            transition_authorization: string;
            persisted_at: string;
          }>)
        : [];

      return {
        package_id: pkg.package_id,
        package_version: pkg.package_version,
        project_id: pkg.project_id,
        conversation_id: pkg.conversation_id,
        requested_outcome: pkg.requested_outcome,
        authorization_state: delegation?.authorization_state ?? null,
        validation_status: validation?.validation_status ?? null,
        gate_status: gate?.gate_status ?? null,
        lifecycle_state: envelope?.lifecycle_state ?? null,
        lifecycle_event_count: lifecycleEvents.length,
        lifecycle_events: lifecycleEvents,
        integrity_warnings: [],
      };
    },
  };
}
TS

printf '\n=== TARGETED VALIDATION ===\n'
npx tsx db/mission-read-model-assembler.test.ts
npx tsx db/mission-read-repository.test.ts
npx tsx db/mission-read-model.integration.test.ts

printf '\n=== CLIENT BUILD ===\n'
npm run build --prefix client

printf '\n=== LIVE PROJECTION ===\n'
npx tsx -e '
import Database from "better-sqlite3";
import { createMissionReadRepository } from "./db/mission-read-repository.ts";
import { assembleMissionReadModel } from "./db/mission-read-model-assembler.ts";
const db = new Database("db/main.db", { readonly: true });
const repo = createMissionReadRepository(db);
const input = await repo.loadMission("corridor-smoke");
console.log(JSON.stringify(input ? assembleMissionReadModel(input) : null, null, 2));
db.close();
'

printf '\n=== WORKTREE ===\n'
git status --short
