export async function runSkill(_: any) {
  return { status: "completed", message: "stub", content: "" };
}

export async function createFile(filename: string) {
  return runSkill({ type: "createFile", params: { filename } });
}

export async function readFile() {
  return runSkill({ type: "readFile" });
}
