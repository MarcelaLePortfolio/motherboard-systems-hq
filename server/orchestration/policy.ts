export type OrchestrationEvent =
  | { type: "event.ingested"; ts: number; source: string; payload?: unknown }
  | { type: "task.transition"; ts: number; taskId: string; from: string; to: string; reason?: string };

export type PolicyContext = {
  now: number;
  operatorMode: "NORMAL" | "SAFE" | "FOCUS" | "PAUSE" | "DRAIN" | "DEBUG";
  intent: string | null;
};

export type PolicyDecision =
  | { kind: "noop" }
  | { kind: "emit"; events: OrchestrationEvent[] }
  | { kind: "set_mode"; mode: PolicyContext["operatorMode"] }
  | { kind: "set_intent"; intent: string | null };

export type Policy = {
  id: string;
  apply: (ctx: PolicyContext, ev: OrchestrationEvent) => PolicyDecision[];
};
