
#!/bin/bash

echo "🧭 Running TRUE route stabilization pass..."

FILES=$(find routes -type f -name "*.ts")

for f in $FILES; do

  # Only act if file uses router.* anywhere

  if grep -q "router\." "$f"; then

    # Only inject if bootstrap is missing

    if ! grep -q "const router = express.Router" "$f"; then

      echo "Fixing missing bootstrap: $f"

      awk '

      BEGIN {

        print "import express from \"express\";"

        print "const router = express.Router();"

        print ""

      }

      { print }

      ' "$f" > "$f.tmp" && mv "$f.tmp" "$f"

    fi

  fi

done

echo "✅ TRUE router stabilization complete"

