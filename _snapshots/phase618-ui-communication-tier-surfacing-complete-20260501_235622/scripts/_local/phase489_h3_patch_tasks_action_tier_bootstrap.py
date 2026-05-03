from pathlib import Path

target = Path("server.mjs")
text = target.read_text()

import_line = 'import { ensureTasksActionTierColumn } from "./server/db_bootstrap_tasks_action_tier_column.mjs";\n'
if import_line not in text:
    anchor = 'import { ensureTasksRunIdColumn } from "./server/db_bootstrap_tasks_run_id_column.mjs";\n'
    if anchor in text:
        text = text.replace(anchor, anchor + import_line, 1)
    else:
        raise SystemExit("Could not find import anchor for ensureTasksRunIdColumn")

call_line = "await ensureTasksActionTierColumn(pool);\n"
if call_line not in text:
    anchor = "await ensureTasksRunIdColumn(pool);\n"
    if anchor in text:
        text = text.replace(anchor, anchor + call_line, 1)
    else:
        raise SystemExit("Could not find bootstrap call anchor for ensureTasksRunIdColumn(pool)")

target.write_text(text)
print("Patched server.mjs to bootstrap tasks.action_tier column")
