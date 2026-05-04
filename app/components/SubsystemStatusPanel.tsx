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
    let es: EventSource | null = null;

    const connectSSE = () => {
      try {
        es = new EventSource('/events/subsystem-status');

        es.onmessage = (event) => {
          const data = JSON.parse(event.data);
          setSubsystems(data.subsystems || []);
          setLoading(false);
        };

        es.onerror = () => {
          console.warn('SSE failed, falling back to polling...');
          es?.close();
          fallbackPolling();
        };
      } catch {
        fallbackPolling();
      }
    };

    const fallbackPolling = () => {
      const fetchStatus = async () => {
        try {
          const res = await fetch('/api/subsystem-status');
          const data = await res.json();
          setSubsystems(data.subsystems || []);
        } catch (err) {
          console.error('Polling failed');
        } finally {
          setLoading(false);
        }
      };

      fetchStatus();
      const interval = setInterval(fetchStatus, 5000);
      return () => clearInterval(interval);
    };

    connectSSE();

    return () => {
      es?.close();
    };
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
