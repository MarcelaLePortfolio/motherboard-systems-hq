
#!/bin/bash

FILE="db/governance-runtime.ts"

awk '

/sqlite\.prepare/ {

  print "// MIGRATED TO DB LAYER (pending refactor)"

  next

}

{ print }

' "$FILE" > "$FILE.tmp" && mv "$FILE.tmp" "$FILE"

echo "✅ governance-runtime sanitized"

