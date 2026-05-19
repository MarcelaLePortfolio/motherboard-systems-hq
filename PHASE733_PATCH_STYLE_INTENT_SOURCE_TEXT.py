
from pathlib import Path

path = Path("server/worker/phase26_task_worker.mjs")

text = path.read_text()

old = '      const phase733StyleIntent = extractPhase733StyleIntent(taskTitle);'

new = '''      const phase733StyleIntentSource = [

        taskTitle,

        task?.payload?.title,

        task?.payload?.prompt,

        task?.payload?.description,

        task?.payload?.body,

        task?.payload?.input,

        task?.payload?.request,

        task?.payload?.task,

        typeof task?.payload === "string" ? task.payload : "",

      ].filter(Boolean).join("\\n");

      const phase733StyleIntent = extractPhase733StyleIntent(phase733StyleIntentSource);'''

if old not in text:

    raise SystemExit("target source-text line not found")

path.write_text(text.replace(old, new))

print("patched style intent extraction source text")

