
#!/usr/bin/env bash

echo "Normalizing imports (FULL SAFE PASS)..."

find . -type f -name "*.ts" | while read file; do

  # remove .ts extensions ONLY in import/export strings

  sed -i '' -E 's/(from\s+["'\'']\..*)\.ts(["'\''])/\1\2/g' "$file"

  sed -i '' -E 's/(import\([^)]*)\.ts(["'\''])/\1\2/g' "$file"

  # fix double escaped legacy snapshots

  sed -i '' -E 's/\\1\.ts/\\1/g' "$file"

done

echo "Done"

