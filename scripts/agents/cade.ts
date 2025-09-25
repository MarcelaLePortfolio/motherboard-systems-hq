import fs from 'fs';
import path from 'path';
import crypto from 'crypto';
import { nanoid } from 'nanoid';
import { db } from '../../db/db-core';
import { agentTasks, task_events } from '../../db/schema';
import { payloadSchemas } from './utils/payload-schemas';
import { eq } from 'drizzle-orm';
import { queryTaskOutput } from '../../db/helpers/memory'; // ✅ Memory query helper

export async function cadeCommandRouter(type: string, payload: any) {
  let result: any = null;
  let status: 'success' | 'error' = 'success';

  try {
    const task = {
      id: nanoid(),
      payload,
      type,
    };

    switch (type) {
      case 'write to file': {
        payloadSchemas['write to file'].parse(payload);

        const fullPath = path.resolve(payload.path);
        const hash = crypto.createHash('sha256').update(payload.content).digest('hex');

        // 🧠 MEMORY CHECK: Has Cade already written this exact file content?
        const existing = await queryTaskOutput({
          actor: 'cade',
          type: 'write to file',
          contains: hash
        });

        const alreadyDone = existing.some(entry => entry.status === 'success' && entry.file_hash === hash);

        if (alreadyDone) {
          result = {
            message: `⚠️ Skipped duplicate write to "${payload.path}" — identical hash found.`,
            hash
          };
          break;
        }

        // Proceed to write the file
        fs.writeFileSync(fullPath, payload.content, 'utf8');

        result = {
          message: `File written to ${payload.path}`,
          bytes: Buffer.byteLength(payload.content, 'utf8'),
          hash
        };

        break;
      }

      default: {
        status = 'error';
        result = `🤷 Unknown task type: ${type}`;
      }
    }

    await db.insert(task_events).values({
      id: nanoid(),
      task_id: task.id,
      type,
      status,
      actor: 'cade',
      payload: JSON.stringify(payload),
      result: JSON.stringify(result),
      file_hash: result?.hash,
      created_at: new Date().toISOString(),
    });

    return { status, result };
  } catch (err: any) {
    status = 'error';
    result = `❌ Error: ${err.message || String(err)}`;

    await db.insert(task_events).values({
      id: nanoid(),
      task_id: nanoid(),
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
