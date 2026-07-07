
#!/usr/bin/env bash

echo "Normalizing Express Router usage..."

find routes -type f -name "*.ts" | while read file; do

  # convert express.Router() → Router()

  sed -i '' 's/express\.Router()/Router()/g' "$file"

  # only inject import if missing AND file uses Router()

  if grep -q "Router()" "$file" && ! grep -q "from \"express\"" "$file"; then

    awk 'NR==1{print "import { Router } from \"express\";"} {print}' "$file" > "$file.tmp" && mv "$file.tmp" "$file"

  fi

done

echo "Done"

