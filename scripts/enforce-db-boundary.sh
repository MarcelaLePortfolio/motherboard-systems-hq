
#!/bin/bash

echo "🧭 Enforcing DB boundary: blocking direct sqlite usage outside db/..."

VIOLATIONS=$(grep -R "sqlite\.prepare" routes scripts || true)

if [ ! -z "$VIOLATIONS" ]; then

  echo "❌ Found forbidden sqlite.prepare usage:"

  echo "$VIOLATIONS"

  exit 1

fi

echo "✅ No direct sqlite usage detected in active surface"

