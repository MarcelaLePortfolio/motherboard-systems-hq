import React from 'react'
import { computeQueueLatency } from '../telemetry/queueLatency'

type QueueLatencyTask = {
  created_at?: string | null
  started_at?: string | null
}

type QueueLatencyCardProps = {
  tasks: QueueLatencyTask[]
  title?: string
}

function formatSeconds(value: number): string {
  if (!Number.isFinite(value) || value <= 0) return '0s'

  if (value < 60) {
    return `${value.toFixed(2)}s`
  }

  const minutes = Math.floor(value / 60)
  const seconds = value % 60

  return `${minutes}m ${seconds.toFixed(2)}s`
}

export default function QueueLatencyCard({
  tasks,
  title = 'Queue Latency',
}: QueueLatencyCardProps) {

  const stats = React.useMemo(() => {
    return computeQueueLatency(tasks || [])
  }, [tasks])

  return (
    <section
      aria-label="queue-latency-card"
      className="rounded-xl border border-white/10 bg-black/20 p-4"
    >

      <div className="mb-3 flex items-center justify-between">

        <h3 className="text-sm font-semibold tracking-wide">
          {title}
        </h3>

        <span className="text-xs opacity-70">
          Derived metric
        </span>

      </div>

      <div className="grid grid-cols-1 gap-3 sm:grid-cols-3">

        <div className="rounded-lg border border-white/10 bg-white/5 p-3">

          <div className="text-xs uppercase tracking-wide opacity-70">
            Average
          </div>

          <div className="mt-1 text-lg font-semibold">
            {formatSeconds(stats.avg)}
          </div>

        </div>

        <div className="rounded-lg border border-white/10 bg-white/5 p-3">

          <div className="text-xs uppercase tracking-wide opacity-70">
            P95
          </div>

          <div className="mt-1 text-lg font-semibold">
            {formatSeconds(stats.p95)}
          </div>

        </div>

        <div className="rounded-lg border border-white/10 bg-white/5 p-3">

          <div className="text-xs uppercase tracking-wide opacity-70">
            Max
          </div>

          <div className="mt-1 text-lg font-semibold">
            {formatSeconds(stats.max)}
          </div>

        </div>

      </div>

      <div className="mt-3 text-xs opacity-70">
        Sample size: {stats.sampleSize}
      </div>

    </section>
  )
}
