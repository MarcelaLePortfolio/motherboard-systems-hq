import fs from 'fs';
import path from 'path';
import { nanoid } from 'nanoid';
import { reflectBeforeAction } from './utils/reflect';
import { payloadSchemas } from './utils/payload-schemas';
import { db } from '../../db/db-core';
import { task_events } from '../../db/schema';

export async function effieCommandRouter(type: string, payload: any) {
  let result: any;
  let status: 'success' | 'error' | 'skipped' = 'success';

  try {
    switch (type) {
      case 'delete file': {
        payloadSchemas['delete file'].parse(payload);

        const { lastSuccess } = await reflectBeforeAction({
          actor: 'effie',
          type: 'delete file',
          contains: payload?.path
        });

        if (lastSuccess) {
          status = 'skipped';
          result = `⚠️ Already deleted: ${payload.path}`;
          break;
        }

        fs.unlinkSync(path.resolve(payload.path));
        result = `🗑️ Deleted file "${payload.path}"`;
        break;
      }

      default: {
        status = 'error';
        result = `🤷 Unknown task type: ${type}`;
      }
    }

    await db.insert(task_events).values({
      id: nanoid(),
      task_id: nanoid(),
      type,
      status,
      actor: 'effie',
      payload: JSON.stringify(payload),
      result: JSON.stringify(result),
      file_hash: undefined,
      created_at: new Date().toISOString()
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
      actor: 'effie',
      payload: JSON.stringify(payload),
      result: JSON.stringify(result),
      file_hash: undefined,
      created_at: new Date().toISOString()
    });

    return { status, result };
  }
}
