#!/usr/bin/env bash
set -euo pipefail

python3 << 'PY'
from pathlib import Path
import re
import sys

path = Path("public/js/agent-status-row.js")
src = path.read_text()

orig = src

src, n1 = re.subn(
    r"const successNode = document\.getElementById\('metric-success'\);",
    "const successNode = document.getElementById('metric-success') || document.getElementById('metric-success-rate');",
    src,
    count=1,
)

if n1 == 0:
    print("warning: success metric hook line not found; continuing", file=sys.stderr)

block_pattern = re.compile(
    r"""(?P<indent>[ \t]*)const connect = \(\) => \{\n(?P<body>.*?)\n(?P=indent)\};\n\n(?P=indent)render\(\);\n(?P=indent)connect\(\);\n(?P=indent)window\.setInterval\(render, 10000\);""",
    re.DOTALL,
)

replacement = """    const bootstrapFromTasks = async () => {
      try {
        const res = await fetch('/api/tasks?limit=200', {
          headers: { Accept: 'application/json' },
          cache: 'no-store'
        });

        if (!res.ok) {
          render();
          return;
        }

        const parsed = await res.json().catch(() => null);
        const rows = Array.isArray(parsed)
          ? parsed
          : Array.isArray(parsed?.tasks)
            ? parsed.tasks
            : Array.isArray(parsed?.rows)
              ? parsed.rows
              : [];

        rows.forEach((row) => {
          const taskId = getTaskId(row);
          const status = normalize(
            row?.status ??
            row?.task_status ??
            row?.state ??
            row?.payload?.status
          );

          if (!taskId || !status) return;

          if (runningTypes.has(status)) {
            runningTaskIds.add(taskId);
            if (!taskStartTimes.has(taskId)) {
              taskStartTimes.set(taskId, getEventTs(row));
            }
            return;
          }

          if (terminalSuccessTypes.has(status)) {
            completedCount += 1;
            return;
          }

          if (terminalFailureTypes.has(status)) {
            failedCount += 1;
          }
        });
      } catch {
        // fail closed to live SSE only
      }

      render();
    };

    const connect = () => {
      let es;
      try {
        es = new EventSource('/events/task-events');
      } catch {
        render();
        return;
      }

      es.onmessage = (evt) => ingestMessage(evt.data);

      [
        ...runningTypes,
        ...terminalSuccessTypes,
        ...terminalFailureTypes
      ].forEach((eventName) => attachTypedListener(es, eventName));

      es.onerror = () => render();
      window.addEventListener('beforeunload', () => es.close(), { once: true });
    };

    render();
    bootstrapFromTasks().finally(() => connect());
    window.setInterval(render, 10000);"""

src, n2 = block_pattern.subn(replacement, src, count=1)

if n2 == 0:
    sys.exit("failed: metrics connect/render block not found")

if src == orig:
    print("no source changes were necessary")
else:
    path.write_text(src)
    print("patched public/js/agent-status-row.js")
PY

bash scripts/_local/phase64_7_dashboard_layout_script_mount_guard.sh
bash scripts/_local/phase64_8_pre_push_contract_guard.sh
docker compose build dashboard
docker compose up -d dashboard
bash scripts/_local/phase65_3_metrics_runtime_verify.sh
