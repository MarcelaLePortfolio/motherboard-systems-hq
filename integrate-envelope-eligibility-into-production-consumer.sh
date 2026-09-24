#!/usr/bin/env bash
set -euo pipefail

BRANCH="feature/support-source-references-runtime"
EXPECTED_HEAD="755092706"

git fetch origin "$BRANCH"
test "$(git rev-parse --abbrev-ref HEAD)" = "$BRANCH"
test "$(git rev-parse --short=9 HEAD)" = "$EXPECTED_HEAD"
test "$(git rev-parse --short=9 "origin/$BRANCH")" = "$EXPECTED_HEAD"

CONSUMER="server/envelope/production-envelope-consumer.ts"
TEST="server/envelope/production-envelope-consumer.test.ts"

test -f "$CONSUMER"
test -f "$TEST"

cp "$CONSUMER" /tmp/production-envelope-consumer.ts.before
cp "$TEST" /tmp/production-envelope-consumer.test.ts.before

cat > /tmp/inspect-envelope-consumer.sh << 'SH'
#!/usr/bin/env bash
set -euo pipefail
printf '\n=== CURRENT PRODUCTION ENVELOPE CONSUMER ===\n'
sed -n '1,240p' server/envelope/production-envelope-consumer.ts
printf '\n=== CURRENT PRODUCTION ENVELOPE CONSUMER TEST ===\n'
sed -n '1,320p' server/envelope/production-envelope-consumer.test.ts
SH
chmod +x /tmp/inspect-envelope-consumer.sh
/tmp/inspect-envelope-consumer.sh

python3 << 'PY'
from pathlib import Path

consumer_path = Path("server/envelope/production-envelope-consumer.ts")
text = consumer_path.read_text()

old_import_anchor = '''import {
  type CreateGovernanceEnvelopeInput,
'''
if old_import_anchor not in text:
    raise SystemExit("Expected CreateGovernanceEnvelopeInput import anchor not found.")

read_import = '''import {
  createGovernanceEnvelopeCreationReadLoader,
  type GovernanceEnvelopeCreationReadLoader,
} from "../../db/governance-envelope-creation-read-repository.js";

import {
  resolveGovernanceEnvelopeSemantics,
} from "./governance-envelope-semantics.js";

'''

text = text.replace(old_import_anchor, read_import + old_import_anchor, 1)

type_anchor = '''export type ProductionEnvelopeConsumerInput = Omit<
'''
if type_anchor not in text:
    raise SystemExit("ProductionEnvelopeConsumerInput anchor not found.")

type_block_end = '''>;

'''
idx = text.find(type_anchor)
end = text.find(type_block_end, idx)
if end == -1:
    raise SystemExit("ProductionEnvelopeConsumerInput type end not found.")
end += len(type_block_end)

input_extension = '''export type ProductionEnvelopeConsumerOptions = {
  load_exact_governance_envelope_creation_read_chain?: GovernanceEnvelopeCreationReadLoader;
};

'''
text = text[:end] + input_extension + text[end:]

fn_anchor = '''export function consumeProductionEnvelopeEntryPoint(
'''
if fn_anchor not in text:
    raise SystemExit("consumeProductionEnvelopeEntryPoint function anchor not found.")

sig_old = '''export function consumeProductionEnvelopeEntryPoint(
  input: ProductionEnvelopeConsumerInput,
): ProductionEnvelopeConsumerResult {
'''
sig_new = '''export function consumeProductionEnvelopeEntryPoint(
  input: ProductionEnvelopeConsumerInput,
  options: ProductionEnvelopeConsumerOptions = {},
): ProductionEnvelopeConsumerResult {
'''
if sig_old not in text:
    raise SystemExit("Exact consumer function signature not found.")
text = text.replace(sig_old, sig_new, 1)

invoke_anchor = '''  return invokeProductionEnvelopeEntryPoint({
'''
if invoke_anchor not in text:
    raise SystemExit("Envelope entry point invocation anchor not found.")

