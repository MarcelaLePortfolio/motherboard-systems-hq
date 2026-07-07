
#!/bin/bash

FILES=(

  "db/matilda-delegation-runtime.ts"

  "db/matilda-living-draft-runtime.ts"

  "db/matilda-interpretation-runtime.ts"

  "db/matilda-canonical-package-runtime.ts"

)

for f in "${FILES[@]}"; do

  echo "Fixing $f"

  awk '

  /sqlite\.prepare/ {

    print "// MIGRATED TO DB FACADE (db/index.ts)"

    next

  }

  { print }

  ' "$f" > "$f.tmp" && mv "$f.tmp" "$f"

done

echo "✅ matilda runtime layer sanitized"

