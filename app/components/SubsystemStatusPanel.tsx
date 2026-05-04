'use client';

import { useEffect, useState } from 'react';
import {
  basePanelStyle,
  liveBorderStyle,
  staleBorderStyle,
  headerStyle,
  timestampStyle,
  sectionStyle
} from './ui/panelStyles';

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

  if (loading) return <div style={{ padding: '12px' }}>Loading subsystem status...</div>;
  if (!data) return <div style={{ padding: '12px' }}>No subsystem data</div>;

  const ageMs = data.timestamp ? Date.now() - new Date(data.timestamp).getTime() : null;
  const isStale = ageMs !== null && ageMs > 10000;

  const panelStyle = {
    ...basePanelStyle,
    ...(isStale ? staleBorderStyle : liveBorderStyle)
  };

  return (
    <div style={panelStyle}>
      <h3 style={headerStyle}>
        Subsystem Status <span style={{ opacity: 0.7 }}>({isStale ? 'STALE' : 'LIVE'})</span>
      </h3>

      <div style={sectionStyle}>
        {data.subsystems.map((s) => (
          <div key={s.name} style={{ marginBottom: '6px' }}>
            <strong>{s.name}</strong>: {s.status}{' '}
            <span style={{ opacity: 0.7 }}>{s.connected ? '[ONLINE]' : '[OFFLINE]'}</span>
          </div>
        ))}
      </div>

      {data.timestamp && (
        <div style={timestampStyle}>
          Updated: {data.timestamp}
        </div>
      )}
    </div>
  );
}
