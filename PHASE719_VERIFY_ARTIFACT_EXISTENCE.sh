
#!/usr/bin/env bash

set -u

echo "===== PHASE 719 VERIFY ARTIFACT EXISTENCE ====="

echo ""

echo "[1] Confirm runtime health"

docker compose ps

echo ""

echo "[2] Inspect latest tasks payload"

curl -s http://localhost:3000/api/tasks | python3 -m json.tool | head -120

echo ""

echo "[3] Inspect recent task_events for execution payloads"

docker compose exec -T postgres psql -U postgres -d motherboard -c "

SELECT

  event_type,

  left(coalesce(payload::text,''), 1000) AS payload_preview,

  created_at

FROM task_events

ORDER BY created_at DESC

LIMIT 10;

"

echo ""

echo "[4] Search repo/runtime for known artifact patterns"

find . \

  -path './node_modules' -prune -o \

  -path './.git' -prune -o \

  -type f \

  \( \

    -iname '*.html' -o \

    -iname '*.md' -o \

    -iname '*.json' -o \

    -iname '*.txt' -o \

    -iname '*.pdf' \

  \) \

  -print | grep -Ei 'artifact|output|result|generated|export|execution|render|task' | head -100

echo ""

echo "[5] Search codebase for actual artifact write operations"

grep -RniE \

'writeFile|fs\.writeFile|createWriteStream|output_path|artifact_path|generated_file|download_url|persist.*artifact|save.*artifact' \

. \

--exclude-dir=node_modules \

--exclude-dir=.git \

| head -120

echo ""

echo "[6] Conclusion target"

echo "Determine whether:"

echo "- workers generate real artifacts"

echo "- artifacts persist anywhere"

echo "- UI merely shows synthetic completion metadata"

echo "- execution outputs are currently non-existent"

echo ""

echo "===== PHASE 719 ARTIFACT EXISTENCE VERIFICATION COMPLETE ====="

