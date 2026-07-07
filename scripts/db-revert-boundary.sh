
#!/bin/bash

echo "🧼 Restoring DB clarity boundary..."

# Ensure sqlite is the only active surface in DB layer

git checkout HEAD -- db/index.ts

# Remove drizzle confusion temporarily from client layer (alias-only mode)

sed -i '' 's/export const db = drizzle(sqlite, { schema });/\/\/ drizzle disabled temporarily/' db/client.ts

echo "✅ DB boundary reset to sqlite canonical mode"

