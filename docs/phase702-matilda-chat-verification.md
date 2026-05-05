# Phase 702 Matilda Chat Verification

Generated: Tue May  5 10:14:11 PDT 2026

## Finding

The inspected surface `app/demo-runtime/page.tsx` is not a Matilda chat interface.
It is a governed runtime demo UI using an operator-request textarea and POSTing to `/api/demo-runtime`.

## Phase 702 Constraint

Do not label this surface as Matilda chat.
Do not mutate backend/runtime behavior.
Only patch UI wording if the current labels imply real execution beyond demo behavior.

## Remaining Inspection Needed

- Inspect the rest of `app/demo-runtime/page.tsx`.
- Inspect `app/api/demo-runtime/route.ts`.
- Continue searching for an actual Matilda chat UI or `/api/chat` route before applying any Matilda-specific UI label.

## app/demo-runtime/page.tsx remainder

```tsx
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
```

## app/api/demo-runtime/route.ts

```ts
import { NextRequest, NextResponse } from "next/server";
import { runMinimalDemoFromPrompt } from "@/src/demo/minimalDemoRunner";

type DemoRuntimeRequestBody = {
  prompt?: string;
  approved?: boolean;
  governanceEvaluated?: boolean;
  authorityOrderingValid?: boolean;
};

export async function POST(request: NextRequest) {
  try {
    const body = (await request.json()) as DemoRuntimeRequestBody;

    if (!body.prompt || !body.prompt.trim()) {
      return NextResponse.json(
        { error: "Prompt is required." },
        { status: 400 }
      );
    }

    const report = runMinimalDemoFromPrompt({
      prompt: body.prompt,
      approved: body.approved ?? true,
      governanceEvaluated: body.governanceEvaluated ?? true,
      authorityOrderingValid: body.authorityOrderingValid ?? true,
    });

    return NextResponse.json(report, { status: 200 });
  } catch (error) {
    const message =
      error instanceof Error ? error.message : "Unknown runtime demo error.";

    return NextResponse.json({ error: message }, { status: 500 });
  }
}
```
