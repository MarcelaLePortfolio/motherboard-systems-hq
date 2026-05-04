'use client';

import { useEffect, useState } from 'react';

type Subsystem = {
  name: string;
  status: string;
  connected: boolean;
};

export default function SubsystemStatusPanel() {
  const [subsystems, setSubsystems] = useState<Subsystem[]>([]);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    const fetchStatus = async () => {
      try {
        const res = await fetch('/api/subsystem-status');
        const data = await res.json();
        setSubsystems(data.subsystems || []);
      } catch (err) {
        console.error('Failed to fetch subsystem status');
      } finally {
        setLoading(false);
      }
    };

    fetchStatus();
    const interval = setInterval(fetchStatus, 5000);

    return () => clearInterval(interval);
  }, []);

  if (loading) {
    return <div>Loading subsystem status...</div>;
  }

  return (
    <div style={{ padding: '12px', border: '1px solid #333', borderRadius: '8px' }}>
      <h3>Subsystem Status</h3>
      {subsystems.map((s) => (
        <div key={s.name} style={{ marginBottom: '8px' }}>
          <strong>{s.name}</strong>: {s.status} {s.connected ? '[ONLINE]' : '[OFFLINE]'}
        </div>
      ))}
    </div>
  );
}
