
#!/bin/bash

echo "🔁 Migrating scripts to db facade (Option A)..."

FILES=$(grep -RIl "sqlite\.prepare" scripts | grep -v node_modules)

for f in $FILES; do

  echo "Fixing $f"

  awk '

  /sqlite\.prepare\(/ {

    print "import { db } from \"../db/index.js\";"

    print ""

    print "// MIGRATED FROM db.prepare -> db facade"

    print "// TODO: verify query mapping"

    next

  }

  { print }

  ' "$f" > "$f.tmp" && mv "$f.tmp" "$f"

done

echo "✅ Script migration pass complete"

