
from pathlib import Path

import re

targets = [

    Path("public/index.html"),

    Path("public/dashboard.html"),

]

for path in targets:

    if not path.exists():

        continue

    text = path.read_text(encoding="utf-8")

    text = text.replace("grid-template-rows:1fr 1fr", "grid-template-rows:1fr")

    text = text.replace("grid-template-rows: 1fr 1fr", "grid-template-rows: 1fr")

    text = text.replace("gridTemplateRows = \"1fr 1fr\"", "gridTemplateRows = \"1fr\"")

    text = text.replace("gridTemplateRows = '1fr 1fr'", "gridTemplateRows = '1fr'")

    text = re.sub(

        r'(<[^>]+id=["\']recentLogs["\'][\s\S]*?</[^>]+>)',

        r'',

        text,

        flags=re.IGNORECASE,

    )

    path.write_text(text, encoding="utf-8")

