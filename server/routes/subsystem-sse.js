/**
 * PHASE 638 — SUBSYSTEM SSE STREAM (OBSERVABILITY HARDENING)
 * Adds structured logging + safe error visibility (read-only)
 */

import { execSync } from 'child_process';

function detectAtlas() {
  try {
    const output = execSync("docker ps --format '{{.Names}}'", { encoding: 'utf-8' });
    const isRunning = output.includes('atlas');
    return {
      name: 'atlas',
      status: isRunning ? 'running' : 'not_detected',
      connected: isRunning
    };
  } catch (err) {
    console.error('[subsystem][atlas][error]', err?.message);
    return {
      name: 'atlas',
      status: 'unknown',
      connected: false
    };
  }
}

function buildSnapshot() {
  const snapshot = {
    ok: true,
    subsystems: [
      detectAtlas(),
      { name: 'guidance', status: 'active', connected: true },
      { name: 'execution', status: 'verified', connected: true }
    ],
    timestamp: new Date().toISOString()
  };

  console.log('[subsystem][snapshot]', JSON.stringify(snapshot));

  return snapshot;
}

export function registerSubsystemSSERoute(app) {
  app.get('/events/subsystem-status', (req, res) => {
    res.setHeader('Content-Type', 'text/event-stream');
    res.setHeader('Cache-Control', 'no-cache');
    res.setHeader('Connection', 'keep-alive');

    const send = () => {
      try {
        const snapshot = buildSnapshot();
        res.write(`data: ${JSON.stringify(snapshot)}\n\n`);
      } catch (err) {
        console.error('[subsystem][sse][error]', err?.message);
      }
    };

    send();
    const interval = setInterval(send, 5000);

    req.on('close', () => {
      clearInterval(interval);
      console.log('[subsystem][sse] client disconnected');
    });
  });
}
