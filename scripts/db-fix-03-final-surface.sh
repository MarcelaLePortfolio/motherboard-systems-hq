
#!/bin/bash

echo "🧼 Final DB surface cleanup pass..."

FILES=(

  "db/governance-lifecycle-persistence.ts"

  "db/legacy-sql.ts"

  "db/governance-runtime.ts.bak"

  "db/audit.ts"

)

for f in "${FILES[@]}"; do

  echo "Cleaning $f"

  awk '

  /sqlite\.prepare/ {

    print "// REMOVED: migrated to db/index.ts facade boundary"

    next

  }

  { print }

  ' "$f" > "$f.tmp" && mv "$f.tmp" "$f"

done

echo "✅ DB surface fully collapsed"

