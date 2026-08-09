import subprocess
import sys

command = [
    "npx",
    "tsx",
    "scripts/validate-source-excerpt-first-live.ts",
]

try:
    result = subprocess.run(
        command,
        cwd=".",
        capture_output=True,
        text=True,
        timeout=90,
    )
except subprocess.TimeoutExpired as error:
    if error.stdout:
        print(error.stdout)
    if error.stderr:
        print(error.stderr, file=sys.stderr)

    print("LIVE_VALIDATION_TIMEOUT")
    print("EXIT_CODE=124")
    raise SystemExit(124)

if result.stdout:
    print(result.stdout, end="")

if result.stderr:
    print(result.stderr, end="", file=sys.stderr)

print(f"EXIT_CODE={result.returncode}")
raise SystemExit(result.returncode)
