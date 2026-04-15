from pathlib import Path
import re

target = Path("public/index.html")
text = target.read_text()

# Remove mounted Phase 490 runtime height sync scripts
text = re.sub(
    r'^\s*<script defer src="js/phase490_[^"]*height[^"]*\.js"></script>\s*\n?',
    '',
    text,
    flags=re.M
)

# Remove Phase 490 height-related style blocks
text = re.sub(
    r'<style id="phase490-[^"]*height[^"]*">.*?</style>\s*',
    '',
    text,
    flags=re.S
)

target.write_text(text)
print("Restored public/index.html by removing Phase 490 height-sync mounts and style blocks.")
