"use client";

import { useState } from "react";

type TaskExecutionRecord = {
  taskId: string;
  taskName: string;
  traversalPosition: number;
  outcome: "SUCCESS" | "FAILED" | "BLOCKED";
  verificationConfirmed: boolean;
  logicalTimestamp: string;
};

type DemoReport = {
  requestId: string;
  requestSummary: string;
  generatedRequest: {
    approved: boolean;
    governanceEvaluated: boolean;
    authorityOrderingValid: boolean;
    tasks: { id: string; name: string }[];
  };
  admissionDecision: "ADMITTED" | "DENIED";
  denialReasons: string[];
  traversalOrder: string[];
  traversalState: "NOT_STARTED" | "IN_PROGRESS" | "COMPLETED" | "BLOCKED";
  taskOutcomes: TaskExecutionRecord[];
  finalDemoResult: "DEMO_SUCCESS" | "DEMO_FAILED";
};

export default function DemoRuntimePage() {
  const [prompt, setPrompt] = useState(
    "Create a project to evaluate deployment readiness for a new service. Include three tasks: dependency verification, governance review, and execution readiness assessment. Require approval before any execution preparation."
  );
  const [approved, setApproved] = useState(true);
  const [governanceEvaluated, setGovernanceEvaluated] = useState(true);
  const [authorityOrderingValid, setAuthorityOrderingValid] = useState(true);
  const [loading, setLoading] = useState(false);
  const [report, setReport] = useState<DemoReport | null>(null);
  const [error, setError] = useState<string>("");

  async function runDemo() {
    setLoading(true);
    setError("");
    setReport(null);

    try {
      const response = await fetch("/api/demo-runtime", {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
        },
        body: JSON.stringify({
          prompt,
          approved,
          governanceEvaluated,
          authorityOrderingValid,
        }),
      });

      const data = (await response.json()) as DemoReport | { error: string };

      if (!response.ok) {
        throw new Error("error" in data ? data.error : "Demo runtime failed.");
      }

      setReport(data as DemoReport);
    } catch (err) {
      setError(err instanceof Error ? err.message : "Unknown dashboard error.");
    } finally {
      setLoading(false);
    }
  }

  return (
    <main style={{ padding: "2rem", maxWidth: "1100px", margin: "0 auto" }}>
      <h1 style={{ marginBottom: "0.5rem" }}>Governed Runtime Demo</h1>
      <p style={{ marginBottom: "1.5rem" }}>
        Enter a natural-language operator request and run it through the governed
        execution demo pipeline.
      </p>

      <label style={{ display: "block", fontWeight: 600, marginBottom: "0.5rem" }}>
        Operator Request
      </label>
      <textarea
        value={prompt}
        onChange={(event) => setPrompt(event.target.value)}
        rows={7}
        style={{
          width: "100%",
          padding: "0.75rem",
          borderRadius: "0.5rem",
          border: "1px solid #ccc",
          marginBottom: "1rem",
          fontFamily: "inherit",
        }}
      />

      <div style={{ display: "flex", gap: "1.25rem", marginBottom: "1rem", flexWrap: "wrap" }}>
        <label>
          <input
            type="checkbox"
            checked={approved}
            onChange={(event) => setApproved(event.target.checked)}
            style={{ marginRight: "0.5rem" }}
          />
          Approved
        </label>
        <label>
          <input
            type="checkbox"
            checked={governanceEvaluated}
            onChange={(event) => setGovernanceEvaluated(event.target.checked)}
            style={{ marginRight: "0.5rem" }}
          />
          Governance evaluated
        </label>
        <label>
          <input
            type="checkbox"
            checked={authorityOrderingValid}
            onChange={(event) => setAuthorityOrderingValid(event.target.checked)}
            style={{ marginRight: "0.5rem" }}
          />
          Authority ordering valid
        </label>
      </div>

      <button
        onClick={runDemo}
        disabled={loading}
        style={{
          padding: "0.75rem 1rem",
          borderRadius: "0.5rem",
          border: "1px solid #111",
          background: "#111",
          color: "#fff",
          cursor: loading ? "not-allowed" : "pointer",
          marginBottom: "1.5rem",
        }}
      >
        {loading ? "Running…" : "Run governed demo"}
      </button>

      {error ? (
        <div
          style={{
            padding: "0.75rem 1rem",
            borderRadius: "0.5rem",
            background: "#fee",
            color: "#900",
            marginBottom: "1rem",
          }}
        >
          {error}
        </div>
      ) : null}

      {report ? (
        <section
          style={{
            border: "1px solid #ddd",
            borderRadius: "0.75rem",
            padding: "1rem",
            background: "#fafafa",
          }}
        >
          <h2 style={{ marginTop: 0 }}>Runtime Result</h2>
          <p>
            <strong>Request ID:</strong> {report.requestId}
          </p>
          <p>
            <strong>Admission:</strong> {report.admissionDecision}
          </p>
          <p>
            <strong>Traversal State:</strong> {report.traversalState}
          </p>
          <p>
            <strong>Final Result:</strong> {report.finalDemoResult}
          </p>

          {report.denialReasons.length > 0 ? (
            <>
              <h3>Denial Reasons</h3>
              <ul>
                {report.denialReasons.map((reason) => (
                  <li key={reason}>{reason}</li>
                ))}
              </ul>
            </>
          ) : null}

          <h3>Generated Tasks</h3>
          <ol>
            {report.generatedRequest.tasks.map((task) => (
              <li key={task.id}>
                {task.id}: {task.name}
              </li>
            ))}
          </ol>

          <h3>Task Outcomes</h3>
          <ol>
            {report.taskOutcomes.map((task) => (
              <li key={`${task.taskId}-${task.logicalTimestamp}`}>
                {task.taskName} — {task.outcome} ({task.logicalTimestamp})
              </li>
            ))}
          </ol>

          <details style={{ marginTop: "1rem" }}>
            <summary>Raw report JSON</summary>
            <pre
              style={{
                overflowX: "auto",
                background: "#111",
                color: "#eee",
                padding: "1rem",
                borderRadius: "0.5rem",
              }}
            >
              {JSON.stringify(report, null, 2)}
            </pre>
          </details>
        </section>
      ) : null}
    </main>
  );
}
