
#!/usr/bin/env bash

echo "Hard resetting Express usage to canonical form..."

find routes -type f -name "*.ts" | while read file; do

  # remove ALL broken imports

  sed -i '' '/Router/d' "$file"

  sed -i '' 's/import express.*from "express"/import express from "express"/g' "$file"

  # ensure router is consistent

  sed -i '' 's/express\.Router()/express.Router()/g' "$file"

  sed -i '' 's/Router()/express.Router()/g' "$file"

  # ensure base import exists

  if ! grep -q "import express" "$file"; then

    awk 'NR==1{print "import express from \"express\";"} {print}' "$file" > "$file.tmp" && mv "$file.tmp" "$file"

  fi

done

echo "Done"

