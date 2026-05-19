
from pathlib import Path

target = Path("server/worker/phase26_task_worker.mjs")

output = Path("PHASE733_WORKER_SEMANTIC_PRODUCER_SLICE.txt")

lines = target.read_text(errors="replace").splitlines()

start = 150

end = 225

capture = [

    "=== Phase 733 Worker Semantic Producer Slice ===",

    f"Target: {target}",

    f"Lines: {start}-{end}",

    "",

]

for idx in range(start, min(end, len(lines)) + 1):

    capture.append(f"{idx}: {lines[idx-1]}")

output.write_text("\n".join(capture) + "\n")

print(output.read_text())

