
from pathlib import Path

target = Path("public/js/phase530_visible_panels_bridge.js")

output = Path("PHASE733_RENDERER_THEME_CONSUMPTION_SLICE.txt")

lines = target.read_text(errors="replace").splitlines()

capture_ranges = [

    (1180, 1365),

    (1365, 1525),

]

result = [

    "=== Phase 733 Renderer Theme Consumption Slice ===",

    f"Target: {target}",

    "",

]

for start, end in capture_ranges:

    result.append(f"=== Lines {start}-{end} ===")

    for idx in range(start, min(end, len(lines)) + 1):

        result.append(f"{idx}: {lines[idx-1]}")

    result.append("")

output.write_text("\n".join(result) + "\n")

print(output.read_text())

