
#!/bin/bash

echo "🧼 Final hard dedupe pass..."

FILES=("routes/cade.ts" "routes/tasks.ts")

for f in "${FILES[@]}"; do

  awk '

  BEGIN {

    expressSeen = 0;

    routerSeen = 0;

  }

  /import express/ {

    if (expressSeen == 0) {

      print;

      expressSeen = 1;

    }

    next;

  }

  /const router =/ {

    if (routerSeen == 0) {

      print;

      routerSeen = 1;

    }

    next;

  }

  { print }

  ' "$f" > "$f.tmp" && mv "$f.tmp" "$f"

done

echo "✅ Hard dedupe complete"

