import fs from 'fs';
import path from 'path';
import crypto from 'crypto';
import { nanoid } from 'nanoid';
import { task_events } from '../../db/audit';
import { db } from "../../db/client";

export async function cadeCommandRouter(type: string, payload: any) {


  const { actor, path: filePath, content } = payload ?? {};
  console.log("<0001cade> ✅ Payload received:", JSON.stringify({ actor, filePath, content }, null, 2));
  let result: any;
  let status: 'success' | 'error' = 'success';

  try {
    switch (type) {
      case 'write to file': {
        const fullPath = path.resolve(filePath);
        const hash = crypto.createHash('sha256').update(content).digest('hex');

        // Check for duplicate content by hash
        if (fs.existsSync(fullPath)) {
          const existing = fs.readFileSync(fullPath, 'utf8');
          const existingHash = crypto.createHash('sha256').update(existing).digest('hex');
          if (existingHash === hash) {
            result = {
              status: 'skipped',
              message: `⚠️ Skipped duplicate write to "${filePath}" — identical hash found.`,
              hash,
            };
            break;
          }
        }

        fs.writeFileSync(fullPath, content, 'utf8');
        result = {
          status: 'success',
          message: `File written to ${filePath}`,
          bytes: Buffer.byteLength(content, 'utf8'),
          hash,
        };
        break;
      }

      default: {
        result = '🤷 Unknown task type';
        status = 'error';
      }
    }

    await db.insert(task_events).values({
      id: nanoid(),
      task_id: undefined,
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
    const error = err?.message || String(err);
    return { status: 'error', result: `❌ Error: ${error}` };
  }
}
