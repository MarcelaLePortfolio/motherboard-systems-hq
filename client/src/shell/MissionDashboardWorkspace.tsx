import { useEffect, type ReactNode } from "react";
import type { MissionPresentationModel } from "../mission-control/missionPresentationMapper";
import type { MissionTimelineEntry } from "../mission-control/missionReadApi";
import { useMissionControl } from "../mission-control/useMissionControl";
import "./mission-dashboard.css";

const ACTIVE_PACKAGE_ID = "corridor-smoke";

interface MissionCardProps {
  title: string;
  children: ReactNode;
  className?: string;
}

function MissionCard({
  title,
  children,
  className = "",
}: MissionCardProps) {
  return (
    <section className={`mission-card ${className}`.trim()}>
      <h2 className="mission-card__title">{title}</h2>
      {children}
    </section>
  );
}

function formatLabel(value: string | null | undefined): string {
  if (!value) {
    return "Unavailable";
  }

  return value
    .replace(/[_-]+/g, " ")
    .toLowerCase()
    .replace(/\b\w/g, (character) => character.toUpperCase());
}

function formatTimestamp(value: string | null | undefined): string {
  if (!value) {
    return "Time unavailable";
  }

  const date = new Date(value);

  if (Number.isNaN(date.getTime())) {
    return value;
  }

  return date.toLocaleString();
}

function getTimelineStage(entry: MissionTimelineEntry): string | null {
  const stage = entry.stage ?? entry.event_type;

  return typeof stage === "string" && stage.trim()
    ? stage.trim()
    : null;
}

function CurrentMissionCard({
  mission,
}: {
  mission: MissionPresentationModel;
}) {
  return (
    <MissionCard
      title="Current Mission"
      className="mission-card--current"
    >
      <div className="mission-current">
        <div>
          <p className="mission-current__name">
            {formatLabel(mission.packageId)}
          </p>

          <p className="mission-card__description">
            This mission is moving through the organizational
            governance lifecycle.
          </p>
        </div>

        <span className="mission-badge">
          Version {mission.version}
        </span>
      </div>
    </MissionCard>
  );
}

function MissionStatusCard({
  mission,
}: {
  mission: MissionPresentationModel;
}) {
  return (
    <MissionCard
      title="Mission Status"
      className="mission-card--status"
    >
      <p className="mission-card__value">
        {formatLabel(mission.stage)}
      </p>

      <div className="mission-health">
        <span
          className={`mission-health__indicator mission-health__indicator--${mission.health.toLowerCase()}`}
          aria-hidden="true"
        />

        <span>{formatLabel(mission.health)}</span>
      </div>

      <p className="mission-card__description">
        Current stage and mission health.
      </p>
    </MissionCard>
  );
}

function GovernanceLifecycleCard({
  mission,
}: {
  mission: MissionPresentationModel;
}) {
  if (!mission.timeline.length) {
    return (
      <MissionCard
        title="Governance Lifecycle"
        className="mission-card--lifecycle"
      >
        <p className="mission-card__empty">
          No lifecycle activity has been recorded.
        </p>
      </MissionCard>
    );
  }

  const currentIndex = mission.timeline.length - 1;

  return (
    <MissionCard
      title="Governance Lifecycle"
      className="mission-card--lifecycle"
    >
      <ol className="mission-timeline">
        {mission.timeline.map((entry, index) => {
          const stage =
            getTimelineStage(entry) ?? `Event ${index + 1}`;
          const isCurrent = index === currentIndex;

          return (
            <li
              key={`${stage}-${entry.timestamp ?? index}`}
              className={`mission-timeline__item ${
                isCurrent
                  ? "mission-timeline__item--current"
                  : ""
              }`.trim()}
            >
              <span
                className="mission-timeline__marker"
                aria-hidden="true"
              />

              <div>
                <p className="mission-timeline__stage">
                  {formatLabel(stage)}
                </p>

                <p className="mission-timeline__timestamp">
                  {formatTimestamp(entry.timestamp)}
                </p>
              </div>
            </li>
          );
        })}
      </ol>
    </MissionCard>
  );
}

function LatestEventCard({
  mission,
}: {
  mission: MissionPresentationModel;
}) {
  const latestEntry =
    mission.timeline[mission.timeline.length - 1];

  const latestStage = latestEntry
    ? getTimelineStage(latestEntry)
    : null;

  return (
    <MissionCard title="Latest Event">
      <p className="mission-card__value">
        {latestStage
          ? formatLabel(latestStage)
          : "No Recent Activity"}
      </p>

      <p className="mission-card__metadata">
        {formatTimestamp(
          latestEntry?.timestamp ?? mission.latestTimestamp,
        )}
      </p>
    </MissionCard>
  );
}

