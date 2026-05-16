
from pathlib import Path

path = Path("server/routes/api-tasks-postgres.mjs")

text = path.read_text()

old = '''    const b = _asJson(req);

    let run_id = b.run_id ?? b.runId ?? null;

'''

new = '''    const b = _asJson(req);

    const taskTitle = (

      b.title ??

      b.description ??

      b.prompt ??

      b.input ??

      b.message ??

      b.task ??

      b.payload?.title ??

      b.payload?.description ??

      b.payload?.prompt ??

      b.payload?.input ??

      b.payload?.message ??

      b.payload?.task ??

      null

    );

    let run_id = b.run_id ?? b.runId ?? null;

'''

if old not in text:

    raise SystemExit("Could not find create-route body insertion point.")

text = text.replace(old, new, 1)

text = text.replace("        b.title ?? null,\n", "        taskTitle ? String(taskTitle) : null,\n", 1)

text = text.replace("        title: b.title ?? null,\n", "        title: taskTitle ? String(taskTitle) : null,\n", 1)

path.write_text(text)

