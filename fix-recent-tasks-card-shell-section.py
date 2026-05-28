
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

    # Collapse any Recent Tasks / Task History two-column or two-row shell rule near the card.

    text = re.sub(

        r'grid-template-columns:\s*1fr\s+1fr\s*!important;',

        'grid-template-columns: 1fr !important;',

        text,

        count=1,

    )

    text = re.sub(

        r'grid-template-columns:\s*1fr\s+1fr;',

        'grid-template-columns: 1fr;',

        text,

        count=1,

    )

    text = re.sub(

        r'grid-template-rows:\s*1fr\s+1fr\s*!important;',

        'grid-template-rows: 1fr !important;',

        text,

    )

    text = re.sub(

        r'grid-template-rows:\s*1fr\s+1fr;',

        'grid-template-rows: 1fr;',

        text,

    )

    # Hide the old Recent Logs / Task History shell labels without removing unrelated inspect-log buttons.

    text = re.sub(

        r'(<h[1-6][^>]*>\s*(Recent Logs|Task History)\s*</h[1-6]>)',

        r'',

        text,

        flags=re.IGNORECASE,

    )

    # Make the actual recent task viewport eligible to consume full card height.

    text = re.sub(

        r'(id=["\']recentTasks["\'][^>]*style=["\'][^"\']*)',

        lambda m: m.group(1) + ';height:100%;min-height:0;overflow:auto;',

        text,

        count=1,

    )

    # If recentLogs remains in shell, make it non-space-taking.

    text = re.sub(

        r'(id=["\']recentLogs["\'][^>]*style=["\'][^"\']*)',

        lambda m: m.group(1) + ';display:none;height:0;min-height:0;overflow:hidden;',

        text,

        count=1,

    )

    path.write_text(text, encoding="utf-8")

