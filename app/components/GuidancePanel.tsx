'use client';

import { useEffect, useState } from 'react';

type Subsystem = {
  name: string;
  status: string;
  connected: boolean;
};

type GuidanceResponse = {
  ok: boolean;
  guidance_available: boolean;
  guidance: any[];
  subsystems?: Subsystem[];
  timestamp?: string;
};

export default function GuidancePanel() {
  const [data, setData] = useState<GuidanceResponse | null>(null);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    let es: EventSource | null = null;

    const connectSSE = () => {
      try {
        es = new EventSource('/events/guidance');

        es.onmessage = (event) => {
          const parsed = JSON.parse(event.data);
          setData(parsed);
          setLoading(false);
        };

        es.onerror = () => {
          console.warn('Guidance SSE failed, falling back to polling');
          es?.close();
          fallbackPolling();
        };
      } catch {
        fallbackPolling();
      }
    };

    const fallbackPolling = () => {
      const fetchGuidance = async () => {
        try {
          const res = await fetch('/api/guidance');
          const json = await res.json();
          setData(json);
        } catch (err) {
          console.error('Polling failed');
        } finally {
          setLoading(false);
        }
      };

      fetchGuidance();
      const interval = setInterval(fetchGuidance, 5000);
      return () => clearInterval(interval);
    };

    connectSSE();

    return () => {
      es?.close();
    };
  }, []);

  if (loading) return <div>Loading guidance...</div>;
  if (!data) return <div>No guidance data</div>;

  const ageMs = data.timestamp ? Date.now() - new Date(data.timestamp).getTime() : null;
  const isStale = ageMs !== null && ageMs > 10000;
  const severity = isStale ? 'WARNING' : 'NORMAL';

  return (
    <div
      style={{
        padding: '12px',
        border: isStale ? '2px solid #ff5555' : '1px solid #444',
        borderRadius: '8px',
        background: isStale ? '#2a0000' : 'transparent'
      }}
    >
      <h3>
        Operator Guidance {isStale ? '(STALE)' : '(LIVE)'} — {severity}
      </h3>

      <div style={{ marginBottom: '12px' }}>
        <strong>Subsystem Context:</strong>
        {data.subsystems?.map((s) => (
          <div key={s.name}>
            {s.name}: {s.status} {s.connected ? '[ONLINE]' : '[OFFLINE]'}
          </div>
        ))}
      </div>

      <div>
        <strong>Guidance:</strong>
        {data.guidance_available ? (
          data.guidance.map((g, i) => <div key={i}>{JSON.stringify(g)}</div>)
        ) : (
          <div>No active guidance</div>
        )}
      </div>

      {data.timestamp && (
        <div style={{ marginTop: '8px', fontSize: '12px', opacity: 0.7 }}>
          Updated: {data.timestamp}
        </div>
      )}
    </div>
  );
}
