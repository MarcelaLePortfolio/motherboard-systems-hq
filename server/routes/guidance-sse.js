/**
 * PHASE 641 — GUIDANCE SSE STREAM (READ-ONLY)
 */

function buildGuidanceSnapshot() {
  return {
    ok: true,
    guidance_available: false, // preserve existing logic externally
    guidance: [],
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
