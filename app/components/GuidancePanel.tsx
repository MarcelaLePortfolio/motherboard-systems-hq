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

  const panelStyle = {
    ...basePanelStyle,
    ...(isStale ? staleBorderStyle : liveBorderStyle)
  };

  return (
    <div style={panelStyle}>
      <h3 style={headerStyle}>
        Operator Guidance <span style={{ opacity: 0.7 }}>({isStale ? 'STALE' : 'LIVE'})</span>
      </h3>

      <div style={sectionStyle}>
        <strong>Subsystem Context</strong>
        {data.subsystems?.map((s) => (
          <div key={s.name} style={{ marginTop: '6px' }}>
            {s.name}: {s.status}{' '}
            <span style={{ opacity: 0.7 }}>{s.connected ? '[ONLINE]' : '[OFFLINE]'}</span>
          </div>
        ))}
      </div>

      <div style={sectionStyle}>
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
        <div style={timestampStyle}>
          Updated: {data.timestamp}
        </div>
      )}
    </div>
  );
}
