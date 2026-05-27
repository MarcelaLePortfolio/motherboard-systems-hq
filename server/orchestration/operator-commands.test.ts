import test from "node:test";
import assert from "node:assert/strict";
import { parseOperatorCommand, commandToDecisions } from "./operator-commands";

test("parse: mode set", () => {
  const r = parseOperatorCommand("mode set SAFE");
  assert.equal(r.ok, true);
  if (r.ok) assert.equal(r.cmd.type, "mode.set");
});

test("parse: intent set", () => {
  const r = parseOperatorCommand("intent set focus phase17");
  assert.equal(r.ok, true);
  if (r.ok && r.cmd.type === "intent.set") assert.equal(r.cmd.intent, "focus phase17");
});

test("parse: queue pause/resume", () => {
  const a = parseOperatorCommand("queue pause");
  const b = parseOperatorCommand("queue resume");
  assert.equal(a.ok, true);
  assert.equal(b.ok, true);
});

test("parse: task cancel includes id and optional reason", () => {
  const r = parseOperatorCommand("task cancel t123 because testing");
  assert.equal(r.ok, true);
  if (r.ok && r.cmd.type === "task.cancel") {
    assert.equal(r.cmd.id, "t123");
    assert.equal(r.cmd.reason, "because testing");
  }
});

test("decisions: queue pause -> set_mode PAUSE", () => {
  const r = parseOperatorCommand("queue pause");
  assert.equal(r.ok, true);
  if (!r.ok) return;
  const d = commandToDecisions(r.cmd);
  assert.equal(d[0].kind, "set_mode");
  // @ts-expect-error
  assert.equal(d[0].mode, "PAUSE");
});
