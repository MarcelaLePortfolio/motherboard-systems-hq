# Phase 80.2 — Queue Latency Mount Discovery

- Generated at: 20260317T183232Z

## Candidate files

dashboard/src/components/index.ts
dashboard/src/components/QueueLatencyCard.tsx
dashboard/src/operator/runbooks/operatorRunbookCatalog.ts
dashboard/src/operator/runbooks/operatorRunbookFormatter.ts
dashboard/src/operator/runbooks/operatorRunbookResolver.ts
dashboard/src/operator/runbooks/operatorRunbookTypes.ts
dashboard/src/telemetry/index.ts
dashboard/src/telemetry/queueLatency.ts

## Files referencing telemetry/task concepts

dashboard/src/components/QueueLatencyCard.tsx:2:import { computeQueueLatency } from '../telemetry'
dashboard/src/components/QueueLatencyCard.tsx:9:type QueueLatencyCardProps = {
dashboard/src/components/QueueLatencyCard.tsx:10:  tasks?: QueueLatencyTask[]
dashboard/src/components/QueueLatencyCard.tsx:31:  tasks = [],
dashboard/src/components/QueueLatencyCard.tsx:33:}: QueueLatencyCardProps) {
dashboard/src/components/QueueLatencyCard.tsx:36:    return computeQueueLatency(tasks)
dashboard/src/components/QueueLatencyCard.tsx:37:  }, [tasks])
dashboard/src/telemetry/queueLatency.ts:9:- Pure derived telemetry
dashboard/src/telemetry/queueLatency.ts:28:export function computeQueueLatency(tasks: any[]): QueueLatencyStats {
dashboard/src/telemetry/queueLatency.ts:32:  for (const task of tasks) {
dashboard/src/telemetry/queueLatency.ts:34:    if (!task.created_at) continue
dashboard/src/telemetry/queueLatency.ts:35:    if (!task.started_at) continue
dashboard/src/telemetry/queueLatency.ts:37:    const created = new Date(task.created_at).getTime()
dashboard/src/telemetry/queueLatency.ts:38:    const started = new Date(task.started_at).getTime()
dashboard/src/operator/runbooks/operatorRunbookResolver.ts:1:import { RUNBOOK_CATALOG } from "./operatorRunbookCatalog";
dashboard/src/operator/runbooks/operatorRunbookResolver.ts:2:import type { Runbook } from "./operatorRunbookTypes";
dashboard/src/operator/runbooks/operatorRunbookFormatter.ts:1:import type { Runbook } from "./operatorRunbookTypes";
dashboard/src/operator/runbooks/operatorRunbookCatalog.ts:1:import type { Runbook } from "./operatorRunbookTypes";
dashboard/src/operator/runbooks/operatorRunbookCatalog.ts:53:    { id: "monitor", description: "Monitor telemetry" },

## Files already importing from components barrel


## Files already rendering cards/panels

dashboard/src/components/QueueLatencyCard.tsx:9:type QueueLatencyCardProps = {
dashboard/src/components/QueueLatencyCard.tsx:30:export default function QueueLatencyCard({
dashboard/src/components/QueueLatencyCard.tsx:33:}: QueueLatencyCardProps) {
dashboard/src/components/index.ts:1:export { default as QueueLatencyCard } from './QueueLatencyCard'
dashboard/src/telemetry/queueLatency.ts:2:Phase 80.2 — Queue Latency Telemetry
dashboard/src/telemetry/queueLatency.ts:12:export type QueueLatencyStats = {
dashboard/src/telemetry/queueLatency.ts:28:export function computeQueueLatency(tasks: any[]): QueueLatencyStats {
dashboard/src/telemetry/index.ts:2:export type { QueueLatencyStats } from './queueLatency'
dashboard/src/operator/runbooks/operatorRunbookTypes.ts:8:export type SystemStateClass =
dashboard/src/operator/runbooks/operatorRunbookTypes.ts:23:  state: SystemStateClass;
dashboard/src/operator/runbooks/operatorRunbookFormatter.ts:12:    `State: ${runbook.state}`,
dashboard/src/operator/runbooks/operatorRunbookCatalog.ts:19:  title: "Investigate Telemetry Drift",
