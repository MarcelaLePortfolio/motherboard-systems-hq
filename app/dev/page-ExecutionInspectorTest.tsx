'use client';

import ExecutionInspector from "../components/ExecutionInspector";

export default function Page() {
  const mockTask = {
    id: "test-task-001",
    status: "completed",
    guidance: {
      classification: "success",
      outcome: "Task completed successfully.",
      explanation: "Execution finished without errors. No retry or intervention required."
    }
  };

  return (
    <div className="p-6 space-y-6">
      <div className="text-lg font-semibold">Execution Inspector — Guidance Test</div>

      <ExecutionInspector task={mockTask} />

      <ExecutionInspector
        task={{
          id: "test-task-002",
          status: "completed",
          guidance: {
            classification: "blocked",
            outcome: "Task failed due to dependency issue.",
            explanation: "Upstream dependency did not resolve. Manual retry recommended after fixing dependency."
          }
        }}
      />
    </div>
  );
}
