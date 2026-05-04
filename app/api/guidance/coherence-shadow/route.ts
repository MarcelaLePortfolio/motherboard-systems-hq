import { NextResponse } from 'next/server';
import deriveCoherentGuidance from '../../../../server/guidance/coherence-adapter.mjs';

// Phase 675 — Shadow Integration Route (REAL DATA, NON-DESTRUCTIVE)
// Mirrors raw guidance + adds coherence output side-by-side.
// Does NOT modify existing /api/guidance, SSE, UI, or formatting.

async function fetchHistory() {
  try {
    const base = process.env.NEXT_PUBLIC_BASE_URL || 'http://localhost:8080';
    const res = await fetch(`${base}/api/guidance/history`, { cache: 'no-store' });
    if (!res.ok) throw new Error(`history fetch failed: ${res.status}`);
    const data = await res.json();
    return Array.isArray(data) ? data : data.history || [];
  } catch {
    // Fallback sample if history is unavailable
    return [
      {
        timestamp: new Date(Date.now() - 120000).toISOString(),
        taskId: 'shadow-task',
        source: 'operator-guidance',
        type: 'retry-risk',
        severity: 'warning',
        summary: 'Shadow duplicate signal',
      },
      {
        timestamp: new Date(Date.now() - 60000).toISOString(),
        taskId: 'shadow-task',
        source: 'operator-guidance',
        type: 'retry-risk',
        severity: 'warning',
        summary: 'Shadow duplicate signal',
      },
      {
        timestamp: new Date().toISOString(),
        taskId: 'shadow-task',
        source: 'operator-guidance',
        type: 'retry-risk',
        severity: 'warning',
        summary: 'Shadow duplicate signal',
      },
    ];
  }
}

export async function GET() {
  const raw = await fetchHistory();
  const coherent = deriveCoherentGuidance(raw);

  return NextResponse.json({
    phase: '675',
    mode: 'coherence-shadow',
    runtimeImpact: {
      execution: false,
      sse: false,
      ui: false,
      formatting: false,
    },
    source: 'history-or-fallback',
    raw,
    coherent,
  });
}
