
#!/usr/bin/env bash

echo "Fixing DB import paths (final pass)..."

find routes -type f -name "*.ts" | while read file; do

  # routes/* → db

  sed -i '' 's/\.\.\/db\/client/\.\.\/\.\.\/db\/client/g' "$file"

  sed -i '' 's/\.\.\/db\/audit/\.\.\/\.\.\/db\/audit/g' "$file"

  # routes/routes/* → db (double nested correction)

  sed -i '' 's/\.\.\/\.\.\/db/\.\.\/\.\.\/db/g' "$file"

done

echo "Done"

