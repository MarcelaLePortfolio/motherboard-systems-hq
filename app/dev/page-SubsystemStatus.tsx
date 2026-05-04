'use client';

import SubsystemStatusPanel from '../components/SubsystemStatusPanel';

export default function Page() {
  return (
    <div style={{ padding: '24px' }}>
      <h2>Subsystem Monitor</h2>
      <SubsystemStatusPanel />
    </div>
  );
}
