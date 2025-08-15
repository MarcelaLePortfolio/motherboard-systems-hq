import fs from 'fs';
import path from 'path';

export function writeTaskToChainFile(agent: string, task: any) {
  const filePath = path.join('memory', `${agent}_chain_state.json`);
  fs.writeFileSync(filePath, JSON.stringify(task, null, 2));
}
