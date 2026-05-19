
from pathlib import Path

target = Path("server/worker/task_execution_interpreter.mjs")

output = Path("PHASE734_VISUAL_GENERATOR_SLICE.txt")

lines = target.read_text(errors="replace").splitlines()

needles = [

    "visual_artifact_generation",

    "Preview Concept",

    "Brand story",

    "Core promise",

    "Reserve a box",

    "visual-artifact:start",

]

hit_lines = [

    idx for idx, line in enumerate(lines, start=1)

    if any(needle in line for needle in needles)

]

ranges = []

for hit in hit_lines:

    ranges.append((max(1, hit - 45), min(len(lines), hit + 90)))

merged = []

for start, end in sorted(ranges):

    if not merged or start > merged[-1][1] + 5:

        merged.append([start, end])

    else:

        merged[-1][1] = max(merged[-1][1], end)

capture = [

    "# Phase 734 Visual Generator Slice",

    "",

    f"Target: {target}",

    "",

]

for start, end in merged:

    capture.append(f"## Lines {start}-{end}")

    capture.append("")

    capture.append("```")

    for idx in range(start, end + 1):

        capture.append(f"{idx}: {lines[idx-1]}")

    capture.append("```")

    capture.append("")

output.write_text("\n".join(capture) + "\n")

print(output.read_text())

