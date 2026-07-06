
import fs from "fs";

export type CadeExecutionRegistry = {

  hard_rules: {

    no_direct_EXECUTABLE_assignment: boolean;

    execution_is_always_derived: boolean;

    only_execution_influencers_may_mutate_state: boolean;

    all_other_layers_may_only_consume: boolean;

  };

  execution_state_model: {

    states: string[];

    final_state_is_derived_only: boolean;

  };

  invariants: {

    EXECUTABLE_is_never_stored: boolean;

    registry_is_single_source_of_truth: boolean;

    conflicting_sources_are_invalid: boolean;

  };

};

export function loadCadeExecutionRegistry(): CadeExecutionRegistry {

  const raw = fs.readFileSync(

    "docs/governance/CADE_EXECUTION_SOURCE_OF_TRUTH_REGISTRY.json",

    "utf-8"

  );

  return JSON.parse(raw);

}

