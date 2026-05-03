from pathlib import Path

for filename in ["server.js", "server.mjs"]:
    p = Path(filename)
    if not p.exists():
        continue

    s = p.read_text()
    old = 'http://localhost:8080/api/delegate-task'
    new = 'http://localhost:3000/api/delegate-task'

    if old in s:
        s = s.replace(old, new)
        p.write_text(s)
        print(f"Updated {filename}")
    else:
        print(f"No 8080 trigger URL found in {filename}")
