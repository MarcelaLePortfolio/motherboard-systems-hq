import { computeQueuePressure } from "./computeQueuePressure"

function assertEqual(actual: number, expected: number, label: string) {
  if (actual !== expected) {
    throw new Error(
      `QueuePressure test failed: ${label} | expected ${expected} got ${actual}`
    )
  }
}

function runQueuePressureTests() {

  assertEqual(
    computeQueuePressure(0,10),
    0,
    "0 running"
  )

  assertEqual(
    computeQueuePressure(5,10),
    0.5,
    "half capacity"
  )

  assertEqual(
    computeQueuePressure(10,10),
    1,
    "full capacity"
  )

  assertEqual(
    computeQueuePressure(12,10),
    1.2,
    "over capacity"
  )

  assertEqual(
    computeQueuePressure(5,0),
    0,
    "zero capacity safe guard"
  )

  assertEqual(
    computeQueuePressure(-1,10),
    0,
    "negative running safe guard"
  )

  console.log("phase80.3 queue pressure tests passed")
}

runQueuePressureTests()
