/*
Phase 80.2 — Queue Latency Telemetry
Safe iteration metric (cognition-only)

Rules:
- No reducer mutation
- No authority change
- No behavior change
- Pure derived telemetry
*/

export type QueueLatencyStats = {
  avg: number
  p95: number
  max: number
  sampleSize: number
}

function percentile(values: number[], p: number): number {
  if (values.length === 0) return 0

  const sorted = [...values].sort((a,b)=>a-b)
  const idx = Math.floor(sorted.length * p)

  return sorted[Math.min(idx, sorted.length-1)]
}

export function computeQueueLatency(tasks: any[]): QueueLatencyStats {

  const latencies:number[] = []

  for (const task of tasks) {

    if (!task.created_at) continue
    if (!task.started_at) continue

    const created = new Date(task.created_at).getTime()
    const started = new Date(task.started_at).getTime()

    if (isNaN(created) || isNaN(started)) continue

    const seconds = Math.max(0,(started - created)/1000)

    latencies.push(seconds)
  }

  if (latencies.length === 0){
    return {
      avg:0,
      p95:0,
      max:0,
      sampleSize:0
    }
  }

  const sum = latencies.reduce((a,b)=>a+b,0)

  return {

    avg: Number((sum / latencies.length).toFixed(2)),

    p95: Number(percentile(latencies,0.95).toFixed(2)),

    max: Number(Math.max(...latencies).toFixed(2)),

    sampleSize: latencies.length
  }
}
