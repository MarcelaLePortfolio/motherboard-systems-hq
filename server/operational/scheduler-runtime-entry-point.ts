
import { buildExecutionAuthoritySnapshot } from "../execution/execution-authority.adapter";

export function schedulerRuntimeEntryPoint(input: any) {

  const authority = buildExecutionAuthoritySnapshot(input);

  return {

    ...input,

    execution_authorized: authority.execution_authorized,

    authority_reason: authority.reason,

    authority_source: authority.source

  };

}

