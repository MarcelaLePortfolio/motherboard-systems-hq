/**
 * PHASE 633 — SUBSYSTEM STATUS ENDPOINT (READ-ONLY)
 * Safe: no execution coupling, no mutation
 */

export function registerSubsystemStatusRoute(app) {
  app.get('/api/subsystem-status', async (req, res) => {
    try {
      const status = {
        ok: true,
        subsystems: [
          {
            name: 'atlas',
            status: 'unknown', // placeholder until wiring
            connected: false,
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
