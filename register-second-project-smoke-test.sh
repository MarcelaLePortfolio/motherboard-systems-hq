
#!/bin/bash

set -e

echo "=== Current registry ==="

curl -s http://localhost:3001/api/projects/registry | python3 -m json.tool

echo

echo "=== Registering sample project ==="

python3 <<'PY'

import json

from pathlib import Path

p = Path("projects/registry.example.json")

data = json.loads(p.read_text())

if not any(x["id"] == "executive-agent-suite" for x in data["projects"]):

    data["projects"].append({

        "id": "executive-agent-suite",

        "name": "Executive Agent Suite",

        "mode": "integrity",

        "kind": "workspace",

        "repoPath": "../executive-agent-suite",

        "services": []

    })

p.write_text(json.dumps(data, indent=2) + "\n")

print("Added Executive Agent Suite to registry seed.")

PY

git diff projects/registry.example.json

echo

echo "Restart the server, then verify the new project appears in the Project Switcher."

