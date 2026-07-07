
#!/bin/bash

echo "🧩 Running SAFE router stabilization pass..."

FILES=$(grep -RL "router\." routes)

for f in $FILES; do

  if grep -q "router\." "$f" && ! grep -q "const router = express.Router" "$f"; then

    echo "Fixing: $f"

    awk '

    BEGIN {

      print "import express from \"express\";"

      print "const router = express.Router();"

      print ""

    }

    { print }

    ' "$f" > "$f.tmp" && mv "$f.tmp" "$f"

  fi

done

echo "✅ SAFE router stabilization complete"

