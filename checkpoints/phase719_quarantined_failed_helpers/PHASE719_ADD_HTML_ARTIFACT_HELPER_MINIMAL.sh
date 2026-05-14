
#!/usr/bin/env bash

set -euo pipefail

echo "===== PHASE 719: ADD HTML ARTIFACT HELPER MINIMAL ====="

mkdir -p checkpoints

BRANCH="$(git branch --show-current)"

WORKER="server/worker/phase26_task_worker.mjs"

ROUTE="server/routes/api-tasks-postgres.mjs"

FRONTEND="public/js/phase530_visible_panels_bridge.js"

OUT="checkpoints/PHASE719_HTML_ARTIFACT_HELPER_MINIMAL_VERIFY.txt"

cp "$WORKER" checkpoints/PHASE719_WORKER_PRE_HTML_HELPER_MINIMAL.mjs

cp "$ROUTE" checkpoints/PHASE719_ROUTE_PRE_HTML_HELPER_MINIMAL.mjs

cp "$FRONTEND" checkpoints/PHASE719_PHASE530_PRE_HTML_HELPER_MINIMAL.js

python3 - << 'PY'

from pathlib import Path

path = Path("server/worker/phase26_task_worker.mjs")

text = path.read_text()

anchor = "    function persistTaskArtifact({ task, completed, executionResult }) {"

helper = r'''

    function phase719EscapeArtifactHtml(value) {

      return String(value ?? "")

        .replace(/&/g, "&amp;")

        .replace(/</g, "&lt;")

        .replace(/>/g, "&gt;")

        .replace(/"/g, "&quot;")

        .replace(/'/g, "&#039;");

    }

    function phase719WriteHtmlArtifact({ artifactDir, filename, task, completed, executionResult }) {

      const htmlFilename = filename.replace(/\.md$/, ".html");

      const htmlPath = path.join(artifactDir, htmlFilename);

      const title = String(task?.title ?? task?.payload?.title ?? completed?.task_id ?? "Task Artifact");

      const outcome = String(executionResult?.communicationResult?.outcome?.content ?? "No outcome content available.");

      const explanation = String(executionResult?.communicationResult?.explanation?.content ?? "No explanation available.");

      const taskId = String(completed?.task_id ?? task?.task_id ?? "");

      const runId = String(completed?.run_id ?? task?.run_id ?? "");

      const status = String(completed?.status ?? "completed");

      const html = `<!doctype html>

<html lang="en">

<head>

<meta charset="utf-8">

<meta name="viewport" content="width=device-width,initial-scale=1">

<title>${phase719EscapeArtifactHtml(title)}</title>

<style>

*{box-sizing:border-box}body{margin:0;min-height:100vh;padding:44px;background:radial-gradient(circle at 16% 12%,rgba(59,130,246,.24),transparent 32%),linear-gradient(180deg,#020617,#0f172a);color:#f8fafc;font-family:Inter,ui-sans-serif,system-ui,-apple-system,BlinkMacSystemFont,"Segoe UI",sans-serif}.artifact{max-width:980px;margin:0 auto;border:1px solid rgba(148,163,184,.22);border-radius:30px;overflow:hidden;background:linear-gradient(180deg,rgba(15,23,42,.97),rgba(2,6,23,.92));box-shadow:0 34px 100px rgba(0,0,0,.54),inset 0 1px 0 rgba(255,255,255,.05)}.hero{padding:38px 42px 30px;border-bottom:1px solid rgba(148,163,184,.16)}.chips{display:flex;gap:10px;flex-wrap:wrap;margin-bottom:24px}.chip{border:1px solid rgba(147,197,253,.34);background:rgba(30,64,175,.22);color:#bfdbfe;border-radius:999px;padding:7px 12px;font-size:12px;font-weight:900;text-transform:uppercase;letter-spacing:.09em}.chip.done{border-color:rgba(134,239,172,.38);background:rgba(20,83,45,.22);color:#bbf7d0}h1{font-size:clamp(36px,6vw,62px);line-height:.96;letter-spacing:-.06em;margin:0 0 16px}.subtitle{color:#cbd5e1;font-size:18px;line-height:1.55;max-width:760px}.grid{display:grid;grid-template-columns:minmax(0,1.2fr) minmax(240px,.8fr);gap:22px;padding:28px}.card{min-height:180px;border:1px solid rgba(96,165,250,.24);border-radius:22px;background:rgba(15,23,42,.72);padding:24px}.card.alt{border-color:rgba(45,212,191,.22);background:rgba(6,78,59,.16)}.label{font-size:12px;text-transform:uppercase;letter-spacing:.18em;font-weight:950;color:#93c5fd;margin-bottom:14px}.alt .label{color:#5eead4}.body{color:#e0f2fe;font-size:20px;line-height:1.55;font-weight:700}.alt .body{color:#ccfbf1;font-size:16px;font-weight:600}.footer{padding:0 28px 28px;color:#64748b;font-size:12px}

</style>

</head>

<body>

<main class="artifact">

<section class="hero"><div class="chips"><span class="chip done">${phase719EscapeArtifactHtml(status)}</span><span class="chip">HTML Artifact</span></div><h1>${phase719EscapeArtifactHtml(title)}</h1><div class="subtitle">This is the worker-authored HTML artifact rendered directly inside Preview.</div></section>

<section class="grid"><article class="card"><div class="label">Outcome</div><div class="body">${phase719EscapeArtifactHtml(outcome)}</div></article><article class="card alt"><div class="label">Build Path</div><div class="body">${phase719EscapeArtifactHtml(explanation)}</div></article></section>

<section class="footer">task_id: ${phase719EscapeArtifactHtml(taskId)} &nbsp; run_id: ${phase719EscapeArtifactHtml(runId)}</section>

</main>

</body>

</html>`;

      fs.writeFileSync(htmlPath, html, "utf8");

      return {

        type: "html",

        filename: htmlFilename,

        path: htmlPath,

        size_bytes: Buffer.byteLength(html, "utf8"),

        created_at: new Date().toISOString(),

        source: "worker"

      };

    }

'''

