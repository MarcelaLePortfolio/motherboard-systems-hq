
from pathlib import Path

path = Path("public/index.html")

lines = path.read_text().splitlines()

remove_ranges = [

    (377, 379),  # Task History tab, 1-based inclusive

    (392, 401),  # Task History panel, 1-based inclusive after Execution Inspector removal

]

remove_zero_based = set()

for start, end in remove_ranges:

    remove_zero_based.update(range(start - 1, end))

new_lines = [line for i, line in enumerate(lines) if i not in remove_zero_based]

path.write_text("\n".join(new_lines) + "\n")

print("Removed Task History tab and panel only.")

