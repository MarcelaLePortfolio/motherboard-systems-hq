import type { OperatorGuidanceRenderModel } from "./operatorGuidance";

export interface OperatorGuidancePanelProps {
  model: OperatorGuidanceRenderModel;
}

export function OperatorGuidancePanel({
  model,
}: OperatorGuidancePanelProps) {
  return (
    <section
      aria-label="Operator guidance"
      data-testid="operator-guidance-panel"
      className="rounded-lg border border-neutral-800 bg-neutral-950 p-4"
    >
      <header className="mb-4">
        <div className="flex items-center justify-between gap-3">
          <h2 className="text-sm font-semibold text-neutral-100">
            {model.title}
          </h2>
          <span
            data-confidence={model.surfaceConfidence}
            className="rounded border border-neutral-700 px-2 py-1 text-xs uppercase tracking-wide text-neutral-300"
          >
            {model.surfaceConfidence}
          </span>
        </div>
        <div className="mt-2 space-y-1 text-xs text-neutral-500">
          <p>Generated: {model.generatedAtLabel}</p>
          <p>Source: {model.source}</p>
          <p>Signals: {model.signalCount}</p>
          <p>
            Conflicts: {model.conflictingSignals ? "present" : "none detected"}
          </p>
        </div>
      </header>

      <div className="mb-4">
        <h3 className="mb-1 text-xs font-medium uppercase tracking-wide text-neutral-400">
          Confidence
        </h3>
        <p className="text-sm leading-6 text-neutral-200">
          {model.confidenceReason}
        </p>
      </div>

      <div>
        <h3 className="mb-2 text-xs font-medium uppercase tracking-wide text-neutral-400">
          Guidance items
        </h3>

        {model.items.length > 0 ? (
          <ul className="space-y-3">
            {model.items.map((item) => (
              <li
                key={item.id}
                className="rounded border border-neutral-800 bg-neutral-900/60 p-3"
              >
                <div className="mb-2 flex items-center justify-between gap-3">
                  <div className="text-xs uppercase tracking-wide text-neutral-400">
                    {item.domainLabel}
                  </div>
                  <div className="flex items-center gap-2 text-[11px] uppercase tracking-wide text-neutral-400">
                    <span>{item.severity}</span>
                    <span>•</span>
                    <span>{item.confidence}</span>
                  </div>
                </div>

                <p className="text-sm leading-6 text-neutral-100">
                  {item.message}
                </p>
                <p className="mt-2 text-sm leading-6 text-neutral-300">
                  {item.rationale}
                </p>

                <div className="mt-3 space-y-1 text-xs text-neutral-500">
                  <p>Observed: {item.createdAtLabel}</p>
                  <p>Sources: {item.sources.join(", ")}</p>
                </div>
              </li>
            ))}
          </ul>
        ) : (
          <p className="text-sm text-neutral-500">
            No bounded guidance items available.
          </p>
        )}
      </div>
    </section>
  );
}

export default OperatorGuidancePanel;