if "function phase719WriteHtmlArtifact" not in text:

    if anchor not in text:

        raise SystemExit("persistTaskArtifact anchor not found")

    text = text.replace(anchor, helper + anchor, 1)

old_tail = '''      return {

        type: "markdown",

        filename,

        path: artifactPath,

        size_bytes: Buffer.byteLength(content, "utf8"),

        created_at: new Date().toISOString(),

        source: "worker"

      };'''

new_tail = '''      const artifact = {

        type: "markdown",

        filename,

        path: artifactPath,

        size_bytes: Buffer.byteLength(content, "utf8"),

        created_at: new Date().toISOString(),

        source: "worker"

      };

      const htmlArtifact = phase719WriteHtmlArtifact({ artifactDir, filename, task, completed, executionResult });

      return { ...htmlArtifact, fallback: artifact };'''

if old_tail not in text:

    old_tail = '''      return {

        type: "markdown",

        filename,

        path: artifactPath,

        size_bytes: Buffer.byteLength(content, "utf8"),

        created_at: new Date().toISOString(),

        source: "worker"

      };'''

    new_tail = '''      const artifact = {

        type: "markdown",

        filename,

        path: artifactPath,

        size_bytes: Buffer.byteLength(content, "utf8"),

        created_at: new Date().toISOString(),

        source: "worker"

      };

      const htmlArtifact = phase719WriteHtmlArtifact({ artifactDir, filename, task, completed, executionResult });

      return { ...htmlArtifact, fallback: artifact };'''

if old_tail not in text:

    raise SystemExit("markdown artifact return tail not found")

text = text.replace(old_tail, new_tail, 1)

old_payload = "          artifacts: [artifact]"

new_payload = "          artifacts: artifact?.fallback ? [artifact, artifact.fallback] : [artifact]"

if old_payload not in text:

    raise SystemExit("artifact payload array line not found")

text = text.replace(old_payload, new_payload, 1)

path.write_text(text)

PY

python3 - << 'PY'

from pathlib import Path

path = Path("server/routes/api-tasks-postgres.mjs")

text = path.read_text()

old = '''      const artifact =

        row.artifact ||

        (Array.isArray(row.artifacts) ? row.artifacts[0] : null);'''

new = '''      const artifacts = Array.isArray(row.artifacts) ? row.artifacts : [];

      const artifact =

        artifacts.find((item) => item && item.type === "html") ||

        row.artifact ||

        artifacts[0] ||

        null;'''

if old not in text:

    old = '''      const artifact =

        row.artifact ||

        (Array.isArray(row.artifacts) ? row.artifacts[0] : null);'''

if old not in text:

    raise SystemExit("route artifact selection block not found")

text = text.replace(old, new, 1)

old_response = '''        artifact: {

          filename: artifact.filename || path.basename(filePath),

          type: artifact.type || "artifact",

          size_bytes: stat.size,

          created_at: artifact.created_at || null,

        },

        content,'''

new_response = '''        artifact: {

          filename: artifact.filename || path.basename(filePath),

          type: artifact.type || "artifact",

          size_bytes: stat.size,

          created_at: artifact.created_at || null,

        },

        render_mode: artifact.type === "html" ? "html" : "markdown",

        content,'''

if old_response not in text:

    raise SystemExit("route content response block not found")

text = text.replace(old_response, new_response, 1)

path.write_text(text)

PY

python3 - << 'PY'

from pathlib import Path

path = Path("public/js/phase530_visible_panels_bridge.js")

text = path.read_text()

marker = "  function phase719RenderMarkdownArtifactPreview(markdown) {"

helper = r'''

  function phase719RenderHtmlArtifactPreview(html) {

    return `

      <iframe

        title="Rendered artifact"

        data-phase719-html-artifact-preview="true"

        sandbox=""

        srcdoc="${phase719EscapePreviewHtml(html)}"

        style="width:100%;min-height:620px;border:1px solid rgba(148,163,184,.24);border-radius:18px;background:#020617;box-shadow:0 22px 70px rgba(0,0,0,.36);"

      ></iframe>

    `;

  }

'''