integration = '''  let readChain;
  let semantics;

  try {
    const loadExactEnvelopeCreationReadChain =
      options.load_exact_governance_envelope_creation_read_chain ??
      createGovernanceEnvelopeCreationReadLoader();

    readChain = loadExactEnvelopeCreationReadChain({
      validation_result_id: input.validation_result_id,
      envelope_gate_id: input.envelope_gate_id,
      delegation_id: input.delegation_id,
      package_id: input.package_id,
      package_version: input.package_version,
    });

    if (readChain.validation_result.validation_status.trim() !== "VALIDATION_PASSED") {
      throw new Error(
        "Production Envelope Consumer requires exact VALIDATION_PASSED status.",
      );
    }

    if (readChain.envelope_gate.gate_status.trim() !== "OPEN") {
      throw new Error(
        "Production Envelope Consumer requires exact OPEN Envelope Gate status.",
      );
    }

    semantics = resolveGovernanceEnvelopeSemantics(
      readChain.validation_result,
    );
  } catch (error) {
    return failedClosed([
      `Production Envelope eligibility failed closed: ${
        error instanceof Error ? error.message : String(error)
      }`,
    ]);
  }

'''
text = text.replace(invoke_anchor, integration + invoke_anchor, 1)

text = text.replace(
    '''    required_capabilities: input.required_capabilities,
''',
    '''    required_capabilities: semantics.required_capabilities,
''',
    1,
)
text = text.replace(
    '''    operational_corridor: input.operational_corridor,
''',
    '''    operational_corridor: semantics.operational_corridor,
''',
    1,
)

consumer_path.write_text(text)
PY

cat > "$TEST" << 'TS'
import test from "node:test";
import assert from "node:assert/strict";

import {
  consumeProductionEnvelopeEntryPoint,
} from "./production-envelope-consumer.js";

const baseInput = {
  envelope_id: "envelope-1",
  package_id: "package-1",
  package_version: 1,
  delegation_id: "delegation-1",
  validation_result_id: "validation-1",
  envelope_gate_id: "gate-1",
  validation_status: "VALIDATION_PASSED",
  required_capabilities: "caller-value-must-not-win",
  operational_corridor: "caller-value-must-not-win",
  lifecycle_state: "ENVELOPE_CREATED",
};

const exactReadChain = {
  validation_result: {
    validation_result_id: "validation-1",
    package_id: "package-1",
    package_version: 1,
    delegation_id: "delegation-1",
    validation_status: "VALIDATION_PASSED",
    governance_findings: null,
    operational_requirements: " planning_only ",
    capability_requirements: " engineering_planning ",
    escalations: null,
    validation_timestamp: "2026-09-24T00:00:00.000Z",
    created_at: "2026-09-24T00:00:00.000Z",
  },
  envelope_gate: {
    envelope_gate_id: "gate-1",
    package_id: "package-1",
    package_version: 1,
    delegation_id: "delegation-1",
    validation_result_id: "validation-1",
    gate_status: "OPEN",
    gate_reason: null,
    gate_decision_timestamp: "2026-09-24T00:01:00.000Z",
    created_at: "2026-09-24T00:01:00.000Z",
  },
};

