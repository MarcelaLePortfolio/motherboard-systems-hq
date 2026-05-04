'use client';

import SubsystemStatusPanel from './SubsystemStatusPanel';
import GuidancePanel from './GuidancePanel';

export default function OperatorDashboard() {
  return (
    <div style={{ padding: '24px', display: 'grid', gap: '16px' }}>
      <div>
        <h2 style={{ marginBottom: '12px' }}>Operator Dashboard</h2>
        <p style={{ marginBottom: '16px', opacity: 0.7 }}>
          Unified read-only surface for subsystem health and operator guidance.
        </p>
      </div>

      <div style={{ display: 'grid', gap: '16px' }}>
        <SubsystemStatusPanel />
        <GuidancePanel />
      </div>
    </div>
  );
}
