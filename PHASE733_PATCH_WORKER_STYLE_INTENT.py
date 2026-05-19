
from pathlib import Path

path = Path("server/worker/phase26_task_worker.mjs")

text = path.read_text()

anchor = '''      const artifactNextSteps = [

        "Confirm the artifact content matches the operator intent.",

        "If richer deliverable content is needed, refine the worker artifact contract before expanding renderer behavior."

      ].join("\\n");

'''

helper = '''      function extractPhase733StyleIntent(sourceText) {

        const source = String(sourceText || "");

        const start = source.match(/style_intent\\s*:\\s*/i);

        if (!start) return null;

        const after = source.slice(start.index + start[0].length);

        const styleIntent = {};

        const allowedKeys = new Set([

          "mood",

          "background",

          "card",

          "text",

          "secondary_text",

          "accent",

          "typography",

          "shadow",

          "density"

        ]);

        for (const rawLine of after.split(/\\r?\\n/)) {

          const line = rawLine.trim();

          if (!line) continue;

          if (/^(hard constraints|content|required visible labels|success criteria)\\s*:?$/i.test(line)) break;

          const match = line.match(/^([a-z_]+)\\s*:\\s*(.+)$/i);

          if (!match) continue;

          const key = match[1].trim().toLowerCase();

          const value = match[2].trim();

          if (allowedKeys.has(key) && value) {

            styleIntent[key] = value.slice(0, 160);

          }

        }

        return Object.keys(styleIntent).length ? styleIntent : null;

      }

      const phase733StyleIntent = extractPhase733StyleIntent(taskTitle);

'''

if anchor not in text:

    raise SystemExit("Style intent insertion anchor not found")

text = text.replace(anchor, anchor + helper, 1)

old = '''          evidence_notes: artifactDetails

            .split("\\n")

            .map((line) => line.trim())

            .filter(Boolean),

          operator_next_steps: artifactNextSteps,

          raw_markdown_fallback: true'''

new = '''          evidence_notes: artifactDetails

            .split("\\n")

            .map((line) => line.trim())

            .filter(Boolean),

          ...(phase733StyleIntent ? { style_intent: phase733StyleIntent } : {}),

          operator_next_steps: artifactNextSteps,

          raw_markdown_fallback: true'''

if old not in text:

    raise SystemExit("Semantic envelope insertion point not found")

text = text.replace(old, new, 1)

path.write_text(text)

