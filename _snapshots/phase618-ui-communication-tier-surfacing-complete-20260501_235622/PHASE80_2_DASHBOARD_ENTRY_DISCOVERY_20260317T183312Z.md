# Phase 80.2 — Dashboard Entry Discovery

Generated: 20260317T183312Z

## Possible app roots


## Files exporting React components

dashboard/src/components/QueueLatencyCard.tsx:30:export default function QueueLatencyCard({

## Files using task data

dashboard/src/components/QueueLatencyCard.tsx:10:  tasks?: QueueLatencyTask[]
dashboard/src/components/QueueLatencyCard.tsx:31:  tasks = [],
dashboard/src/components/QueueLatencyCard.tsx:36:    return computeQueueLatency(tasks)
dashboard/src/components/QueueLatencyCard.tsx:37:  }, [tasks])
dashboard/src/telemetry/queueLatency.ts:28:export function computeQueueLatency(tasks: any[]): QueueLatencyStats {
dashboard/src/telemetry/queueLatency.ts:32:  for (const task of tasks) {

## Any existing telemetry display

