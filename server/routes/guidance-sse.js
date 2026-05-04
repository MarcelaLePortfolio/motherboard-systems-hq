/**
 * PHASE 650 — GUIDANCE SSE STREAM WITH INTELLIGENCE (READ-ONLY)
 */

import { execSync } from 'child_process';
import { generateGuidance } from '../lib/guidance-engine.js';

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

function getSubsystemSnapshot() {
  return [
    detectAtlas(),
    { name: 'guidance', status: 'active', connected: true },
    { name: 'execution', status: 'verified', connected: true }
  ];
}

function buildGuidanceSnapshot() {
  const subsystems = getSubsystemSnapshot();
  const guidance = generateGuidance(subsystems);

  return {
    ok: true,
    guidance_available: guidance.length > 0,
    guidance,
    subsystems,
    timestamp: new Date().toISOString()
  };
}

export function registerGuidanceSSERoute(app) {
  app.get('/events/guidance', (req, res) => {
    res.setHeader('Content-Type', 'text/event-stream');
    res.setHeader('Cache-Control', 'no-cache');
    res.setHeader('Connection', 'keep-alive');

    const send = () => {
      try {
        const snapshot = buildGuidanceSnapshot();
        res.write(`data: ${JSON.stringify(snapshot)}\n\n`);
      } catch (err) {
        console.error('[guidance][sse][error]', err?.message);
      }
    };

    send();
    const interval = setInterval(send, 5000);

    req.on('close', () => {
      clearInterval(interval);
      console.log('[guidance][sse] client disconnected');
    });
  });
}
