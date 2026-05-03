from pathlib import Path

target = Path("server.mjs")
text = target.read_text()

import_line = 'import { ensureTasksRunIdColumn } from "./server/db_bootstrap_tasks_run_id_column.mjs";\n'
if import_line not in text:
    anchor = 'import { ensureTasksTaskIdColumn } from "./server/db_bootstrap_tasks_task_id.mjs";\n'
    if anchor in text:
        text = text.replace(anchor, anchor + import_line, 1)
    else:
        raise SystemExit("Could not find import anchor for ensureTasksTaskIdColumn")

call_line = "await ensureTasksRunIdColumn(pool);\n"
if call_line not in text:
    anchor = "await ensureTasksTaskIdColumn(pool);\n"
    if anchor in text:
        text = text.replace(anchor, anchor + call_line, 1)
    else:
        raise SystemExit("Could not find bootstrap call anchor for ensureTasksTaskIdColumn(pool)")

target.write_text(text)
print("Patched server.mjs to bootstrap tasks.run_id column")
