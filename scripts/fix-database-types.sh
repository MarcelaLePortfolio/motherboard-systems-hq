
#!/usr/bin/env bash

echo "Fixing Database namespace misuse..."

find db -type f -name "*.ts" | while read file; do

  # replace broken namespace usage

  sed -i '' 's/Database\.Database/any/g' "$file"

  sed -i '' 's/: Database/: any/g' "$file"

done

echo "Done"

