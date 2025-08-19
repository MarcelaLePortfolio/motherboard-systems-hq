import { promises as fs } from 'fs';
import path from 'path';

export default async function replaceStubHandler({ action, implementation }) {
  try {
    const filePath = path.join(process.cwd(), 'scripts/agents_full/cade.ts');
    let content = await fs.readFile(filePath, 'utf-8');

    const caseRegex = new RegExp(`case\\s+"${action}"[\\s\\S]*?return\\s+\\{[^}]*\\}`, 'm');

    if (!caseRegex.test(content)) {
      throw new Error(`Case for action "${action}" not found`);
    }

    content = content.replace(caseRegex, `case "${action}": {\n${implementation}\n}`);

    await fs.writeFile(filePath, content, 'utf-8');
    return { status: 'success', action };
  } catch (err) {
    return { error: err.message };
  }
}
