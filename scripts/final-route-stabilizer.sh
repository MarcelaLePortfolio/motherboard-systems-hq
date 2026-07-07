
#!/bin/bash

echo "🧭 Running final route stabilization pass..."

FILES=$(grep -RL "router\." routes)

for f in $FILES; do

  if ! grep -q "const router = express.Router" "$f"; then

    echo "Fixing missing router bootstrap: $f"

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

echo "✅ Final route stabilization complete"

