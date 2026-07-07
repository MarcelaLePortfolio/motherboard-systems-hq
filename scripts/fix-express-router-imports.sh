
#!/usr/bin/env bash

echo "Fixing Express Router imports..."

find routes -type f -name "*.ts" | while read file; do

  # ensure Router is imported if file uses Router(

  if grep -q "Router(" "$file" && ! grep -q "from \"express\"" "$file"; then

    awk 'NR==1{print "import { Router } from \"express\";"} {print}' "$file" > "$file.tmp" && mv "$file.tmp" "$file"

  fi

  # replace express.Router() safely

  sed -i '' 's/express\.Router()/Router()/g' "$file"

done

echo "Done"

