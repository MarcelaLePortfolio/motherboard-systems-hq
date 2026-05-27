/*
PHASE 77 — SIGNAL SEVERITY MODEL SMOKE
Verifies deterministic severity mapping.
*/

import { getSignalSeverity } from "./phase77_signal_severity_model";

function assert(condition: boolean, message: string) {
  if (!condition) {
    console.error("FAIL:", message);
    process.exit(1);
  }
}

function testNoSignals() {
  const result = getSignalSeverity({});

  assert(result.overallSeverity === "NONE", "Expected NONE overall severity");
  assert(result.replayDrift === "NONE", "Expected NONE replay drift severity");
  assert(result.healthAnomaly === "NONE", "Expected NONE health anomaly severity");
}

function testSingleSignalHigh() {
  const result = getSignalSeverity({
    replayDrift: true
  });

  assert(result.replayDrift === "HIGH", "Expected HIGH replay drift severity");
  assert(result.overallSeverity === "HIGH", "Expected HIGH overall severity");
}

function testMultipleSignalsHigh() {
  const result = getSignalSeverity({
    telemetryGap: true,
    diagnosticsFailure: true
  });

  assert(result.telemetryGap === "HIGH", "Expected HIGH telemetry gap severity");
  assert(result.diagnosticsFailure === "HIGH", "Expected HIGH diagnostics failure severity");
  assert(result.overallSeverity === "HIGH", "Expected HIGH overall severity");
}

function run() {
  testNoSignals();
  testSingleSignalHigh();
  testMultipleSignalsHigh();

  console.log("PHASE 77 SIGNAL SEVERITY SMOKE PASS");
}

run();
