/**
 * PHASE 650 — GUIDANCE ROUTE WITH INTELLIGENCE (READ-ONLY)
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

export function registerGuidanceRoute(app) {
  app.get('/api/guidance', async (req, res) => {
    try {
      const subsystems = getSubsystemSnapshot();
      const guidance = generateGuidance(subsystems);

      const response = {
        ok: true,
        guidance_available: guidance.length > 0,
        guidance,
        subsystems,
        timestamp: new Date().toISOString()
      };

      res.json(response);
    } catch (err) {
      res.status(500).json({
        ok: false,
        error: 'guidance_failed'
      });
    }
  });
}
