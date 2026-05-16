
from pathlib import Path

import re

path = Path("server/routes/api-tasks-postgres.mjs")

text = path.read_text()

if "const taskTitle = (" not in text:

    text = re.sub(

        r"(    const b = _asJson\(req\);\s*)",

        r"""\1

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

""",

        text,

        count=1,

    )

if "const taskTitle = (" not in text:

    raise SystemExit("Failed to insert taskTitle normalization.")

text = text.replace("        b.title ?? null,\n", "        taskTitle ? String(taskTitle) : null,\n", 1)

text = text.replace("        title: b.title ?? null,\n", "        title: taskTitle ? String(taskTitle) : null,\n", 1)

path.write_text(text)

