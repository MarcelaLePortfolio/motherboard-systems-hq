
import { sqlite } from "./client.js";

// legacy compatibility layer

export const legacyDB = sqlite;

export const prepare = sqlite.prepare.bind(sqlite);

