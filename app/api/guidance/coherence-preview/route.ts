import { NextResponse } from 'next/server';
import deriveCoherentGuidance from '../../../../server/guidance/coherence-adapter.mjs';

export async function GET() {
  const sampleHistory = [
    {
      timestamp: new Date(Date.now() - 120000).toISOString(),
      taskId: 'preview-task',
      source: 'operator-guidance',
      type: 'duplicate-risk',
      severity: 'warning',
      summary: 'Preview duplicate guidance signal',
    },
    {
      timestamp: new Date(Date.now() - 60000).toISOString(),
      taskId: 'preview-task',
      source: 'operator-guidance',
      type: 'duplicate-risk',
      severity: 'warning',
      summary: 'Preview duplicate guidance signal',
    },
    {
      timestamp: new Date().toISOString(),
      taskId: 'preview-task',
      source: 'operator-guidance',
      type: 'duplicate-risk',
      severity: 'warning',
      summary: 'Preview duplicate guidance signal',
    },
  ];

  const coherent = deriveCoherentGuidance(sampleHistory);

  return NextResponse.json({
    phase: '674',
    mode: 'coherence-preview',
    runtimeImpact: {
      execution: false,
      sse: false,
      ui: false,
      formatting: false,
    },
    coherent,
  });
}
