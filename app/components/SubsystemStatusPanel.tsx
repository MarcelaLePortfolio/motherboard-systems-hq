'use client';

import { useEffect, useState } from 'react';

type Subsystem = {
  name: string;
  status: string;
  connected: boolean;
};

type Snapshot = {
  subsystems: Subsystem[];
  timestamp?: string;
};

export default function SubsystemStatusPanel() {
  const [data, setData] = useState<Snapshot | null>(null);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    let es: EventSource | null = null;

    const connectSSE = () => {
      try {
        es = new EventSource('/events/subsystem-status');

        es.onmessage = (event) => {
          const parsed = JSON.parse(event.data);
          setData(parsed);
          setLoading(false);
        };

        es.onerror = () => {
          console.warn('Subsystem SSE failed, falling back to polling');
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
          const json = await res.json();
          setData(json);
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

  if (loading) return <div>Loading subsystem status...</div>;
  if (!data) return <div>No subsystem data</div>;

  const ageMs = data.timestamp ? Date.now() - new Date(data.timestamp).getTime() : null;
  const isStale = ageMs !== null && ageMs > 10000;
  const severity = isStale ? 'WARNING' : 'NORMAL';

  return (
    <div
      style={{
        padding: '12px',
        border: isStale ? '2px solid #ff5555' : '1px solid #333',
        borderRadius: '8px',
        background: isStale ? '#2a0000' : 'transparent'
      }}
    >
      <h3>
        Subsystem Status {isStale ? '(STALE)' : '(LIVE)'} — {severity}
      </h3>

      {data.subsystems.map((s) => (
        <div key={s.name} style={{ marginBottom: '8px' }}>
          <strong>{s.name}</strong>: {s.status} {s.connected ? '[ONLINE]' : '[OFFLINE]'}
        </div>
      ))}

      {data.timestamp && (
        <div style={{ marginTop: '8px', fontSize: '12px', opacity: 0.7 }}>
          Updated: {data.timestamp}
        </div>
      )}
    </div>
  );
}
