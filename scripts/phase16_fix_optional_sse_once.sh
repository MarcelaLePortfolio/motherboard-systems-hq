#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."

FILE="server/optional-sse.mjs"
test -f "$FILE"

perl -0777 -i -pe '
  # 1) Insert a proper "once" gate right after the hello writeEvent(...) block.
  if ($_ !~ /PHASE16_OPTIONAL_SSE_ONCE_DEFINED/) {
    s#(\s*writeEvent\(res,\s*\{\s*\n\s*event:\s*"hello",.*?\n\s*\}\);\s*\n)#${1}\n      // PHASE16_OPTIONAL_SSE_ONCE_DEFINED\n      // If ?once=1, end immediately after hello for clean curl smoke tests.\n      let once = false;\n      try {\n        const url = new URL(req.originalUrl || req.url || \"/\", \"http://localhost\");\n        once = url.searchParams.get(\"once\") === \"1\";\n      } catch (_) {}\n      if (once) {\n        setTimeout(() => { try { res.end(); } catch (_) {} }, 25);\n        return;\n      }\n\n#s;
  }

  # 2) Remove the broken duplicated blocks that reference an undefined "once"
  #    (they appear as repeated "if (once) { ... return; }" chunks).
  $_ =~ s/\n\s*if\s*\(once\)\s*\{\s*\n\s*\/\/ One-shot mode.*?\n\s*return;\s*\n\s*\}\s*//sg;

  # 3) Remove the old query-param once handler block if it still exists (now redundant).
  $_ =~ s/\n\s*\/\/ If \?once=1, end immediately after hello for clean curl tests\.\s*\n\s*try\s*\{\s*\n\s*const url = new URL\(.*?\n\s*\}\s*catch\s*\(_\)\s*\{\s*\}\s*//sg;

  $_;
' "$FILE"

echo "✅ patched $FILE (fixed once logic + removed duplicates)"
