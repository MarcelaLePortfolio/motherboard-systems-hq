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
  const [retryStatus, setRetryStatus] = useState<string | null>(null);
  const [coherenceData, setCoherenceData] = useState<any>(null);

  const fetchGuidance = async () => {
    try {
      const res = await fetch('/api/guidance');
      const json = await res.json();
      setData(json);
    } catch {
      console.error('Guidance fetch failed');
    } finally {
      setLoading(false);
    }
  };

  const fetchCoherencePreview = async () => {
    try {
      const res = await fetch('/api/guidance/coherence-shadow');
      if (!res.ok) return;
      const json = await res.json();
      setCoherenceData(json);
    } catch {
      console.error('Coherence preview fetch failed');
    }
  };

  const retryTask = async (taskId: string) => {
    setRetryStatus('clicked');

    if (!confirm('Retry this task?')) {
      setRetryStatus('cancelled');
      return;
    }

    setRetryStatus('creating');

    const retryId = `retry_${taskId}_${Date.now()}`;

    try {
      const res = await fetch('/api/tasks/create', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          task_id: retryId,
          title: `Retry ${taskId}`,
          status: 'queued',
          kind: 'retry',
          payload: {
            retry_of_task_id: taskId,
            execution_mode: 'rebuild_context',
            cache_policy: 'bypass',
            memory_scope: 'reset_partial',
            strategy: 'fresh-context'
          },
          source: 'operator-guidance-ui'
        })
      });

      if (!res.ok) {
        setRetryStatus('failed');
        return;
      }

      setRetryStatus('created');
      await fetchGuidance();
    } catch {
      setRetryStatus('failed');
      console.error('Retry task creation failed');
    }
  };

  const copyAction = async (text: string) => {
    try {
      await navigator.clipboard.writeText(text);
    } catch {
      console.error('Copy action failed');
    }
  };

  useEffect(() => {
    let es: EventSource | null = null;
    let pollingInterval: ReturnType<typeof setInterval> | null = null;

    const fallbackPolling = () => {
      fetchGuidance();
      fetchCoherencePreview();
      pollingInterval = setInterval(() => {
        fetchGuidance();
        fetchCoherencePreview();
      }, 5000);
    };

    const connectSSE = () => {
      try {
        es = new EventSource('/events/operator-guidance');

        es.onmessage = (event) => {
          try {
            const json = JSON.parse(event.data);
            setData(json);
            fetchCoherencePreview();
            setLoading(false);
          } catch {
            console.error('SSE parse failed');
          }
        };

        es.onerror = () => {
          es?.close();
          fallbackPolling();
        };
      } catch {
        fallbackPolling();
      }
    };

    connectSSE();

    return () => {
      es?.close();
      if (pollingInterval) clearInterval(pollingInterval);
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

  const groupBySeverity = (guidance: any[]) => ({
    critical: guidance.filter((g) => g.type === 'critical'),
    warning: guidance.filter((g) => g.type === 'warning'),
    info: guidance.filter((g) => g.type === 'info')
  });

  const getSeverityStyle = (type: string) => {
    if (type === 'critical') {
      return {
        color: '#ff5555',
        background: 'rgba(255, 85, 85, 0.12)',
        border: 'rgba(255, 85, 85, 0.65)',
        badge: 'CRITICAL'
      };
    }

    if (type === 'warning') {
      return {
        color: '#ffaa00',
        background: 'rgba(255, 170, 0, 0.10)',
        border: 'rgba(255, 170, 0, 0.55)',
        badge: 'WARNING'
      };
    }

    return {
      color: '#66ccff',
      background: 'rgba(102, 204, 255, 0.08)',
      border: 'rgba(102, 204, 255, 0.45)',
      badge: 'INFO'
    };
  };

  const buttonStyle = {
    fontSize: '11px',
    padding: '4px 8px',
    borderRadius: '6px',
    border: '1px solid rgba(255,255,255,0.2)',
    cursor: 'pointer'
  };

  const grouped = groupBySeverity(data.guidance || []);
  const total = data.guidance?.length || 0;

  const getSignalKey = (signal: any) =>
    [
      signal?.type || '',
      signal?.subsystem || '',
      signal?.message || '',
      signal?.suggested_action || ''
    ].join('::');

  const rawSignals = coherenceData?.raw || [];
  const coherentSignals = coherenceData?.coherent || [];
  const coherentKeys = new Set(coherentSignals.map(getSignalKey));
  const rawKeys = new Set(rawSignals.map(getSignalKey));

  const retainedSignals = rawSignals.filter((signal: any) => coherentKeys.has(getSignalKey(signal)));
  const collapsedSignals = rawSignals.filter((signal: any) => !coherentKeys.has(getSignalKey(signal)));
  const introducedSignals = coherentSignals.filter((signal: any) => !rawKeys.has(getSignalKey(signal)));

  const diffSummary = {
    retained: retainedSignals.length,
    collapsed: collapsedSignals.length,
    introduced: introducedSignals.length
  };

  const renderDiffSignals = (label: string, items: any[]) => {
    if (!items.length) {
      return (
        <div style={{ marginTop: '4px', opacity: 0.62 }}>
          {label}: none
        </div>
      );
    }

    return (
      <div style={{ marginTop: '6px' }}>
        <div style={{ fontWeight: 700 }}>{label}: {items.length}</div>
        {items.slice(0, 3).map((signal: any, i: number) => (
          <div
            key={`${label}-${i}`}
            style={{
              marginTop: '4px',
              padding: '5px 7px',
              borderRadius: '7px',
              background: 'rgba(255,255,255,0.05)',
              opacity: 0.82
            }}
          >
            <span style={{ fontWeight: 700 }}>{signal?.subsystem || 'unknown'}:</span>{' '}
            {signal?.message || 'No message'}
          </div>
        ))}
      </div>
    );
  };

  const renderGroup = (label: string, items: any[], emphasis: number) => {
    if (items.length === 0) return null;

    return (
      <div style={{ marginTop: `${10 + emphasis * 4}px` }}>
        <div
          style={{
            fontWeight: 700,
            fontSize: emphasis > 1 ? '14px' : '13px',
            opacity: 0.85 + emphasis * 0.05,
            letterSpacing: '0.04em'
          }}
        >
          {label} ({items.length})
        </div>

        {items.map((g, i) => {
          const severity = getSeverityStyle(g.type);

          return (
            <div
              key={i}
              style={{
                marginTop: '8px',
                padding: emphasis > 1 ? '10px 12px' : '8px 10px',
                borderLeft: `4px solid ${severity.color}`,
                border: `1px solid ${severity.border}`,
                borderRadius: '10px',
                background: severity.background,
                fontSize: '13px'
              }}
            >
              <div style={{ display: 'flex', alignItems: 'center', gap: '8px', marginBottom: '6px' }}>
                <span
                  style={{
                    color: severity.color,
                    border: `1px solid ${severity.border}`,
                    borderRadius: '999px',
                    padding: '2px 7px',
                    fontSize: '10px',
                    fontWeight: 800,
                    letterSpacing: '0.05em'
                  }}
                >
                  {severity.badge}
                </span>
                <span style={{ fontWeight: 700 }}>{g.subsystem}</span>
              </div>

              <div style={{ opacity: 0.9, lineHeight: 1.35 }}>{g.message}</div>

              {g.suggested_action && (
                <div
                  style={{
                    marginTop: '8px',
                    padding: '6px 8px',
                    borderRadius: '8px',
                    background: 'rgba(255, 255, 255, 0.06)',
                    fontWeight: 650,
                    opacity: 0.9
                  }}
                >
                  Action: {g.suggested_action}
                </div>
              )}

              <div style={{ marginTop: '8px', display: 'flex', gap: '6px', flexWrap: 'wrap' }}>
                <button onClick={fetchGuidance} style={buttonStyle}>
                  Refresh
                </button>

                {g.suggested_action && (
                  <button onClick={() => copyAction(g.suggested_action)} style={buttonStyle}>
                    Copy Action
                  </button>
                )}

                {g.task_id && (
                  <button
                    onClick={() => retryTask(g.task_id)}
                    style={{
                      ...buttonStyle,
                      border: '1px solid rgba(255, 85, 85, 0.45)'
                    }}
                  >
                    Retry Task
                  </button>
                )}
              </div>
            </div>
          );
        })}
      </div>
    );
  };

  return (
    <div style={panelStyle}>
      <h3 style={headerStyle}>
        Operator Guidance ({total}){' '}
        <span style={{ opacity: 0.7 }}>
          ({isStale ? 'STALE' : 'LIVE'})
        </span>
      </h3>

      <div style={sectionStyle}>
        <strong>Subsystem Context</strong>
        {data.subsystems?.map((s: any) => (
          <StatusRow
            key={s.name}
            label={s.name}
            status={s.status}
            connected={s.connected}
          />
        ))}
      </div>

      <div style={sectionStyle}>
        <strong>Coherence Preview</strong>
        <div style={{ marginTop: '8px', fontSize: '12px', opacity: 0.82, lineHeight: 1.45 }}>
          {coherenceData ? (
            <>
              <div>Mode: {coherenceData.mode || 'coherence-shadow'}</div>
              <div>Raw signals: {coherenceData.raw?.length ?? 0}</div>
              <div>Coherent signals: {coherenceData.coherent?.length ?? 0}</div>
              <div>Source: {coherenceData.source || 'unknown'}</div>

              <div style={{ marginTop: '10px', paddingTop: '8px', borderTop: '1px solid rgba(255,255,255,0.12)' }}>
                <div style={{ fontWeight: 800, marginBottom: '4px' }}>Raw vs Coherent Diff</div>
                <div>Retained: {diffSummary.retained}</div>
                <div>Collapsed: {diffSummary.collapsed}</div>
                <div>Introduced: {diffSummary.introduced}</div>
                {renderDiffSignals('Collapsed signals', collapsedSignals)}
                {renderDiffSignals('Introduced coherent signals', introducedSignals)}
              </div>
            </>
          ) : (
            <div>Coherence preview unavailable.</div>
          )}
        </div>
      </div>

      <div style={sectionStyle}>
        <strong>Guidance</strong>
        {retryStatus && (
          <div style={{ marginTop: '6px', fontSize: '11px', opacity: 0.7 }}>
            Retry Status: {retryStatus}
          </div>
        )}
        {data.guidance_available ? (
          <>
            {renderGroup('CRITICAL', grouped.critical, 2)}
            {renderGroup('WARNING', grouped.warning, 1)}
            {renderGroup('INFO', grouped.info, 0)}
          </>
        ) : (
          <div style={{ marginTop: '8px', opacity: 0.8, fontWeight: 600 }}>
            All systems operating normally.
          </div>
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
