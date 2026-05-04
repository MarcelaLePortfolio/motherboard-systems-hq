'use client';

import { useEffect, useState } from 'react';
import StatusRow from './ui/StatusRow';
import {
  basePanelStyle,
  liveBorderStyle,
  staleBorderStyle,
  headerStyle,
  sectionStyle,
  timestampStyle
} from './ui/panelStyles';

export default function GuidancePanel() {
  const [data, setData] = useState<any>(null);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    let es: EventSource | null = null;

    const connectSSE = () => {
      es = new EventSource('/events/guidance');

      es.onmessage = (event) => {
        try {
          const json = JSON.parse(event.data);
          setData(json);
          setLoading(false);
        } catch {
          console.error('SSE parse failed');
        }
      };

      es.onerror = () => {
        es?.close();
        fallbackPolling();
      };
    };

    const fallbackPolling = () => {
      const fetchGuidance = async () => {
        try {
          const res = await fetch('/api/guidance');
          const json = await res.json();
          setData(json);
        } catch {
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

  const panelStyle = {
    ...basePanelStyle,
    ...(isStale ? staleBorderStyle : liveBorderStyle)
  };

  const getColor = (type: string) => {
    if (type === 'critical') return '#ff5555';
    if (type === 'warning') return '#ffaa00';
    return '#66ccff';
  };

  return (
    <div style={panelStyle}>
      <h3 style={headerStyle}>
        Operator Guidance <span style={{ opacity: 0.7 }}>({isStale ? 'STALE' : 'LIVE'})</span>
      </h3>

      <div style={sectionStyle}>
        <strong>Subsystem Context</strong>
        {data.subsystems?.map((s: any) => (
          <StatusRow key={s.name} label={s.name} status={s.status} connected={s.connected} />
        ))}
      </div>

      <div style={sectionStyle}>
        <strong>Guidance</strong>
        {data.guidance_available ? (
          data.guidance.map((g: any, i: number) => (
            <div
              key={i}
              style={{
                marginTop: '4px',
                padding: '4px 6px',
                borderLeft: `3px solid ${getColor(g.type)}`,
                fontSize: '13px'
              }}
            >
              <div style={{ fontWeight: 600 }}>
                {g.type.toUpperCase()} • {g.subsystem}
              </div>
              <div style={{ opacity: 0.85 }}>{g.message}</div>
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
