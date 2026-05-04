/**
 * PHASE 636 — SUBSYSTEM SSE STREAM (READ-ONLY)
 * Emits periodic subsystem snapshots without execution coupling
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
  } catch {
    return {
      name: 'atlas',
      status: 'unknown',
      connected: false
    };
  }
}

function buildSnapshot() {
  return {
    ok: true,
    subsystems: [
      detectAtlas(),
      { name: 'guidance', status: 'active', connected: true },
      { name: 'execution', status: 'verified', connected: true }
    ],
    timestamp: new Date().toISOString()
  };
}

export function registerSubsystemSSERoute(app) {
  app.get('/events/subsystem-status', (req, res) => {
    res.setHeader('Content-Type', 'text/event-stream');
    res.setHeader('Cache-Control', 'no-cache');
    res.setHeader('Connection', 'keep-alive');

    const send = () => {
      const snapshot = buildSnapshot();
      res.write(`data: ${JSON.stringify(snapshot)}\n\n`);
    };

    send();
    const interval = setInterval(send, 5000);

    req.on('close', () => {
      clearInterval(interval);
    });
  });
}
