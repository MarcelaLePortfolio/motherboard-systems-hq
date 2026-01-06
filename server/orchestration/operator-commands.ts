import type { PolicyDecision, PolicyContext } from "./policy";

export type OperatorCommand =
  | { type: "mode.set"; mode: PolicyContext["operatorMode"] }
  | { type: "intent.set"; intent: string }
  | { type: "intent.clear" }
  | { type: "queue.pause" }
  | { type: "queue.resume" }
  | { type: "task.cancel"; id: string; reason?: string }
  | { type: "task.retry"; id: string }
  | { type: "budget.set"; scope: string; value: number };

const MODES: PolicyContext["operatorMode"][] = ["NORMAL", "SAFE", "FOCUS", "PAUSE", "DRAIN", "DEBUG"];

function isMode(x: string): x is PolicyContext["operatorMode"] {
  return (MODES as string[]).includes(x);
}

function splitTokens(input: string): string[] {
  return input.trim().split(/\s+/).filter(Boolean);
}

/**
 * Minimal operator command parser (Phase 17.5):
 * Supported:
 * - mode set <MODE>
 * - intent set <TEXT...>
 * - intent clear
 * - queue pause
 * - queue resume
 * - task cancel <id> [reason...]
 * - task retry <id>
 * - budget set <scope> <value>
 */
export function parseOperatorCommand(input: string): { ok: true; cmd: OperatorCommand } | { ok: false; error: string } {
  const s = input.trim();
  if (!s) return { ok: false, error: "empty command" };

  const toks = splitTokens(s);

  const head = toks[0]?.toLowerCase();
  const sub = toks[1]?.toLowerCase();

  if (head === "mode" && sub === "set") {
    const m = toks[2]?.toUpperCase();
    if (!m || !isMode(m)) return { ok: false, error: `invalid mode: ${toks[2] || ""}` };
    return { ok: true, cmd: { type: "mode.set", mode: m } };
  }

  if (head === "intent" && sub === "set") {
    const text = toks.slice(2).join(" ").trim();
    if (!text) return { ok: false, error: "intent set requires text" };
    return { ok: true, cmd: { type: "intent.set", intent: text } };
  }

  if (head === "intent" && sub === "clear") {
    return { ok: true, cmd: { type: "intent.clear" } };
  }

  if (head === "queue" && sub === "pause") {
    return { ok: true, cmd: { type: "queue.pause" } };
  }

  if (head === "queue" && sub === "resume") {
    return { ok: true, cmd: { type: "queue.resume" } };
  }

  if (head === "task" && sub === "cancel") {
    const id = toks[2];
    if (!id) return { ok: false, error: "task cancel requires id" };
    const reason = toks.slice(3).join(" ").trim() || undefined;
    return { ok: true, cmd: { type: "task.cancel", id, reason } };
  }

  if (head === "task" && sub === "retry") {
    const id = toks[2];
    if (!id) return { ok: false, error: "task retry requires id" };
    return { ok: true, cmd: { type: "task.retry", id } };
  }

  if (head === "budget" && sub === "set") {
    const scope = toks[2];
    const valueRaw = toks[3];
    if (!scope || !valueRaw) return { ok: false, error: "budget set requires <scope> <value>" };
    const value = Number(valueRaw);
    if (!Number.isFinite(value)) return { ok: false, error: `invalid value: ${valueRaw}` };
    return { ok: true, cmd: { type: "budget.set", scope, value } };
  }

  return { ok: false, error: "unknown command" };
}

/**
 * Convert a parsed OperatorCommand into PolicyDecisions (pure).
 * Phase 17.5 only updates ctx-level mode/intent. Task ops become events for later wiring.
 */
export function commandToDecisions(cmd: OperatorCommand): PolicyDecision[] {
  switch (cmd.type) {
    case "mode.set":
      return [{ kind: "set_mode", mode: cmd.mode }];
    case "intent.set":
      return [{ kind: "set_intent", intent: cmd.intent }];
    case "intent.clear":
      return [{ kind: "set_intent", intent: null }];
    case "queue.pause":
      return [{ kind: "set_mode", mode: "PAUSE" }];
    case "queue.resume":
      return [{ kind: "set_mode", mode: "NORMAL" }];
    case "task.cancel":
      return [
        {
          kind: "emit",
          events: [
            {
              type: "event.ingested",
              ts: Date.now(),
              source: "operator",
              payload: { op: "task.cancel", id: cmd.id, reason: cmd.reason || null },
            },
          ],
        },
      ];
    case "task.retry":
      return [
        {
          kind: "emit",
          events: [
            {
              type: "event.ingested",
              ts: Date.now(),
              source: "operator",
              payload: { op: "task.retry", id: cmd.id },
            },
          ],
        },
      ];
    case "budget.set":
      return [
        {
          kind: "emit",
          events: [
            {
              type: "event.ingested",
              ts: Date.now(),
              source: "operator",
              payload: { op: "budget.set", scope: cmd.scope, value: cmd.value },
            },
          ],
        },
      ];
    default: {
      const _exhaustive: never = cmd;
      return _exhaustive;
    }
  }
}
