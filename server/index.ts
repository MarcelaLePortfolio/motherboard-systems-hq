
import express from "express";

const app = express();

/**

 * Compatibility middleware

 */

const apiCompat = (_req: any, _res: any, next: any) => next();

/**

 * Root redirect

 */

function mountRootRedirect(app: any) {

  app.get("/", (_req: any, res: any) => {

    res.redirect("/ui");

  });

}

/**

 * OPERATOR COCKPIT UI (STATIC SHELL)

 */

function mountMinimalUI(app: any) {

  app.get("/ui", (_req: any, res: any) => {

    res.send(`

      <html>

        <head>

          <title>Operator Cockpit</title>

          <style>

            body {

              margin: 0;

              font-family: ui-sans-serif, system-ui;

              background: #0b1220;

              color: #e6edf3;

            }

            .topbar {

              display: flex;

              justify-content: space-between;

              padding: 12px 16px;

              background: #0f172a;

              border-bottom: 1px solid #1f2a44;

              font-size: 13px;

            }

            .status {

              color: #4ade80;

            }

            .grid {

              display: grid;

              grid-template-columns: 1fr 1fr;

              height: calc(100vh - 120px);

            }

            .panel {

              border-right: 1px solid #1f2a44;

              padding: 12px;

              overflow: hidden;

            }

            .right {

              border-right: none;

            }

            .tabs {

              display: flex;

              gap: 8px;

              margin-bottom: 10px;

              font-size: 12px;

              opacity: 0.8;

            }

            .box {

              height: 100%;

              border: 1px dashed #24314f;

              border-radius: 10px;

              padding: 12px;

              color: #93a4c7;

            }

            .atlas {

              height: 60px;

              border-top: 1px solid #1f2a44;

              display: flex;

              align-items: center;

              padding: 0 16px;

              font-size: 12px;

              color: #93a4c7;

            }

          </style>

        </head>

        <body>

          <div class="topbar">

            <div>Project Switcher → Motherboard Systems HQ</div>

            <div class="status">● Stable</div>

          </div>

          <div class="grid">

            <div class="panel">

              <div class="tabs">Chat | Delegation | Guidance</div>

              <div class="box">

                OPERATOR WORKSPACE<br/><br/>

                Chat stream (empty)<br/>

                Delegation (empty)<br/>

                Guidance (optional)

              </div>

            </div>

            <div class="panel right">

              <div class="tabs">Telemetry Console</div>

              <div class="box">

                TELEMETRY PIPELINE<br/><br/>

                No active execution stream<br/>

                Waiting for events...

              </div>

            </div>

          </div>

          <div class="atlas">

            ATLAS SUBSYSTEM STATE — Memory: Healthy | Graph: Synced | Lineage: Active

          </div>

        </body>

      </html>

    `);

  });

}

/**

 * SSE router stub

 */

function sseRouter(_app: any) {}

/**

 * SSE emitter stub

 */

export function emitSSE(_event: string, _payload: any) {}

app.use(express.json());

app.use(apiCompat);

mountRootRedirect(app);

mountMinimalUI(app);

sseRouter(app);

const PORT = process.env.PORT || 3000;

app.listen(PORT, () => {

  console.log(`Server running on port ${PORT}`);

});

