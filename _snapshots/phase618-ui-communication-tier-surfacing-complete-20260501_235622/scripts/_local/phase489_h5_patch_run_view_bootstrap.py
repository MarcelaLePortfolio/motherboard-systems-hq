from pathlib import Path

target = Path("server.mjs")
text = target.read_text()

import_line = 'import { ensureRunView } from "./server/db_bootstrap_run_view.mjs";\n'
if import_line not in text:
    anchor = 'import { ensureTasksKindColumn } from "./server/db_bootstrap_tasks_kind_column.mjs";\n'
    if anchor in text:
        text = text.replace(anchor, anchor + import_line, 1)
    else:
        raise SystemExit("Could not find import anchor for ensureTasksKindColumn")

call_line = "await ensureRunView(pool);\n"
if call_line not in text:
    anchor = "await ensureTasksKindColumn(pool);\n"
    if anchor in text:
        text = text.replace(anchor, anchor + call_line, 1)
    else:
        raise SystemExit("Could not find bootstrap call anchor for ensureTasksKindColumn(pool)")

target.write_text(text)
print("Patched server.mjs to bootstrap run_view")
