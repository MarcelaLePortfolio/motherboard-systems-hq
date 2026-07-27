import { useMissionControl } from "../mission-control/useMissionControl";

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
  const { status, mission, error } = useMissionControl();

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
        <h2>Mission Control State</h2>

        <p>
          <strong>Status:</strong> {status}
        </p>

        {error ? (
          <p>
            <strong>Error:</strong> {error}
          </p>
        ) : null}

        {mission ? (
          <>
            <p>
              <strong>Package:</strong> {mission.packageId}
            </p>
            <p>
              <strong>Stage:</strong> {mission.stage}
            </p>
            <p>
              <strong>Owner:</strong> {mission.owner}
            </p>
            <p>
              <strong>Health:</strong> {mission.health}
            </p>
          </>
        ) : (
          <p>
            No authoritative mission has been loaded into Mission Control.
          </p>
        )}
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
        This surface renders authoritative Mission Control state only.
        Runtime mission selection and loading remain a separate corridor.
      </p>
    </section>
  );
}
