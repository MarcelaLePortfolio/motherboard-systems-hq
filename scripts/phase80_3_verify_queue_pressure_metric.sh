#!/usr/bin/env bash
set -euo pipefail

echo "Phase 80.3 — Queue Pressure Metric Local Verification"

node -e "
const { computeQueuePressure } = require('../dist/telemetry/computeQueuePressure')

function assertEqual(actual, expected, label){
  if(actual !== expected){
    throw new Error('FAIL: ' + label + ' expected ' + expected + ' got ' + actual)
  }
}

assertEqual(computeQueuePressure(0,10),0,'zero running')
assertEqual(computeQueuePressure(5,10),0.5,'half capacity')
assertEqual(computeQueuePressure(10,10),1,'full capacity')
assertEqual(computeQueuePressure(12,10),1.2,'over capacity')
assertEqual(computeQueuePressure(5,0),0,'zero capacity')
assertEqual(computeQueuePressure(-1,10),0,'negative running')

console.log('Phase 80.3 verification PASSED')
"

echo "Queue Pressure metric verified locally"
