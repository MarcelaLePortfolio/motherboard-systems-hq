
import { evaluateExecutionAuthority } from "../execution/execution-authority-core";

export function schedulerRuntimeEntryPoint(input: any) {

  const decision = evaluateExecutionAuthority({

    preview_confirmed: input.preview_confirmed,

    plan_review_ready: input.plan_review_ready

  });

  return {

    ...input,

    execution_authorized: decision.execution_authorized,

    authority_reason: decision.reason

  };

}

