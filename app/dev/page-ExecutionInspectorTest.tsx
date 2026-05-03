'use client';

import ExecutionInspector from "../components/ExecutionInspector";

export default function Page() {
  return (
    <div className="p-6 space-y-6">
      <div className="text-lg font-semibold">Execution Inspector — Guidance Test (UI Verified)</div>

      <ExecutionInspector
        task={{
          id: "live-task-001",
          status: "completed",
          guidance: {
            classification: "success",
            outcome: "Execution pipeline completed cleanly.",
            explanation: "All stages (DB → Worker → SSE) executed without error. No retry or intervention required."
          }
        }}
      />

      <ExecutionInspector
        task={{
          id: "live-task-002",
          status: "completed",
          guidance: {
            classification: "warning",
            outcome: "Execution completed with advisory signal.",
            explanation: "Non-blocking anomaly detected in communication layer. Monitoring recommended but no action required."
          }
        }}
      />

      <ExecutionInspector
        task={{
          id: "live-task-003",
          status: "failed",
          guidance: {
            classification: "blocked",
            outcome: "Execution halted due to upstream failure.",
            explanation: "Dependency did not resolve. Retry should only occur after upstream fix is confirmed."
          }
        }}
      />

      <ExecutionInspector
        task={{
          id: "live-task-004",
          status: "completed"
        }}
      />
    </div>
  );
}
