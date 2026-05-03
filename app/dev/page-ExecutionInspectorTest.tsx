'use client';

import ExecutionInspector from "../components/ExecutionInspector";

export default function Page() {
  const mockTask = {
    id: "test-task-001",
    status: "completed",
    guidance: {
      classification: "warning",
      outcome: "Task completed with minor issues.",
      explanation: "The task executed successfully but encountered a non-blocking warning during processing. No retry required."
    }
  };

  return (
    <div className="p-6">
      <ExecutionInspector task={mockTask} />
    </div>
  );
}
