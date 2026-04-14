from pathlib import Path

target = Path("server.mjs")
text = target.read_text()

import_line = 'import { ensureTasksKindColumn } from "./server/db_bootstrap_tasks_kind_column.mjs";\n'
if import_line not in text:
    anchor = 'import { ensureTasksActionTierColumn } from "./server/db_bootstrap_tasks_action_tier_column.mjs";\n'
    if anchor in text:
        text = text.replace(anchor, anchor + import_line, 1)
    else:
        raise SystemExit("Could not find import anchor for ensureTasksActionTierColumn")

call_line = "await ensureTasksKindColumn(pool);\n"
if call_line not in text:
    anchor = "await ensureTasksActionTierColumn(pool);\n"
    if anchor in text:
        text = text.replace(anchor, anchor + call_line, 1)
    else:
        raise SystemExit("Could not find bootstrap call anchor for ensureTasksActionTierColumn(pool)")

target.write_text(text)
print("Patched server.mjs to bootstrap tasks.kind column")
