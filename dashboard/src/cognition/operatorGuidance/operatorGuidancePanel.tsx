import type { OperatorGuidanceEnvelope } from "./operatorGuidance";

export interface OperatorGuidancePanelProps {
  envelope: OperatorGuidanceEnvelope;
}

function formatUpdatedAt(updatedAt: string | null): string {
  if (!updatedAt) {
    return "Not updated";
  }

  const date = new Date(updatedAt);

  if (Number.isNaN(date.getTime())) {
    return "Invalid timestamp";
  }

  return date.toLocaleString();
}

export function OperatorGuidancePanel({
  envelope,
}: OperatorGuidancePanelProps) {
  return (
    <section
      aria-label="Operator guidance"
      data-testid="operator-guidance-panel"
      className="rounded-lg border border-neutral-800 bg-neutral-950 p-4"
    >
      <header className="mb-3">
        <div className="flex items-center justify-between gap-3">
          <h2 className="text-sm font-semibold text-neutral-100">
            {envelope.title}
          </h2>
          <span
            data-confidence={envelope.confidence}
            className="rounded border border-neutral-700 px-2 py-1 text-xs uppercase tracking-wide text-neutral-300"
          >
            {envelope.confidence}
          </span>
        </div>
        <p className="mt-1 text-xs text-neutral-500">
          Updated: {formatUpdatedAt(envelope.updatedAt)}
        </p>
      </header>

      <div className="space-y-3">
        <div>
          <h3 className="mb-1 text-xs font-medium uppercase tracking-wide text-neutral-400">
            Guidance
          </h3>
          <p className="text-sm leading-6 text-neutral-200">
            {envelope.summary}
          </p>
        </div>

        <div>
          <h3 className="mb-1 text-xs font-medium uppercase tracking-wide text-neutral-400">
            Provenance
          </h3>
          {envelope.sources.length > 0 ? (
            <ul className="list-disc space-y-1 pl-5 text-sm text-neutral-300">
              {envelope.sources.map((source) => (
                <li key={source}>{source}</li>
              ))}
            </ul>
          ) : (
            <p className="text-sm text-neutral-500">No signal sources available.</p>
          )}
        </div>
      </div>
    </section>
  );
}

export default OperatorGuidancePanel;
