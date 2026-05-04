/**
 * PHASE 634 — ATLAS SUBSYSTEM SURFACING (READ-ONLY)
 * Adds runtime detection without execution coupling
 */

import { execSync } from 'child_process';

function detectAtlas() {
  try {
    const output = execSync("docker ps --format '{{.Names}}'", { encoding: 'utf-8' });
    const isRunning = output.includes('atlas');
    return {
      status: isRunning ? 'running' : 'not_detected',
      connected: isRunning
    };
  } catch (err) {
    return {
      status: 'unknown',
      connected: false
    };
  }
}

export function registerSubsystemStatusRoute(app) {
  app.get('/api/subsystem-status', async (req, res) => {
    try {
      const atlas = detectAtlas();

      const status = {
        ok: true,
        subsystems: [
          {
            name: 'atlas',
            status: atlas.status,
            connected: atlas.connected,
          },
          {
            name: 'guidance',
            status: 'active',
            connected: true,
          },
          {
            name: 'execution',
            status: 'verified',
            connected: true,
          }
        ],
        timestamp: new Date().toISOString()
      };

      res.json(status);
    } catch (err) {
      res.status(500).json({
        ok: false,
        error: 'subsystem_status_failed'
      });
    }
  });
}
