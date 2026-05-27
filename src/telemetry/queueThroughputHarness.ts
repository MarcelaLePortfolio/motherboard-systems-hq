/*
Phase 81.5 — Throughput Local Verification Harness

Purpose:
Local deterministic verification only.

Safety class:
TEST ONLY
NO RUNTIME USE
NO REDUCER USE
NO POLICY USE
NO AUTOMATION USE

This file must never be imported by runtime paths.
*/

import { computeQueueThroughput } from "./computeQueueThroughput"

function verify(label: string, completed: number, window: number, expected: number) {
  const result = computeQueueThroughput(completed, window)

  if (result !== expected) {
    throw new Error(
      "Throughput harness failure: " +
      label +
      " expected=" +
      expected +
      " got=" +
      result
    )
  }

  console.log("PASS:", label)
}

function runHarness() {

  verify(
    "baseline",
    10,
    5,
    2
  )

  verify(
    "high volume",
    120,
    10,
    12
  )

  verify(
    "zero completed",
    0,
    5,
    0
  )

  verify(
    "zero window",
    5,
    0,
    0
  )

  verify(
    "negative guard",
    -5,
    5,
    0
  )

  console.log("phase81.5 throughput harness verified")
}

runHarness()
