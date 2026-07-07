
#!/usr/bin/env bash

echo "Fixing DB import paths..."

find routes -type f -name "*.ts" | while read file; do

  # routes/* → db

  sed -i '' 's/\.\.\/db\/client/\.\.\/\.\.\/db\/client/g' "$file"

  sed -i '' 's/\.\.\/db\/audit/\.\.\/\.\.\/db\/audit/g' "$file"

  # routes/routes/* → db (double nested safety)

  sed -i '' 's/\.\.\/\.\.\/\.\.\/db/\.\.\/\.\.\/db/g' "$file"

done

echo "Done"

