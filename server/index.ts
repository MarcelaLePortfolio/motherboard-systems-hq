
import express from "express";

const app = express();

/**

 * Temporary compatibility middleware (fixes missing apiCompat TS error)

 */

const apiCompat = (_req: any, _res: any, next: any) => next();

/**

 * Root redirect handler (stub replacement for ./routes/root-redirect)

 */

function mountRootRedirect(app: any) {

  app.get("/", (_req: any, res: any) => {

    res.redirect("/ui");

  });

}

/**

 * Minimal UI handler (stub replacement for ./routes/minimal-ui)

 */

function mountMinimalUI(app: any) {

  app.get("/ui", (_req: any, res: any) => {

    res.send(`

      <html>

        <head><title>Motherboard Systems HQ</title></head>

        <body>

          <h1>System Online</h1>

        </body>

      </html>

    `);

  });

}

/**

 * SSE router stub (replacement for ./routes/sse)

 */

function sseRouter(_app: any) {

  // placeholder for SSE endpoints

}

/**

 * SSE event emitter stub (replacement for ./events/sse-bus)

 */

export function emitSSE(_event: string, _payload: any) {

  // no-op stub for compilation

}

app.use(express.json());

app.use(apiCompat);

mountRootRedirect(app);

mountMinimalUI(app);

sseRouter(app);

const PORT = process.env.PORT || 3000;

app.listen(PORT, () => {

  console.log(\`Server running on port \${PORT}\`);

});

