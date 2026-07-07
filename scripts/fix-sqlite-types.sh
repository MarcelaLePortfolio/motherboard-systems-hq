
#!/usr/bin/env bash

echo "Fixing better-db3 Database types..."

find db -type f -name "*.ts" -exec sed -i '' 's/Database\.Database/Database/g' {} \;

echo "Done"