test("uses exact persisted Validation and Gate lineage and authoritative semantics", () => {
  let persistedInput: Record<string, unknown> | undefined;

  const result = consumeProductionEnvelopeEntryPoint(
    {
      ...baseInput,
      create_governance_envelope: (input) => {
        persistedInput = input;
        return {
          ...input,
          created_at: "2026-09-24T00:02:00.000Z",
        };
      },
    },
    {
      load_exact_governance_envelope_creation_read_chain: () => exactReadChain,
    },
  );

  assert.equal(result.ok, true);
  assert.equal(persistedInput?.required_capabilities, "engineering_planning");
  assert.equal(persistedInput?.operational_corridor, "planning_only");
  assert.notEqual(
    persistedInput?.required_capabilities,
    baseInput.required_capabilities,
  );
  assert.notEqual(
    persistedInput?.operational_corridor,
    baseInput.operational_corridor,
  );

  if (result.ok) {
    assert.equal(result.scheduler_authorized, false);
    assert.equal(result.worker_claim_authorized, false);
    assert.equal(result.orchestration_authorized, false);
    assert.equal(result.routing_authorized, false);
    assert.equal(result.assignment_authorized, false);
    assert.equal(result.lifecycle_transition_authorized, false);
    assert.equal(result.execution_authorized, false);
    assert.equal(result.downstream_governance_authorized, false);
    assert.equal(result.new_authority_introduced, false);
  }
});

test("fails closed when exact Validation is not VALIDATION_PASSED", () => {
  const result = consumeProductionEnvelopeEntryPoint(
    {
      ...baseInput,
      create_governance_envelope: () => {
        throw new Error("persistence must not run");
      },
    },
    {
      load_exact_governance_envelope_creation_read_chain: () => ({
        ...exactReadChain,
        validation_result: {
          ...exactReadChain.validation_result,
          validation_status: "RESOLUTION_REQUIRED",
        },
      }),
    },
  );

  assert.equal(result.ok, false);
  assert.match(result.findings[0], /VALIDATION_PASSED/);
});

test("fails closed when exact Envelope Gate is not OPEN", () => {
  const result = consumeProductionEnvelopeEntryPoint(
    {
      ...baseInput,
      create_governance_envelope: () => {
        throw new Error("persistence must not run");
      },
    },
    {
      load_exact_governance_envelope_creation_read_chain: () => ({
        ...exactReadChain,
        envelope_gate: {
          ...exactReadChain.envelope_gate,
          gate_status: "CLOSED",
        },
      }),
    },
  );

  assert.equal(result.ok, false);
  assert.match(result.findings[0], /OPEN Envelope Gate/);
});

test("fails closed when authoritative capability semantics are missing", () => {
  const result = consumeProductionEnvelopeEntryPoint(
    {
      ...baseInput,
      create_governance_envelope: () => {
        throw new Error("persistence must not run");
      },
    },
    {
      load_exact_governance_envelope_creation_read_chain: () => ({
        ...exactReadChain,
        validation_result: {
          ...exactReadChain.validation_result,
          capability_requirements: " ",
        },
      }),
    },
  );

  assert.equal(result.ok, false);
  assert.match(result.findings[0], /capability_requirements/);
});

test("fails closed when authoritative operational semantics are missing", () => {
  const result = consumeProductionEnvelopeEntryPoint(
    {
      ...baseInput,
      create_governance_envelope: () => {
        throw new Error("persistence must not run");
      },
    },
    {
      load_exact_governance_envelope_creation_read_chain: () => ({
        ...exactReadChain,
        validation_result: {
          ...exactReadChain.validation_result,
          operational_requirements: null,
        },
      }),
    },
  );

  assert.equal(result.ok, false);
  assert.match(result.findings[0], /operational_requirements/);
});
TS

git diff --check -- "$CONSUMER" "$TEST"
npm run check
./node_modules/.bin/tsx --test \
  db/governance-envelope-creation-read-repository.test.ts \
  server/envelope/governance-envelope-semantics.test.ts \
  "$TEST"

git add -- "$CONSUMER" "$TEST"
test "$(git diff --cached --name-only | wc -l | tr -d ' ')" = "2"
git diff --cached --name-only | grep -Fxq "$CONSUMER"
git diff --cached --name-only | grep -Fxq "$TEST"

git commit -m "Integrate Envelope eligibility into production consumer"
git push origin "$BRANCH"
git fetch origin "$BRANCH"
test "$(git rev-parse HEAD)" = "$(git rev-parse "origin/$BRANCH")"