if helper not in text:

    if marker not in text:

        raise SystemExit("markdown renderer marker not found")

    text = text.replace(marker, helper + marker, 1)

old = "      body.innerHTML = phase719RenderMarkdownArtifactPreview(data.content);"

new = '''      if (data.render_mode === "html" || (artifact.type || "").toLowerCase() === "html") {

        body.innerHTML = phase719RenderHtmlArtifactPreview(data.content);

      } else {

        body.innerHTML = phase719RenderMarkdownArtifactPreview(data.content);

      }'''

if old not in text:

    raise SystemExit("frontend markdown render assignment not found")

text = text.replace(old, new, 1)

path.write_text(text)

PY

node --check "$WORKER"

node --check "$ROUTE"

node --check "$FRONTEND"

cp "$WORKER" checkpoints/PHASE719_WORKER_POST_HTML_HELPER_MINIMAL.mjs

cp "$ROUTE" checkpoints/PHASE719_ROUTE_POST_HTML_HELPER_MINIMAL.mjs

cp "$FRONTEND" checkpoints/PHASE719_PHASE530_POST_HTML_HELPER_MINIMAL.js

docker compose up -d --build worker dashboard

sleep 6

cat > /tmp/phase719_html_helper_minimal_body.json << 'JSON'

{"title":"Phase 719 HTML helper validation: direct embedded artifact preview","agent":"cade","source":"phase719-html-helper-minimal"}

JSON

CREATE_RESPONSE="$(curl -sS --max-time 15 -X POST 'http://localhost:3000/api/tasks/create' -H 'Content-Type: application/json' --data-binary @/tmp/phase719_html_helper_minimal_body.json || true)"

printf '%s\n' "$CREATE_RESPONSE" > checkpoints/PHASE719_HTML_HELPER_MINIMAL_CREATE_RESPONSE.json

TASK_ID="$(printf '%s' "$CREATE_RESPONSE" | python3 -c 'import json,sys

try:

    print(json.load(sys.stdin).get("task_id",""))

except Exception:

    print("")

')"

sleep 8

{

  echo "RUNTIME HEALTH"

  curl -i -s --max-time 10 'http://localhost:3000/api/tasks/health' || true

  echo ""

  echo "TASK_ID"

  echo "$TASK_ID"

  echo ""

  echo "ARTIFACT FILES"

  docker exec motherboard_systems_hq-dashboard-1 sh -lc 'find /app/data/artifacts -maxdepth 1 -type f -print 2>/dev/null | sort | tail -20' || true

  echo ""

  echo "TASK API HTML ARTIFACT PRESENCE"

  curl -s --max-time 10 'http://localhost:3000/api/tasks?limit=5' | grep -o '"type":"html"' | head || true

  echo ""

  echo "PREVIEW ROUTE"

  if [ -n "$TASK_ID" ]; then

    curl -i -s --max-time 10 "http://localhost:3000/api/tasks/$TASK_ID/artifact-preview" | head -n 100 || true

  else

    echo "No task id."

  fi

  echo ""

  echo "FRONTEND HTML RENDER MARKERS"

  curl -s --max-time 10 'http://localhost:3000/js/phase530_visible_panels_bridge.js' | grep -nE 'phase719RenderHtmlArtifactPreview|data-phase719-html-artifact-preview|render_mode' | head -n 50 || true

  echo ""

  echo "DASHBOARD LOGS"

  docker logs --tail 120 motherboard_systems_hq-dashboard-1 || true

  echo ""

  echo "WORKER LOGS"

  docker logs --tail 120 motherboard_systems_hq-worker-1 || true

} | tee "$OUT"

git add "$WORKER" "$ROUTE" "$FRONTEND"

git add PHASE719_ADD_HTML_ARTIFACT_HELPER_MINIMAL.sh

git add checkpoints/PHASE719_WORKER_PRE_HTML_HELPER_MINIMAL.mjs

git add checkpoints/PHASE719_ROUTE_PRE_HTML_HELPER_MINIMAL.mjs

git add checkpoints/PHASE719_PHASE530_PRE_HTML_HELPER_MINIMAL.js

git add checkpoints/PHASE719_WORKER_POST_HTML_HELPER_MINIMAL.mjs

git add checkpoints/PHASE719_ROUTE_POST_HTML_HELPER_MINIMAL.mjs

git add checkpoints/PHASE719_PHASE530_POST_HTML_HELPER_MINIMAL.js

git add checkpoints/PHASE719_HTML_HELPER_MINIMAL_CREATE_RESPONSE.json

git add "$OUT"

git commit -m "Phase 719: add HTML artifact helper and direct preview rendering"

git push origin "$BRANCH"

echo "===== HTML ARTIFACT HELPER MINIMAL COMPLETE ====="

