const missionStages = [
  "Delegated",
  "Governance Validation",
  "Envelope Construction",
  "Assigned",
  "Executing",
  "Outcome Review",
  "Complete",
];

export default function MissionDashboardWorkspace() {
  return (
    <section
      className="mission-dashboard-workspace"
      data-workspace="mission-dashboard"
      aria-labelledby="mission-dashboard-title"
    >
      <header className="mission-dashboard-workspace__header">
        <div>
          <p className="mission-dashboard-workspace__eyebrow">Dashboard</p>
          <h1 id="mission-dashboard-title">Mission</h1>
        </div>
      </header>

      <div className="mission-dashboard-workspace__empty-state">
        <h2>No delegated mission is currently active.</h2>
        <p>
          When a Package is delegated, this view will show its authoritative
          real-time status from Governance Validation through completion.
        </p>
      </div>

      <ol
        className="mission-dashboard-workspace__pipeline"
        aria-label="Mission pipeline"
      >
        {missionStages.map((stage) => (
          <li key={stage} className="mission-dashboard-workspace__stage">
            <span aria-hidden="true">○</span>
            <span>{stage}</span>
          </li>
        ))}
      </ol>

      <p className="mission-dashboard-workspace__boundary">
        This initial surface does not infer, simulate, or fabricate operational
        state. Runtime pipeline binding remains a separate implementation slice.
      </p>
    </section>
  );
}
