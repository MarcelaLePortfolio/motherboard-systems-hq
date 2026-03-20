import { computeQueueThroughput } from "./computeQueueThroughput"

function assertEqual(actual: number, expected: number, label: string) {
  if (actual !== expected) {
    throw new Error(
      `QueueThroughput test failed: ${label} | expected ${expected} got ${actual}`
    )
  }
}

function runQueueThroughputTests() {

  assertEqual(
    computeQueueThroughput(0,5),
    0,
    "zero completed"
  )

  assertEqual(
    computeQueueThroughput(10,5),
    2,
    "basic throughput"
  )

  assertEqual(
    computeQueueThroughput(25,5),
    5,
    "higher throughput"
  )

  assertEqual(
    computeQueueThroughput(50,10),
    5,
    "different window"
  )

  assertEqual(
    computeQueueThroughput(5,0),
    0,
    "zero window safeguard"
  )

  assertEqual(
    computeQueueThroughput(-1,5),
    0,
    "negative completed safeguard"
  )

  console.log("phase81.2 queue throughput tests passed")
}

runQueueThroughputTests()
