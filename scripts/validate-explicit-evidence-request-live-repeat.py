import subprocess
import sys

RUNS = 3
TIMEOUT_SECONDS = 90
SUCCESS_MARKER = "SUPPORT_DRIVEN_SOURCE_EXCERPT_LIVE_SUPPORTED"

passes = 0

for run_number in range(1, RUNS + 1):
    print()
    print(f"=== EXPLICIT EVIDENCE LIVE RUN {run_number}/{RUNS} ===")

    try:
        result = subprocess.run(
            [
                "npx",
                "tsx",
                "scripts/validate-support-driven-source-excerpt-live.ts",
            ],
            capture_output=True,
            text=True,
            timeout=TIMEOUT_SECONDS,
        )
    except subprocess.TimeoutExpired as error:
        if error.stdout:
            stdout = (
                error.stdout.decode()
                if isinstance(error.stdout, bytes)
                else error.stdout
            )
            print(stdout, end="")

        if error.stderr:
            stderr = (
                error.stderr.decode()
                if isinstance(error.stderr, bytes)
                else error.stderr
            )
            print(stderr, end="", file=sys.stderr)

        print(f"RUN_{run_number}_EXIT_CODE=124")
        print("EXPLICIT_EVIDENCE_REPEAT_VALIDATION_TIMEOUT")
        raise SystemExit(124)

    if result.stdout:
        print(result.stdout, end="")

    if result.stderr:
        print(result.stderr, end="", file=sys.stderr)

    print(f"RUN_{run_number}_EXIT_CODE={result.returncode}")

    if result.returncode != 0:
        print("EXPLICIT_EVIDENCE_REPEAT_VALIDATION_FAIL")
        raise SystemExit(result.returncode)

    combined_output = result.stdout + result.stderr

    if SUCCESS_MARKER not in combined_output:
        print(
            "EXPLICIT_EVIDENCE_REPEAT_VALIDATION_FAIL: "
            "success marker missing."
        )
        raise SystemExit(2)

    passes += 1

print()
print("=== DETERMINATION ===")
print(f"PASSED_RUNS={passes}")
print(f"TOTAL_RUNS={RUNS}")

if passes == RUNS:
    print("EXPLICIT_EVIDENCE_REPEAT_VALIDATION_SUPPORTED")
    raise SystemExit(0)

print("EXPLICIT_EVIDENCE_REPEAT_VALIDATION_FAIL")
raise SystemExit(1)
