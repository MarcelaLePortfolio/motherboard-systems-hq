
#!/usr/bin/env python3

from pathlib import Path

import subprocess

import tarfile

import re

OUTPUT = Path("LATEST_SOURCE_BACKUP_DB_ASSET_INSPECTION.txt")

PATTERN = re.compile(

    r"(postgres|pgdata|docker|volume|database|\.db$|sqlite|drizzle|migration|schema|task|agent_brain|compose|supabase)",

    re.IGNORECASE,

)

def write(line=""):

    print(line)

    with OUTPUT.open("a", encoding="utf-8") as f:

        f.write(line + "\n")

def run(cmd):

    try:

        result = subprocess.run(cmd, text=True, capture_output=True, check=False)

        return (result.stdout + result.stderr).strip()

    except Exception as exc:

        return f"ERROR running {' '.join(cmd)}: {exc}"

def list_tars(root):

    p = Path(root)

    if not p.exists():

        return []

    return sorted(p.glob("source_*.tar.gz"))[-10:]

def inspect_tar(tar_path, limit=200):

    matches = []

    try:

        with tarfile.open(tar_path, "r:gz") as tf:

            for member in tf:

                if PATTERN.search(member.name):

                    matches.append(member.name)

                    if len(matches) >= limit:

                        break

    except Exception as exc:

        matches.append(f"ERROR inspecting {tar_path}: {exc}")

    return matches

OUTPUT.unlink(missing_ok=True)

write("===== LATEST SOURCE BACKUP DB ASSET INSPECTION =====")

write(run(["date"]))

write()

local_tars = list_tars("./backups")

rio_tars = list_tars("/Volumes/Rio Drive/backups")

write("===== LOCAL SOURCE TARBALLS =====")

for item in local_tars:

    write(str(item))

write()

write("===== RIO DRIVE SOURCE TARBALLS =====")

for item in rio_tars:

    write(str(item))

write()

write("===== INSPECT LOCAL TARBALL CONTENTS =====")

for tar_path in local_tars[-5:]:

    write()

    write(f"----- {tar_path} -----")

    matches = inspect_tar(tar_path)

    if matches:

        for m in matches:

            write(m)

    else:

        write("NO_DB_ASSET_MATCHES_FOUND")

write()

write("===== INSPECT RIO DRIVE TARBALL CONTENTS =====")

for tar_path in rio_tars[-5:]:

    write()

    write(f"----- {tar_path} -----")

    matches = inspect_tar(tar_path)

    if matches:

        for m in matches:

            write(m)

    else:

        write("NO_DB_ASSET_MATCHES_FOUND")

write()

write("===== LIVE DOCKER VOLUMES =====")

write(run(["docker", "volume", "ls"]))

write()

write("===== LIVE CONTAINERS =====")

write(run(["docker", "ps", "-a"]))

write()

write("===== POSSIBLE LOCAL SQLITE FILES =====")

count = 0

for root in [Path(".")]:

    for path in root.rglob("*"):

        if path.is_file() and path.suffix.lower() in {".db", ".sqlite", ".sqlite3"}:

            write(str(path))

            count += 1

            if count >= 200:

                break

    if count >= 200:

        break

if count == 0:

    write("NO_LOCAL_SQLITE_FILES_FOUND")

write()

write("===== GIT HEAD =====")

write(run(["git", "log", "--oneline", "-5"]))

write()

write("===== WORKTREE =====")

write(run(["git", "status", "--short"]))

write()

write(f"Inspection complete -> {OUTPUT}")

