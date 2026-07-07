
import { execSync } from "child_process";

console.log("EXECUTION AUTHORITY ORIGIN RESOLVER");

const raw = execSync(

  `rg "execution_authorized" -n .`,

  { encoding: "utf8" }

);

const lines = raw.split("\n").filter(Boolean);

type Hit = { file: string; line: number; content: string };

const hits: Hit[] = lines.map((l) => {

  const [file, lineStr, ...rest] = l.split(":");

  return {

    file,

    line: Number(lineStr),

    content: rest.join(":")

  };

});

const firstAssignments: Record<string, Hit> = {};

for (const hit of hits) {

  const isAssignment =

    hit.content.includes("execution_authorized") &&

    (hit.content.includes(":") || hit.content.includes("="));

  if (!isAssignment) continue;

  if (!firstAssignments[hit.file] || hit.line < firstAssignments[hit.file].line) {

    firstAssignments[hit.file] = hit;

  }

}

const ranked = Object.values(firstAssignments)

  .sort((a, b) => a.line - b.line)

  .slice(0, 25);

console.log(

  ranked.map(r => ({

    file: r.file,

    line: r.line,

    snippet: r.content.trim().slice(0, 120)

  }))

);

