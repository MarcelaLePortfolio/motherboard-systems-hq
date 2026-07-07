
export type AuthorityContext = {

  source?: string;

  urgency?: "low" | "medium" | "high";

  mode?: "diagnostic" | "simulation" | "runtime";

};

export type AuthorityDecision = {

  execution_authorized: boolean;

  reason: string;

  confidence: number;

};

export function evaluateAuthority(context: AuthorityContext = {}): AuthorityDecision {

  const mode = context.mode ?? "diagnostic";

  if (mode === "diagnostic") {

    return {

      execution_authorized: true,

      reason: "diagnostic_mode_default_allow",

      confidence: 0.95

    };

  }

  if (mode === "simulation") {

    return {

      execution_authorized: true,

      reason: "simulation_mode_restricted_allow",

      confidence: 0.7

    };

  }

  return {

    execution_authorized: false,

    reason: "runtime_mode_not_integrated",

    confidence: 0.2

  };

}

