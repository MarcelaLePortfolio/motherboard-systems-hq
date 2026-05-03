#!/usr/bin/env python3
import sys, re, pathlib

def find_container_around(html: str, anchor_pat: re.Pattern, tag="section"):
    m = anchor_pat.search(html)
    if not m:
        return None
    i = m.start()

    open_pat = re.compile(r'<%s\b[^>]*>' % tag, re.IGNORECASE)
    opens = [mm for mm in open_pat.finditer(html, 0, i)]
    if not opens:
        return None
    start_m = opens[-1]
    start = start_m.start()

    open_tag = re.compile(r'<%s\b[^>]*>' % tag, re.IGNORECASE)
    close_tag = re.compile(r'</%s\s*>' % tag, re.IGNORECASE)

    pos = start
    depth = 0
    while True:
        om = open_tag.search(html, pos)
        cm = close_tag.search(html, pos)
        if cm is None:
            return None
        if om is not None and om.start() < cm.start():
            depth += 1
            pos = om.end()
            continue
        depth -= 1
        pos = cm.end()
        if depth <= 0:
            end = pos
            return (start, end, html[start:end])

def looks_like_pvo(block: str) -> bool:
    s = block.lower()
    keys = ["pvo", "project", "visual", "output", "monitor", "screen", "bevel", "crt"]
    return sum(1 for k in keys if k in s) >= 2

def main():
    if len(sys.argv) != 3:
        print("usage: surgical_pvo_transplant_v2.py <collapsed_html> <restored_html>", file=sys.stderr)
        return 2

    collapsed_path = pathlib.Path(sys.argv[1])
    restored_path  = pathlib.Path(sys.argv[2])

    collapsed = collapsed_path.read_text(encoding="utf-8", errors="replace")
    restored  = restored_path.read_text(encoding="utf-8", errors="replace")

    collapsed_anchors = [
        re.compile(r'\bid=["\']pvo\b', re.IGNORECASE),
        re.compile(r'Project\s+Visual\s+Output', re.IGNORECASE),
        re.compile(r'\bPVO\b', re.IGNORECASE),
        re.compile(r'\bmonitor\b', re.IGNORECASE),
        re.compile(r'\bvisual\b', re.IGNORECASE),
    ]

    c_block = None
    for ap in collapsed_anchors:
        c_block = find_container_around(collapsed, ap, tag="section") or find_container_around(collapsed, ap, tag="div")
        if c_block and looks_like_pvo(c_block[2]):
            break

    if not c_block:
        print("ERROR: Could not find a PVO-like container in collapsed backup.", file=sys.stderr)
        return 3

    restored_candidates = []
    for ap in [
        re.compile(r'Task\s+Activity\s+Over\s+Time', re.IGNORECASE),
        re.compile(r'id=["\']task-activity-graph["\']', re.IGNORECASE),
        re.compile(r'Matilda\s+Chat\s+Console', re.IGNORECASE),
        re.compile(r'Task\s+Delegation', re.IGNORECASE),
        re.compile(r'\bvisual\b', re.IGNORECASE),
        re.compile(r'\bmonitor\b', re.IGNORECASE),
    ]:
        rb = find_container_around(restored, ap, tag="section") or find_container_around(restored, ap, tag="div")
        if rb:
            restored_candidates.append(rb)

    r_block = None
    for rb in restored_candidates:
        if looks_like_pvo(rb[2]):
            r_block = rb
            break
    if not r_block and restored_candidates:
        r_block = restored_candidates[0]

    if not r_block:
        print("ERROR: Could not find a replacement container in restored file.", file=sys.stderr)
        return 4

    c_html = c_block[2]
    r_start, r_end, _ = r_block

    updated = restored[:r_start] + c_html + restored[r_end:]
    restored_path.write_text(updated, encoding="utf-8")
    print("OK: transplanted PVO-like container using v2 heuristic.")
    return 0

if __name__ == "__main__":
    raise SystemExit(main())
