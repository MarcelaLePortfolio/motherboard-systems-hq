
from pathlib import Path

from datetime import datetime

OUTPUT = Path("ACTIVE_CADE_RUNTIME_REFERENCE_AUDIT.txt")

EXCLUDED_DIRS = {

    ".git",

    "node_modules",

    "backups",

    "scripts_backup_2",

    "_archive",

    "dist",

}

EXCLUDED_FILES = {

    "CADE_RUNTIME_DISCOVERY.txt",

    "CADE_RUNTIME_HIGH_SIGNAL_CONTENTS.txt",

    "ACTIVE_CADE_RUNTIME_REFERENCE_AUDIT.txt",

}

TARGETS = [

    "cade_task_processor",

    "cade_task_processor_clean",

    "cade-processor",

    "launch-cade",

    "cade-delegation-watcher",

    "agent-to-cade",

    "routeTask",

    "createAgentRuntime",

    "run_shell",

    "delegateToCadeV2",

]

def is_excluded(path: Path) -> bool:

    parts = set(path.parts)

    if parts & EXCLUDED_DIRS:

        return True

    if path.name in EXCLUDED_FILES:

        return True

    if path.suffix == ".log":

        return True

    return False

def read_text(path: Path) -> str:

    try:

        return path.read_text(errors="ignore")

    except Exception:

        return ""

files = [

    path

    for path in Path(".").rglob("*")

    if path.is_file() and not is_excluded(path)

]

lines = []

lines.append("ACTIVE CADE RUNTIME REFERENCE AUDIT")

lines.append(f"Generated: {datetime.now().isoformat()}")

lines.append("")

for target in TARGETS:

    lines.append("==================================================================")

    lines.append(f"TARGET: {target}")

    lines.append("==================================================================")

    lines.append("")

    matches = []

    for path in files:

        text = read_text(path)

        if target not in text:

            continue

        for index, line in enumerate(text.splitlines(), start=1):

            if target in line:

                matches.append(f"{path}:{index}:{line}")

    if matches:

        lines.extend(matches)

    else:

        lines.append("(no references found)")

    lines.append("")

lines.append("==================================================================")

lines.append("PACKAGE SCRIPTS")

lines.append("==================================================================")

lines.append("")

package_json = Path("package.json")

if package_json.exists():

    text = read_text(package_json)

    capture = False

    depth = 0

    for line in text.splitlines():

        if '"scripts"' in line:

            capture = True

        if capture:

            lines.append(line)

            depth += line.count("{")

            depth -= line.count("}")

            if depth <= 0 and "}" in line:

                break

OUTPUT.write_text("\n".join(lines) + "\n")

print(OUTPUT.read_text())

