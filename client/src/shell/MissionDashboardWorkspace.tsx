import { useEffect, type ReactNode } from "react";
import type {
  MissionPresentationModel,
  MissionProgressStage,
} from "../mission-control/missionPresentationMapper";
import type { MissionTimelineEntry } from "../mission-control/missionReadApi";
import { useMissionControl } from "../mission-control/useMissionControl";
import "./mission-dashboard.css";
import "./mission-dashboard-presentation.css";

const ACTIVE_PACKAGE_ID = "corridor-smoke";

interface MissionCardProps {
  title: string;
  eyebrow?: string;
  children: ReactNode;
  className?: string;
}

function MissionCard({
  title,
  eyebrow,
  children,
  className = "",
}: MissionCardProps) {
  return (
    <section className={`mission-card ${className}`.trim()}>
      <h2 className="mission-card__title">
        {title}
        {eyebrow ? (
          <span className="mission-card__title-eyebrow">{eyebrow}</span>
        ) : null}
      </h2>
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

  return typeof stage === "string" && stage.trim() ? stage.trim() : null;
}

function hasAuthoritativeValue(value: string | null | undefined): boolean {
  return Boolean(value) && value!.toUpperCase() !== "UNKNOWN";
}

/**
 * Executive Brief.
 *
 * Note: the Mission Read contract available to the frontend
 * (`missionReadApi.ts`) does not currently expose a human-readable mission
 * title or objective/requested-outcome field -- only package identity
 * (id/version/project), stage, owner, health, awaiting, and evidence
 * counts. Per the presentation spec's "authoritative data only" principle,
 * this card renders an explicit "not yet available" state for title and
 * objective rather than inventing one from the package id. This is called
 * out as a deferred field in the implementation report; supplying it would
 * require a Mission Read projection change, which is outside this bundle's
 * authorized scope.
 */
function ExecutiveBriefCard({
  mission,
}: {
  mission: MissionPresentationModel;
}) {
  const progressSummary =
    mission.progressPosition !== null
      ? `Stage ${mission.progressPosition} of ${mission.progressTotal}`
      : `Current stage: ${formatLabel(mission.stage)}`;

  return (
    <MissionCard title="Executive Brief" className="mission-card--brief">
      <div className="mission-brief">
        <p className="mission-brief__title">
          Mission title not yet available
        </p>

        <p className="mission-brief__objective">
          Mission objective is not yet exposed by Mission Read for this
          package. Displaying identity and operational state only.
        </p>

        <dl className="mission-brief__facts">
          <div className="mission-brief__fact">
            <dt>Stage</dt>
            <dd>{formatLabel(mission.stage)}</dd>
          </div>

          <div className="mission-brief__fact">
            <dt>Health</dt>
            <dd className="mission-brief__health">
              <span
                className={`mission-health__indicator mission-health__indicator--${mission.health.toLowerCase()}`}
                aria-hidden="true"
              />
              {formatLabel(mission.health)}
            </dd>
          </div>

          <div className="mission-brief__fact">
            <dt>Progress</dt>
            <dd>{progressSummary}</dd>
          </div>
        </dl>

        <div className="mission-brief__footer">
          <span className="mission-brief__identifier">
            {formatLabel(mission.packageId)}
          </span>
          <span className="mission-badge">Version {mission.version}</span>
        </div>
      </div>
    </MissionCard>
  );
}

function MissionStatusCard({
  mission,
}: {
  mission: MissionPresentationModel;
}) {
  const isBlocked = mission.health.toUpperCase() === "BLOCKED";

  return (
    <MissionCard title="Mission Status" className="mission-card--status">
      <div className="mission-status">
        <div className="mission-status__row">
          <span className="mission-status__label">Stage</span>
          <span className="mission-status__value">
            {formatLabel(mission.stage)}
          </span>
        </div>

        <div className="mission-status__row">
          <span className="mission-status__label">Health</span>
          <span className="mission-status__value mission-health">
            <span
              className={`mission-health__indicator mission-health__indicator--${mission.health.toLowerCase()}`}
              aria-hidden="true"
            />
            {formatLabel(mission.health)}
          </span>
        </div>

        <div className="mission-status__row">
          <span className="mission-status__label">Owner</span>
          <span className="mission-status__value">
            {hasAuthoritativeValue(mission.owner)
              ? formatLabel(mission.owner)
              : "Unassigned"}
          </span>
        </div>

        <div className="mission-status__row">
          <span className="mission-status__label">Started</span>
          <span className="mission-status__value">
            {formatTimestamp(mission.startedTimestamp)}
          </span>
        </div>

        {isBlocked ? (
          <p className="mission-status__blocking">
            Blocked
            {mission.awaiting
              ? ` — awaiting ${formatLabel(mission.awaiting)}.`
              : "."}
          </p>
        ) : null}
      </div>
    </MissionCard>
  );
}

function MissionProgressCard({
  mission,
}: {
  mission: MissionPresentationModel;
}) {
  if (!mission.progressStages) {
    return (
      <MissionCard
        title="Mission Progress"
        eyebrow="Operational lifecycle"
        className="mission-card--progress"
      >
        <p className="mission-card__empty">
          Current stage “{formatLabel(mission.stage)}” is not a recognized
          operational lifecycle stage. Progress cannot be safely rendered.
        </p>
      </MissionCard>
    );
  }

  return (
    <MissionCard
      title="Mission Progress"
      eyebrow="Operational lifecycle"
      className="mission-card--progress"
    >
      <ol className="mission-progress-track">
        {mission.progressStages.map((stage: MissionProgressStage) => (
          <li
            key={stage.key}
            className={`mission-progress-track__item mission-progress-track__item--${stage.status}`}
          >
            <span
              className="mission-progress-track__marker"
              aria-hidden="true"
            />
            <span className="mission-progress-track__label">
              {stage.label}
            </span>
          </li>
        ))}
      </ol>
    </MissionCard>
  );
}

function LatestEventCard({ mission }: { mission: MissionPresentationModel }) {
  const latestEntry = mission.timeline[mission.timeline.length - 1];
  const latestStage = latestEntry ? getTimelineStage(latestEntry) : null;

  return (
    <MissionCard title="Latest Event">
      <p className="mission-card__value">
        {latestStage ? formatLabel(latestStage) : "No Recent Activity"}
      </p>

      <p className="mission-card__metadata">
        {formatTimestamp(latestEntry?.timestamp ?? mission.latestTimestamp)}
      </p>
    </MissionCard>
  );
}

function NextStepCard({ mission }: { mission: MissionPresentationModel }) {
  return (
    <MissionCard title="Next Step">
      <p className="mission-card__value">
        {mission.awaiting ? formatLabel(mission.awaiting) : "No Pending Action"}
      </p>

      <p className="mission-card__description">
        {mission.nextStageLabel
          ? `Next lifecycle stage: ${mission.nextStageLabel}.`
          : "No further lifecycle stage is defined after the current one."}
      </p>
    </MissionCard>
  );
}

function ActiveAgentCard({ mission }: { mission: MissionPresentationModel }) {
  const hasOwner = hasAuthoritativeValue(mission.owner);

  return (
    <MissionCard title="Current Agent" className="mission-card--agent">
      <p className="mission-card__value">
        {hasOwner ? formatLabel(mission.owner) : "Unassigned"}
      </p>

      <p className="mission-card__description">
        {hasOwner
          ? `Responsible for the ${formatLabel(mission.stage)} stage.`
          : "No department or agent is currently assigned."}
      </p>

      <p className="mission-card__metadata">
        Status: {formatLabel(mission.health)}
      </p>
    </MissionCard>
  );
}

function MissionPipelineCard({
  mission,
}: {
  mission: MissionPresentationModel;
}) {
  const hasOwner = hasAuthoritativeValue(mission.owner);

  return (
    <MissionCard title="Mission Pipeline" className="mission-card--pipeline">
      <div className="mission-pipeline">
        <div className="mission-pipeline__node">
          <span className="mission-pipeline__node-label">Current Stage</span>
          <span className="mission-pipeline__node-value">
            {formatLabel(mission.stage)}
          </span>
        </div>

        <span className="mission-pipeline__arrow" aria-hidden="true">
          →
        </span>

        <div className="mission-pipeline__node">
          <span className="mission-pipeline__node-label">Current Owner</span>
          <span className="mission-pipeline__node-value">
            {hasOwner ? formatLabel(mission.owner) : "Unassigned"}
          </span>
        </div>

        <span className="mission-pipeline__arrow" aria-hidden="true">
          →
        </span>

        <div className="mission-pipeline__node">
          <span className="mission-pipeline__node-label">Awaiting</span>
          <span className="mission-pipeline__node-value">
            {mission.awaiting ? formatLabel(mission.awaiting) : "Nothing pending"}
          </span>
        </div>
      </div>
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
    ["Integrity Warnings", String(mission.integrityWarnings.length)],
  ];

  return (
    <MissionCard title="Package Details" className="mission-card--details">
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

/**
 * No authoritative system-level telemetry field exists on the Mission Read
 * model (only per-mission evidence). Per spec 4.9 / implementation plan,
 * System Overview is explicitly deferred rather than populated with
 * invented metrics.
 */
function SystemOverviewCard() {
  return (
    <MissionCard title="System Overview" className="mission-card--system">
      <p className="mission-card__empty">
        System-level telemetry is not yet available from Mission Read.
        This card is intentionally deferred until an authoritative
        projection exists.
      </p>
    </MissionCard>
  );
}

function GovernanceHistoryCard({
  mission,
}: {
  mission: MissionPresentationModel;
}) {
  if (!mission.timeline.length) {
    return (
      <MissionCard
        title="Governance History"
        eyebrow="Authoritative event feed"
        className="mission-card--history"
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
      title="Governance History"
      eyebrow="Authoritative event feed"
      className="mission-card--history"
    >
      <ol className="mission-timeline">
        {mission.timeline.map((entry, index) => {
          const stage = getTimelineStage(entry) ?? `Event ${index + 1}`;
          const isCurrent = index === currentIndex;

          return (
            <li
              key={`${stage}-${entry.timestamp ?? index}`}
              className={`mission-timeline__item ${
                isCurrent ? "mission-timeline__item--current" : ""
              }`.trim()}
            >
              <span className="mission-timeline__marker" aria-hidden="true" />

              <div>
                <p className="mission-timeline__stage">{formatLabel(stage)}</p>
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

export default function MissionDashboardWorkspace() {
  const { mission, status, error, loadMission, refresh } = useMissionControl();

  useEffect(() => {
    void loadMission(ACTIVE_PACKAGE_ID);
  }, [loadMission]);

  if (status === "idle" || status === "loading") {
    return (
      <div className="mission-dashboard-state">Preparing Mission Control…</div>
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
        <p>{error ?? "Mission Control could not load the current mission."}</p>

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
          <p className="mission-dashboard__eyebrow">Mission Control</p>
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
          aria-label="Executive brief and mission status"
        >
          <ExecutiveBriefCard mission={mission} />
          <MissionStatusCard mission={mission} />
        </section>

        <section
          className="mission-dashboard__progress-region"
          aria-label="Mission progress"
        >
          <MissionProgressCard mission={mission} />
        </section>

        <section
          className="mission-dashboard__action-region"
          aria-label="Executive action cards"
        >
          <LatestEventCard mission={mission} />
          <NextStepCard mission={mission} />
          <ActiveAgentCard mission={mission} />
        </section>
        {/* --------------------------------------------------------------------------
            Archived Presentation Components

            Mission Pipeline
            Package Details
            System Overview
            Governance History

            Removed from the Executive Mission Control executive view on
            2026-07-30. Rendering intentionally disabled while preserving the
            implementation below for future restoration or reuse.
        -------------------------------------------------------------------------- */}
      </div>
    </main>
  );
}
