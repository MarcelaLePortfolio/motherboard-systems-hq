
#!/usr/bin/env bash

echo "Normalizing DB boolean model..."

find db -type f -name "*.ts" | while read file; do

  sed -i '' 's/=== 1/=== true/g' "$file"

  sed -i '' 's/=== 0/=== false/g' "$file"

done

echo "Boolean normalization complete."

