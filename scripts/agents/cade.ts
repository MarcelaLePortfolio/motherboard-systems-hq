import fs from 'fs';
import path from 'path';
import crypto from 'crypto';
import { nanoid } from 'nanoid';
import { db } from '../../db/db-core';
import { agentTasks } from '../../db/schema';
import { eq } from 'drizzle-orm';
import { task_events } from '../../db/schema';

export async function cadeCommandRouter(type: string, payload: any) {
  const task = {
    id: nanoid(),
    type,
    payload,
  };

  let result: any = null;
  let status: 'success' | 'error' = 'success';

  try {
    switch (type) {
      case 'write to file': {
        const fullPath = path.resolve(payload.path);
        fs.writeFileSync(fullPath, payload.content, 'utf8');

        const hash = crypto
          .createHash('sha256')
          .update(payload.content)
          .digest('hex');

        result = {
          message: `File written to ${payload.path}`,
          bytes: Buffer.byteLength(payload.content),
          hash,
        };

        // ✅ Log to task_events
        await db.insert(task_events).values({
          id: nanoid(),
          task_id: task.id,
          type: 'write to file',
          status,
          actor: 'cade',
          payload: JSON.stringify(payload),
          result: JSON.stringify(result),
          file_hash: hash,
          created_at: new Date().toISOString(),
        });

        break;
      }

      default: {
        status = 'error';
        result = `🤷 Unknown task type: ${type}`;
      }
    }

    return { status, result };
  } catch (err: any) {
    status = 'error';
    result = `❌ Error: ${err.message || String(err)}`;

    await db.insert(task_events).values({
      id: nanoid(),
      task_id: task.id,
      type,
      status,
      actor: 'cade',
      payload: JSON.stringify(payload),
      result: JSON.stringify(result),
      file_hash: undefined,
      created_at: new Date().toISOString(),
    });

    return { status, result };
  }
}
