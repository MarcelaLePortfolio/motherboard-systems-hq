from pathlib import Path
import re

p = Path("server.js")
s = p.read_text()

if 'createRequire' not in s:
    s = s.replace(
        'import fs from "fs";',
        'import fs from "fs";\nimport { createRequire } from "module";'
    )

if 'const require = createRequire(import.meta.url);' not in s:
    s = s.replace(
        'const __filename = fileURLToPath(import.meta.url);',
        'const require = createRequire(import.meta.url);\nconst __filename = fileURLToPath(import.meta.url);'
    )

if 'require("./server/retry_contract.js")' not in s:
    marker = 'const require = createRequire(import.meta.url);\n'
    s = s.replace(
        marker,
        marker + 'const { enforceRetryContract } = require("./server/retry_contract.js");\n'
    )

s = re.sub(
    r'app\.post\(\s*["\']\/api\/delegate-task["\']\s*,\s*async\s*\(',
    'app.post("/api/delegate-task", enforceRetryContract, async (',
    s,
    count=1
)

p.write_text(s)
