import { usePackages } from "./usePackages";
import type { ExecutivePackageReadModel } from "./packageReadApi";

import "./packages-workspace.css";

function formatTimestamp(value: string): string {
  const parsed = new Date(value);

  if (Number.isNaN(parsed.getTime())) {
    return value;
  }

  return parsed.toLocaleString(undefined, {
    dateStyle: "medium",
    timeStyle: "short",
  });
}

function PackageStatusBadge({
  status,
}: {
  status: ExecutivePackageReadModel["status"];
}) {
  return (
    <span
      className="packages-workspace-badge packages-workspace-badge--status"
      data-status={status}
    >
      {status === "needs_review" ? "Needs review" : status}
    </span>
  );
}

function LivingDraftBadge() {
  return (
    <span className="packages-workspace-badge packages-workspace-badge--draft">
      Living Draft
    </span>
  );
}

function PackagesWorkspaceNotice() {
  return (
    <div
      className="packages-workspace-notice"
      role="note"
    >
      Living Draft Packages reflect work in progress and
      are <strong>not authoritative</strong>. They are not
      approved, final, or execution-ready.
    </div>
  );
}

function PackageListItem({
  pkg,
  isSelected,
  onSelect,
}: {
  pkg: ExecutivePackageReadModel;
  isSelected: boolean;
  onSelect: (packageId: string) => void;
}) {
  return (
    <li>
      <button
        type="button"
        className="packages-workspace-list-item"
        aria-current={isSelected ? "true" : undefined}
        data-selected={isSelected ? "true" : "false"}
        onClick={() => onSelect(pkg.id)}
      >
        <span className="packages-workspace-list-item-top">
          <span className="packages-workspace-list-item-title">
            {pkg.title || "Untitled Package"}
          </span>
          {pkg.kind === "living_draft" ? (
            <LivingDraftBadge />
          ) : null}
        </span>

        <span className="packages-workspace-list-item-summary">
          {pkg.summary || "No summary available."}
        </span>

        <span className="packages-workspace-list-item-meta">
          <PackageStatusBadge status={pkg.status} />
          <span className="packages-workspace-list-item-updated">
            Updated {formatTimestamp(pkg.updated_at)}
          </span>
        </span>
      </button>
    </li>
  );
}

function PackagesListPanel() {
  const {
    packages,
    status,
    error,
    selectedPackageId,
    selectPackage,
    refresh,
  } = usePackages();

  if (status === "loading") {
    return (
      <div
        className="packages-workspace-state"
        role="status"
        aria-live="polite"
      >
        Loading Packages…
      </div>
    );
  }

  if (status === "error") {
    return (
      <div
        className="packages-workspace-state packages-workspace-state--error"
        role="alert"
      >
        <p>{error ?? "Unable to load Packages."}</p>
        <button
          type="button"
          className="packages-workspace-button"
          onClick={() => void refresh()}
        >
          Try again
        </button>
      </div>
    );
  }

  if (status === "idle") {
    return (
      <div
        className="packages-workspace-state"
        role="status"
      >
        No active project is selected.
      </div>
    );
  }

  if (packages.length === 0) {
    return (
      <div
        className="packages-workspace-state"
        role="status"
      >
        No Packages are available for this project yet.
      </div>
    );
  }

  return (
    <ul
      className="packages-workspace-list"
      aria-label="Packages"
    >
      {packages.map((pkg) => (
        <PackageListItem
          key={pkg.id}
          pkg={pkg}
          isSelected={pkg.id === selectedPackageId}
          onSelect={(packageId) => {
            void selectPackage(packageId);
          }}
        />
      ))}
    </ul>
  );
}

function PackageDetailPanel() {
  const {
    selectedPackageId,
    selectedPackage,
    detailStatus,
    detailError,
    clearSelection,
  } = usePackages();

  if (!selectedPackageId) {
    return (
      <div
        className="packages-workspace-state"
        role="status"
      >
        Select a Package to view its details.
      </div>
    );
  }

  if (detailStatus === "loading") {
    return (
      <div
        className="packages-workspace-state"
        role="status"
        aria-live="polite"
      >
        Loading Package detail…
      </div>
    );
  }

  if (detailStatus === "error") {
    return (
      <div
        className="packages-workspace-state packages-workspace-state--error"
        role="alert"
      >
        <p>
          {detailError ?? "Unable to load Package details."}
        </p>
        <button
          type="button"
          className="packages-workspace-button"
          onClick={clearSelection}
        >
          Back to list
        </button>
      </div>
    );
  }

  if (!selectedPackage) {
    return null;
  }

  return (
    <article
      className="packages-workspace-detail"
      aria-labelledby="packages-workspace-detail-heading"
    >
      <header className="packages-workspace-detail-header">
        <div className="packages-workspace-detail-heading-row">
          <h2 id="packages-workspace-detail-heading">
            {selectedPackage.title || "Untitled Package"}
          </h2>
          {selectedPackage.kind === "living_draft" ? (
            <LivingDraftBadge />
          ) : null}
        </div>

        <div className="packages-workspace-detail-meta">
          <PackageStatusBadge status={selectedPackage.status} />
          <span>Source status: {selectedPackage.source_status}</span>
        </div>
      </header>

      <PackagesWorkspaceNotice />

      <p className="packages-workspace-detail-summary">
        {selectedPackage.summary || "No summary available."}
      </p>

      <dl className="packages-workspace-detail-facts">
        <div>
          <dt>Package ID</dt>
          <dd>{selectedPackage.id}</dd>
        </div>
        <div>
          <dt>Conversation</dt>
          <dd>
            {selectedPackage.conversation_id ?? "—"}
          </dd>
        </div>
        <div>
          <dt>Created</dt>
          <dd>
            {formatTimestamp(selectedPackage.created_at)}
          </dd>
        </div>
        <div>
          <dt>Updated</dt>
          <dd>
            {formatTimestamp(selectedPackage.updated_at)}
          </dd>
        </div>
      </dl>

      <button
        type="button"
        className="packages-workspace-button packages-workspace-button--secondary"
        onClick={clearSelection}
      >
        Close detail
      </button>
    </article>
  );
}

export default function PackagesWorkspace() {
  const { status, refresh } = usePackages();

  return (
    <section
      className="packages-workspace"
      aria-labelledby="packages-workspace-heading"
    >
      <header className="packages-workspace-header">
        <div className="packages-workspace-header-text">
          <h1 id="packages-workspace-heading">Packages</h1>
          <p>
            Review Packages generated for the active
            project. This is a read-only view.
          </p>
        </div>

        <button
          type="button"
          className="packages-workspace-button"
          onClick={() => void refresh()}
          disabled={status === "loading"}
        >
          {status === "loading" ? "Refreshing…" : "Refresh"}
        </button>
      </header>

      <PackagesWorkspaceNotice />

      <div className="packages-workspace-body">
        <div className="packages-workspace-panel packages-workspace-panel--list">
          <PackagesListPanel />
        </div>

        <div className="packages-workspace-panel packages-workspace-panel--detail">
          <PackageDetailPanel />
        </div>
      </div>
    </section>
  );
}
