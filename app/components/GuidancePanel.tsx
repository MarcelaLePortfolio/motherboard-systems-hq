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

  if (loading) return <div style={{ padding: '12px' }}>Loading guidance...</div>;
  if (!data) return <div style={{ padding: '12px' }}>No guidance data</div>;

  const ageMs = data.timestamp ? Date.now() - new Date(data.timestamp).getTime() : null;
  const isStale = ageMs !== null && ageMs > 10000;
  const severity = isStale ? 'WARNING' : 'NORMAL';

  return (
    <div
      style={{
        padding: '16px',
        border: isStale ? '2px solid #ff5555' : '1px solid #444',
        borderRadius: '10px',
        background: isStale ? '#2a0000' : '#111',
        color: '#eee'
      }}
    >
      <h3 style={{ marginBottom: '10px', fontSize: '16px' }}>
        Operator Guidance <span style={{ opacity: 0.7 }}>({isStale ? 'STALE' : 'LIVE'} • {severity})</span>
      </h3>

      <div style={{ marginBottom: '12px' }}>
        <strong>Subsystem Context</strong>
        {data.subsystems?.map((s) => (
          <div key={s.name} style={{ marginTop: '6px' }}>
            {s.name}: {s.status}{' '}
            <span style={{ opacity: 0.7 }}>{s.connected ? '[ONLINE]' : '[OFFLINE]'}</span>
          </div>
        ))}
      </div>

      <div style={{ marginBottom: '10px' }}>
        <strong>Guidance</strong>
        {data.guidance_available ? (
          data.guidance.map((g, i) => (
            <div key={i} style={{ marginTop: '6px' }}>
              {JSON.stringify(g)}
            </div>
          ))
        ) : (
          <div style={{ marginTop: '6px', opacity: 0.7 }}>No active guidance</div>
        )}
      </div>

      {data.timestamp && (
        <div style={{ fontSize: '12px', opacity: 0.5 }}>
          Updated: {data.timestamp}
        </div>
      )}
    </div>
  );
}
