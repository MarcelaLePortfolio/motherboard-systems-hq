#!/usr/bin/env python3
import sys, re, pathlib

def find_block(html: str, needle_regex: re.Pattern, tag_names=("div","section","main","article")):
    m = needle_regex.search(html)
    if not m:
        return None

    i = m.start()

    # find nearest opening tag before needle
    open_pat = re.compile(r'<(?P<tag>' + '|'.join(tag_names) + r')\b[^>]*>', re.IGNORECASE)
    candidates = [mm for mm in open_pat.finditer(html, 0, i)]
    if not candidates:
        return None

    start_m = candidates[-1]
    start = start_m.start()
    tag = start_m.group("tag").lower()

    # walk forward to matching close for this tag, tracking nested same-tag opens/closes
    open_tag = re.compile(r'<'+re.escape(tag)+r'\b[^>]*>', re.IGNORECASE)
    close_tag = re.compile(r'</'+re.escape(tag)+r'\s*>', re.IGNORECASE)

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
            return (start, end, html[start:end], m.group(0))

def looks_like_pvo(block_html: str) -> bool:
    s = block_html.lower()
    # broader heuristics; allow for collapsed/minified markup
    if "project" in s and "visual" in s and "output" in s:
        return True
    if "pvo" in s:
        return True
    if "visual-output" in s or "visual_output" in s:
        return True
    if 'id="pvo' in s or "id='pvo" in s:
        return True
    if "pvo-" in s:
        return True
    return False

def main():
    if len(sys.argv) != 3:
        print("usage: surgical_pvo_transplant.py <collapsed_html> <restored_html>", file=sys.stderr)
        return 2

    collapsed_path = pathlib.Path(sys.argv[1])
    restored_path = pathlib.Path(sys.argv[2])

    collapsed = collapsed_path.read_text(encoding="utf-8", errors="replace")
    restored  = restored_path.read_text(encoding="utf-8", errors="replace")

    # order matters: strongest identifiers first
    needles = [
        re.compile(r'\bid=["\']pvo\b', re.IGNORECASE),
        re.compile(r'\bid=["\']pvo[-_][^"\']+', re.IGNORECASE),
        re.compile(r'\bproject[-_ ]visual[-_ ]output\b', re.IGNORECASE),
        re.compile(r'Project\s+Visual\s+Output', re.IGNORECASE),
        re.compile(r'\bPVO\b', re.IGNORECASE),
    ]

    c_block = None
    r_block = None
    chosen = None

    for nd in needles:
        c_block = find_block(collapsed, nd)
        r_block = find_block(restored, nd)
        if c_block and r_block:
            chosen = nd.pattern
            break

    if not c_block or not r_block:
        print("ERROR: Could not locate matching PVO block in both files. No changes applied.", file=sys.stderr)
        return 3

    c_start, c_end, c_html, c_hit = c_block
    r_start, r_end, r_html, r_hit = r_block

    # sanity: ensure extracted blocks look like PVO in both files
    if not looks_like_pvo(c_html):
        print(f"ERROR: Collapsed extraction does not look like PVO (matched: {c_hit!r}, needle: {chosen}).", file=sys.stderr)
        return 4
    if not looks_like_pvo(r_html):
        print(f"ERROR: Restored extraction does not look like PVO (matched: {r_hit!r}, needle: {chosen}).", file=sys.stderr)
        return 5

    updated = restored[:r_start] + c_html + restored[r_end:]
    restored_path.write_text(updated, encoding="utf-8")

    print(f"OK: PVO block transplanted using needle: {chosen}")
    return 0

if __name__ == "__main__":
    raise SystemExit(main())
