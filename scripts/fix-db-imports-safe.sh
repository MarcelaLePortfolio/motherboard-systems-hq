
#!/usr/bin/env bash

echo "Fixing DB import paths safely..."

find routes -type f -name "*.ts" | while read file; do

  # normalize any deep relative db imports

  sed -i '' 's/\.\.\/\.\.\/\.\.\/db/\.\.\/\.\.\/db/g' "$file"

  sed -i '' 's/\.\.\/\.\.\/db/\.\.\/db/g' "$file"

done

echo "Done"

