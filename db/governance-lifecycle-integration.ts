
import {

  composeGovernanceLifecycleAssignmentTransition,

  type ComposeGovernanceLifecycleAssignmentTransitionInput,

  type ComposedGovernanceLifecycleAssignmentTransitionResult,

} from "./governance-lifecycle-composition";

import {

  persistGovernanceEnvelopeLifecycleTransition,

} from "./governance-lifecycle-persistence";

export type CompleteGovernanceLifecycleAssignmentTransitionInput = Omit<

  ComposeGovernanceLifecycleAssignmentTransitionInput,

  "persist"

> & {

  db?: unknown;

};

export type CompletedGovernanceLifecycleAssignmentTransitionResult =

  ComposedGovernanceLifecycleAssignmentTransitionResult;

export function completeGovernanceLifecycleAssignmentTransition(

  input: CompleteGovernanceLifecycleAssignmentTransitionInput,

): CompletedGovernanceLifecycleAssignmentTransitionResult {

  return composeGovernanceLifecycleAssignmentTransition({

    envelope_id: input.envelope_id,

    envelope: input.envelope,

    available_departments: input.available_departments ?? [],

    available_actors: input.available_actors ?? [],

    department_handshake: input.department_handshake,

    target_lifecycle_state: "ASSIGNED",

    persisted_at: input.persisted_at,

    persist: ({ envelope_id, transition_authorization, persisted_at }) =>

      persistGovernanceEnvelopeLifecycleTransition({

        envelope_id,

        transition_authorization,

        persisted_at,

        db: input.db as never,

      }),

  });

}


