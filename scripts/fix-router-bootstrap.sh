
#!/bin/bash

FILES=$(grep -RL "express.Router" routes)

for f in $FILES; do

  echo "Fixing $f"

  # only patch if file uses router but doesn't define it

  if grep -q "router\." "$f"; then

    if ! grep -q "express.Router" "$f"; then

      # safer macOS-compatible insertion (no multiline sed block)

      awk 'NR==1{

        print "import express from \"express\";"

        print "const router = express.Router();"

        print "export default router;"

        print ""

      } {print}' "$f" > "$f.tmp" && mv "$f.tmp" "$f"

    fi

  fi

done

