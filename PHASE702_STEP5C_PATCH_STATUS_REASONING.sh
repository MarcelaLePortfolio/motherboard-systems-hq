#!/usr/bin/env bash
set -euo pipefail

cat > app/components/ui/StatusRow.tsx << 'TSX'
'use client';

type Props = {
  label: string;
  status: string;
  connected?: boolean;
};

function getStatusReason(status: string, connected?: boolean): string {
  const normalized = status.toLowerCase();

  if (connected === false) {
    return 'No active connection is currently reported for this subsystem.';
  }

  if (normalized.includes('critical')) {
    return 'Critical means the subsystem is reporting a high-severity state that needs operator attention.';
  }

  if (normalized.includes('degraded')) {
    return 'Degraded means the subsystem is available but not operating at full confidence.';
  }

  if (normalized.includes('offline')) {
    return 'Offline means the subsystem is not currently reporting an active runtime connection.';
  }

  if (normalized.includes('unknown')) {
    return 'Unknown means the UI has not received enough current data to classify this subsystem.';
  }

  if (normalized.includes('healthy') || normalized.includes('ok') || normalized.includes('online')) {
    return 'This subsystem is currently reporting an available state.';
  }

  return 'Status is shown exactly as reported by the subsystem feed.';
}

export default function StatusRow({ label, status, connected }: Props) {
  const reason = getStatusReason(status, connected);

  return (
    <div style={{ marginBottom: '10px' }}>
      <div>
        <strong>{label}</strong>: {status}{' '}
        {typeof connected === 'boolean' && (
          <span style={{ opacity: 0.7 }}>
            {connected ? '[ONLINE]' : '[OFFLINE]'}
          </span>
        )}
      </div>
      <div style={{ marginTop: '3px', fontSize: '12px', opacity: 0.72, lineHeight: 1.35 }}>
        {reason}
      </div>
    </div>
  );
}
TSX

git add app/components/ui/StatusRow.tsx PHASE702_STEP5C_PATCH_STATUS_REASONING.sh
git commit -m "Phase 702: add subsystem status reasoning to UI"
git push

git status --short
