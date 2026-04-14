"use client";

import { useMemo, useState } from "react";

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

type SummaryBadgeProps = {
  label: string;
  value: string;
};

type GovernanceTraceRowProps = {
  label: string;
  value: string;
};

function SummaryBadge({ label, value }: SummaryBadgeProps) {
  return (
    <div
      style={{
        border: "1px solid #d9d9d9",
        borderRadius: "0.75rem",
        padding: "0.85rem 1rem",
        background: "#fff",
        minWidth: "180px",
      }}
    >
      <div
        style={{
          fontSize: "0.78rem",
          textTransform: "uppercase",
          letterSpacing: "0.06em",
          color: "#666",
          marginBottom: "0.35rem",
        }}
      >
        {label}
      </div>
      <div style={{ fontWeight: 700, fontSize: "1rem", color: "#111" }}>{value}</div>
    </div>
  );
}

function GovernanceTraceRow({ label, value }: GovernanceTraceRowProps) {
  return (
    <p style={{ marginTop: 0, marginBottom: "0.65rem", lineHeight: 1.6 }}>
      <strong>{label}:</strong> {value}
    </p>
  );
}

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

  const governanceExplanation = useMemo(() => {
    if (!report) {
      return "";
    }

    if (report.admissionDecision === "ADMITTED") {
      return "Request admitted because approval is present, governance evaluation is present, authority ordering is valid, and task structure passed integrity checks.";
    }

    if (report.denialReasons.length > 0) {
      return `Request denied because: ${report.denialReasons.join(", ")}.`;
    }

    return "Request denied because one or more governance admission conditions were not satisfied.";
  }, [report]);

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
    <main style={{ padding: "2rem", maxWidth: "1120px", margin: "0 auto" }}>
      <h1 style={{ marginBottom: "0.5rem", fontSize: "2rem" }}>Governed Runtime Demo</h1>
      <p style={{ marginBottom: "1.5rem", color: "#444", lineHeight: 1.5 }}>
        Enter a natural-language operator request and run it through the governed runtime
        pipeline. The result surface is organized around request, admission, execution,
        and outcome so the system can be understood quickly without code inspection.
      </p>

      <section
        style={{
          border: "1px solid #ddd",
          borderRadius: "0.9rem",
          padding: "1rem",
          background: "#fafafa",
          marginBottom: "1.5rem",
        }}
      >
        <label style={{ display: "block", fontWeight: 700, marginBottom: "0.5rem" }}>
          Operator Request
        </label>
        <textarea
          value={prompt}
          onChange={(event) => setPrompt(event.target.value)}
          rows={7}
          style={{
            width: "100%",
            padding: "0.85rem",
            borderRadius: "0.65rem",
            border: "1px solid #ccc",
            marginBottom: "1rem",
            fontFamily: "inherit",
            fontSize: "0.98rem",
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
            padding: "0.8rem 1rem",
            borderRadius: "0.6rem",
            border: "1px solid #111",
            background: "#111",
            color: "#fff",
            cursor: loading ? "not-allowed" : "pointer",
            fontWeight: 700,
          }}
        >
          {loading ? "Running…" : "Run governed demo"}
        </button>
      </section>

      {error ? (
        <div
          style={{
            padding: "0.85rem 1rem",
            borderRadius: "0.65rem",
            background: "#fee",
            color: "#900",
            marginBottom: "1rem",
            border: "1px solid #f3b7b7",
          }}
        >
          {error}
        </div>
      ) : null}

      {report ? (
        <section
          style={{
            border: "1px solid #ddd",
            borderRadius: "0.9rem",
            padding: "1.25rem",
            background: "#fff",
          }}
        >
          <h2 style={{ marginTop: 0, marginBottom: "1rem" }}>Runtime Result</h2>

          <div style={{ display: "flex", gap: "0.9rem", flexWrap: "wrap", marginBottom: "1.25rem" }}>
            <SummaryBadge label="Admission" value={report.admissionDecision} />
            <SummaryBadge label="Traversal" value={report.traversalState} />
            <SummaryBadge label="Final result" value={report.finalDemoResult} />
            <SummaryBadge label="Tasks" value={String(report.generatedRequest.tasks.length)} />
          </div>

          <div
            style={{
              border: "1px solid #e2e2e2",
              borderRadius: "0.75rem",
              padding: "1rem",
              marginBottom: "1rem",
              background: "#fafafa",
            }}
          >
            <h3 style={{ marginTop: 0, marginBottom: "0.65rem" }}>Governance Trace</h3>
            <GovernanceTraceRow label="Admission decision" value={report.admissionDecision} />
            <GovernanceTraceRow label="Approval present" value={report.generatedRequest.approved ? "YES" : "NO"} />
            <GovernanceTraceRow label="Governance evaluated" value={report.generatedRequest.governanceEvaluated ? "YES" : "NO"} />
            <GovernanceTraceRow label="Authority ordering valid" value={report.generatedRequest.authorityOrderingValid ? "YES" : "NO"} />
            <GovernanceTraceRow label="Rule-level trace" value="NO DATA" />
            <div style={{ marginTop: "0.9rem" }}>
              <strong>Denial reasons:</strong>
              {report.denialReasons.length > 0 ? (
                <ul style={{ marginTop: "0.5rem", marginBottom: 0 }}>
                  {report.denialReasons.map((reason) => (
                    <li key={reason}>{reason}</li>
                  ))}
                </ul>
              ) : (
                <p style={{ marginTop: "0.5rem", marginBottom: 0 }}>NONE</p>
              )}
            </div>
          </div>

          <div
            style={{
              border: "1px solid #e2e2e2",
              borderRadius: "0.75rem",
              padding: "1rem",
              marginBottom: "1rem",
              background: "#fafafa",
            }}
          >
            <h3 style={{ marginTop: 0, marginBottom: "0.65rem" }}>Request</h3>
            <p style={{ marginTop: 0, marginBottom: "0.75rem", lineHeight: 1.5 }}>
              <strong>Request ID:</strong> {report.requestId}
            </p>
            <div>
              <strong>Natural-language prompt:</strong>
              <div
                style={{
                  marginTop: "0.5rem",
                  padding: "0.85rem",
                  borderRadius: "0.65rem",
                  border: "1px solid #ddd",
                  background: "#fff",
                  whiteSpace: "pre-wrap",
                  lineHeight: 1.6,
                }}
              >
                {report.requestSummary}
              </div>
            </div>
          </div>

          <div
            style={{
              border: "1px solid #e2e2e2",
              borderRadius: "0.75rem",
              padding: "1rem",
              marginBottom: "1rem",
              background: "#fafafa",
            }}
          >
            <h3 style={{ marginTop: 0, marginBottom: "0.65rem" }}>Admission</h3>
            <GovernanceTraceRow label="Decision" value={report.admissionDecision} />
            <GovernanceTraceRow label="Approval present" value={report.generatedRequest.approved ? "YES" : "NO"} />
            <GovernanceTraceRow label="Governance evaluated" value={report.generatedRequest.governanceEvaluated ? "YES" : "NO"} />
            <GovernanceTraceRow label="Authority ordering valid" value={report.generatedRequest.authorityOrderingValid ? "YES" : "NO"} />
            <p style={{ marginBottom: 0, lineHeight: 1.6 }}>
              <strong>Governance explanation:</strong> {governanceExplanation}
            </p>
            {report.denialReasons.length > 0 ? (
              <>
                <h4 style={{ marginBottom: "0.5rem" }}>Denial reasons</h4>
                <ul style={{ marginTop: 0 }}>
                  {report.denialReasons.map((reason) => (
                    <li key={reason}>{reason}</li>
                  ))}
                </ul>
              </>
            ) : null}
          </div>

          <div
            style={{
              border: "1px solid #e2e2e2",
              borderRadius: "0.75rem",
              padding: "1rem",
              marginBottom: "1rem",
              background: "#fafafa",
            }}
          >
            <h3 style={{ marginTop: 0, marginBottom: "0.65rem" }}>Execution</h3>

            <p><strong>Traversal order:</strong></p>
            {report.traversalOrder.length > 0 ? (
              <ol>
                {report.traversalOrder.map((entry, idx) => (
                  <li key={idx}>{entry}</li>
                ))}
              </ol>
            ) : (
              <p>NO DATA</p>
            )}

            <p><strong>Task definitions:</strong></p>
            <ol>
              {report.generatedRequest.tasks.map((task) => (
                <li key={task.id}>
                  {task.id}: {task.name}
                </li>
              ))}
            </ol>
          </div>

          <div
            style={{
              border: "1px solid #e2e2e2",
              borderRadius: "0.75rem",
              padding: "1rem",
              marginBottom: "1rem",
              background: "#fafafa",
            }}
          >
            <h3 style={{ marginTop: 0, marginBottom: "0.65rem" }}>Outcome</h3>

            <p><strong>Final result:</strong> {report.finalDemoResult}</p>

            <ol style={{ marginTop: 0 }}>
              {report.taskOutcomes.map((task) => (
                <li key={`${task.taskId}-${task.logicalTimestamp}`}>
                  <strong>{task.taskName}</strong> — {task.outcome} ({task.logicalTimestamp})
                </li>
              ))}
            </ol>
          </div>

          <details>
            <summary style={{ cursor: "pointer", fontWeight: 700 }}>Raw report JSON</summary>
            <pre
              style={{
                overflowX: "auto",
                background: "#111",
                color: "#eee",
                padding: "1rem",
                borderRadius: "0.5rem",
                marginTop: "0.9rem",
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