function NextStepCard({
  mission,
}: {
  mission: MissionPresentationModel;
}) {
  return (
    <MissionCard title="Next Step">
      <p className="mission-card__value">
        {mission.awaiting
          ? formatLabel(mission.awaiting)
          : "No Pending Action"}
      </p>

      <p className="mission-card__description">
        The next required action will appear here when available.
      </p>
    </MissionCard>
  );
}

function PackageDetailsCard({
  mission,
}: {
  mission: MissionPresentationModel;
}) {
  const details = [
    ["Mission ID", mission.packageId],
    ["Project", mission.projectId ?? "Unavailable"],
    ["Version", String(mission.version)],
    ["Lifecycle Events", String(mission.lifecycleEventCount)],
    ["Artifacts", String(mission.artifactCount)],
    [
      "Integrity Warnings",
      String(mission.integrityWarnings.length),
    ],
  ];

  return (
    <MissionCard
      title="Mission Details"
      className="mission-card--details"
    >
      <dl className="mission-details">
        {details.map(([label, value]) => (
          <div className="mission-details__row" key={label}>
            <dt>{label}</dt>
            <dd>{value}</dd>
          </div>
        ))}
      </dl>
    </MissionCard>
  );
}

function ActiveAgentCard({
  mission,
}: {
  mission: MissionPresentationModel;
}) {
  const hasAuthoritativeOwner =
    mission.owner &&
    mission.owner.toUpperCase() !== "UNKNOWN";

  return (
    <MissionCard
      title="Current Owner"
      className="mission-card--agent"
    >
      <p className="mission-card__value">
        {hasAuthoritativeOwner
          ? formatLabel(mission.owner)
          : "Unassigned"}
      </p>

      <p className="mission-card__description">
        {hasAuthoritativeOwner
          ? "Currently responsible for mission progress."
          : "No department or agent is currently assigned."}
      </p>
    </MissionCard>
  );
}

export default function MissionDashboardWorkspace() {
  const {
    mission,
    status,
    error,
    loadMission,
    refresh,
  } = useMissionControl();

  useEffect(() => {
    void loadMission(ACTIVE_PACKAGE_ID);
  }, [loadMission]);

  if (status === "idle" || status === "loading") {
    return (
      <div className="mission-dashboard-state">
        Preparing Mission Control…
      </div>
    );
  }

  if (status === "not_found") {
    return (
      <div className="mission-dashboard-state">
        No mission is currently in progress.
      </div>
    );
  }

  if (status === "error" || !mission) {
    return (
      <div className="mission-dashboard-state mission-dashboard-state--error">
        <p>
          {error ??
            "Mission Control could not load the current mission."}
        </p>

        <button
          type="button"
          onClick={() => void refresh()}
          className="mission-button"
        >
          Try again
        </button>
      </div>
    );
  }

  return (
    <main className="mission-dashboard">
      <header className="mission-dashboard__header">
        <div>
          <p className="mission-dashboard__eyebrow">
            Mission Control
          </p>

          <h1 className="mission-dashboard__heading">
            Executive Mission Overview
          </h1>
        </div>

        <button
          type="button"
          onClick={() => void refresh()}
          className="mission-button"
        >
          Refresh
        </button>
      </header>

      <div className="mission-dashboard__composition">
        <section
          className="mission-dashboard__hero-region"
          aria-label="Current mission overview"
        >
          <CurrentMissionCard mission={mission} />
          <MissionStatusCard mission={mission} />
        </section>

        <section
          className="mission-dashboard__lifecycle-region"
          aria-label="Governance lifecycle"
        >
          <GovernanceLifecycleCard mission={mission} />
        </section>

        <section
          className="mission-dashboard__lower-region"
          aria-label="Mission activity and evidence"
        >
          <div className="mission-dashboard__pipeline-region">
            <header className="mission-dashboard__region-heading">
              <p className="mission-dashboard__region-eyebrow">
                Mission Progress
              </p>

              <h2 className="mission-dashboard__region-title">
                Current Activity
              </h2>
            </header>

            <div className="mission-dashboard__pipeline-cards">
              <LatestEventCard mission={mission} />
              <NextStepCard mission={mission} />
              <ActiveAgentCard mission={mission} />
            </div>
          </div>

          <div className="mission-dashboard__evidence-region">
            <header className="mission-dashboard__region-heading">
              <p className="mission-dashboard__region-eyebrow">
                Mission Record
              </p>

              <h2 className="mission-dashboard__region-title">
                Supporting Details
              </h2>
            </header>

            <PackageDetailsCard mission={mission} />
          </div>
        </section>
      </div>
    </main>
  );
}
