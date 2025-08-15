import fs from 'fs';
import path from 'path';

const CHAIN_STATE_PATH = path.join(__dirname, '../../../../memory/agent_chain_state.json');

export function loadChainState(): any {
  if (!fs.existsSync(CHAIN_STATE_PATH)) {
    return { agent: 'Matilda', status: 'Idle', ts: 0 };
  }
  const raw = fs.readFileSync(CHAIN_STATE_PATH, 'utf-8');
  return JSON.parse(raw);
}

export function saveChainState(state: any): void {
  fs.writeFileSync(CHAIN_STATE_PATH, JSON.stringify(state, null, 2));
}
