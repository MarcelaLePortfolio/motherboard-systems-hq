#!/usr/bin/env python3
from __future__ import annotations

import json
import os
import re
import subprocess
from pathlib import Path
from typing import Dict, List

ROOT = Path(subprocess.check_output(["git", "rev-parse", "--show-toplevel"], text=True).strip())
os.chdir(ROOT)

SEARCH_AREAS = [
    "src",
    "scripts",
    "workers",
    "public",
    "docker-compose.yml",
    "Dockerfile",
    "Dockerfile.dashboard",
    "package.json",
]

PATTERNS: Dict[str, List[str]] = {
    "shell_execution": [
        r"\bexec\(",
        r"\bspawn\(",
        r"\bspawnSync\(",
        r"\bexecSync\(",
        r"\bsubprocess\.",
        r"\bos\.system\(",
        r"child_process",
        r"tsx ",
        r"bash ",
        r"sh ",
    ],
    "filesystem_write": [
        r"writeFile",
        r"writeFileSync",
        r"appendFile",
        r"appendFileSync",
        r"mkdir",
        r"mkdirSync",
        r"cat >",
        r"tee ",
        r"fs/promises",
        r"open\(",
    ],
    "filesystem_read": [
        r"readFile",
        r"readFileSync",
        r"readdir",
        r"readdirSync",
        r"statSync",
        r"existsSync",
    ],
    "git_operations": [
        r"\bgit\b",
        r"simple-git",
        r"isomorphic-git",
    ],
    "docker_operations": [
        r"\bdocker\b",
        r"docker compose",
        r"docker-compose",
    ],
    "http_requests": [
        r"\bfetch\(",
        r"axios",
        r"undici",
        r"requests\.",
        r"httpx\.",
    ],
    "task_lifecycle": [
        r"\btask\b",
        r"\brun\b",
        r"\blease\b",
        r"task event",
        r"task_event",
        r"task-events",
    ],
    "governance_runtime_registry": [
        r"runtime registry",
        r"registry owner",
        r"governance",
        r"consumption registry",
    ],
}

def tracked_files() -> List[Path]:
    files: List[Path] = []
    for area in SEARCH_AREAS:
        p = ROOT / area
        if p.is_file():
            files.append(p)
        elif p.is_dir():
            files.extend(
                f for f in p.rglob("*")
                if f.is_file() and ".git" not in f.parts and f.suffix.lower() not in {".png", ".jpg", ".jpeg", ".gif", ".ico", ".pdf"}
            )
    seen = set()
    unique: List[Path] = []
    for f in files:
        rel = str(f.relative_to(ROOT))
        if rel not in seen:
            seen.add(rel)
            unique.append(f)
    return unique

def safe_text(path: Path) -> str:
    try:
        return path.read_text(encoding="utf-8", errors="ignore")
    except Exception:
        return ""

def find_matches(text: str, patterns: List[str]) -> List[str]:
    hits: List[str] = []
    for pattern in patterns:
        if re.search(pattern, text, flags=re.IGNORECASE | re.MULTILINE):
            hits.append(pattern)
    return hits

def main() -> None:
    files = tracked_files()
    findings = {}

    for capability, patterns in PATTERNS.items():
        matched_files = []
        for path in files:
            text = safe_text(path)
            hits = find_matches(text, patterns)
            if hits:
                matched_files.append({
                    "file": str(path.relative_to(ROOT)),
                    "matched_patterns": hits,
                })
        findings[capability] = {
            "present": len(matched_files) > 0,
            "match_count": len(matched_files),
            "files": matched_files[:50],
        }

    summary = {
        "repository_root": str(ROOT),
        "audit_type": "execution_capability_presence_audit",
        "note": "This verifies which execution-related capabilities are present in the codebase/configuration by static evidence. It does not prove runtime authorization or correctness.",
        "capabilities": findings,
    }

    print(json.dumps(summary, indent=2))

if __name__ == "__main__":
    main()
