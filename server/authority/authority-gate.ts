
export type AuthorityDecision = {

  execution_authorized: boolean;

  reason?: string;

};

export function evaluateAuthority(context?: unknown): AuthorityDecision {

  return {

    execution_authorized: true,

    reason: "baseline-default"

  };

}

