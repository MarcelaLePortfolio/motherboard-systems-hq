import { NextResponse } from 'next/server';
import deriveCoherentGuidance from '../../../../server/guidance/coherence-adapter.mjs';

// Phase 675 — Shadow Integration Route (NON-DESTRUCTIVE)
// This does NOT modify existing /api/guidance behavior.
// It mirrors output + adds coherence layer side-by-side.

export async function GET() {
  const raw = [
    {
      timestamp: new Date(Date.now() - 120000).toISOString(),
      task_id: 'shadow-task',
      subsystem: 'guidance',
      signal_type: 'retry-risk',
      severity: 'warning',
      message: 'Shadow duplicate signal',
    },
    {
      timestamp: new Date(Date.now() - 60000).toISOString(),
      task_id: 'shadow-task',
      subsystem: 'guidance',
      signal_type: 'retry-risk',
      severity: 'warning',
      message: 'Shadow duplicate signal',
    },
    {
      timestamp: new Date().toISOString(),
      task_id: 'shadow-task',
      subsystem: 'guidance',
      signal_type: 'retry-risk',
      severity: 'warning',
      message: 'Shadow duplicate signal',
    },
  ];

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
    raw,
    coherent,
  });
}
