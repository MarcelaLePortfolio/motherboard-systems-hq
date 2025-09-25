import { cadeCommandRouter } from "./cade";
const delegate = { cadeCommandRouter };
import { db } from "../../db/db-core";
import { task_events } from "../../db/schema";
export const delegate2 = { cade: cadeCommandRouter };
import fs from 'fs';
import path from 'path';
import { nanoid } from "nanoid";
import { payloadSchemas } from './utils/payload-schemas';
import { reflectBeforeAction } from './utils/reflect';
import { queryTaskOutput } from '../../db/helpers/memory';

export async function effieCommandRouter(type: string, payload: any) {
  let result: any;
  let status: string = 'success';

  try {
    switch (type) {
      case 'delete file': {
        payloadSchemas['delete file'].parse(payload);

        const fullPath = path.resolve(payload.path);
        const hasAlready = await reflectBeforeAction({
          actor: 'effie',
          type: 'delete file',
          contains: payload.path
        });

        if (hasAlready.lastSuccess) {
          status = 'skipped';
          result = `⚠️ Already deleted: ${payload.path}`;
          break;
        }

        fs.unlinkSync(fullPath);
        result = `��️ Deleted file "${payload.path}"`;
        break;
      }

      case 'run task file': {
        payloadSchemas['run task file'].parse(payload);
        const fullPath = path.resolve(payload.filename);
        if (!fs.existsSync(fullPath)) {
          throw new Error(`Task file not found: ${payload.filename}`);
        }

        const raw = fs.readFileSync(fullPath, 'utf8');
  const { filename } = payload ?? {};
  const taskContent = fs.readFileSync(filename, "utf8");
  const task = JSON.parse(taskContent);
  const taskPayload = task?.payload ?? {};

  const { agent, command } = task;
        if (!agent || !command || !taskPayload) {
          throw new Error(`Invalid task structure in ${payload.filename}`);
        }

        let delegate;

        switch (agent) {
          case 'cade':
            delegate = await import('./cade');
            break;
          default:
            throw new Error(`Unsupported agent: ${agent}`);
        }
console.log("🧪 DEBUG task:", JSON.stringify(task, null, 2));

console.log("🧪 DEBUG payload:", JSON.stringify(taskPayload, null, 2));
        const response = await delegate[`${agent}CommandRouter`](command, { payload: { ...taskPayload, actor: "effie" } });
        status = response.status;
        result = response.result;
        break;
      }

      default: {
        status = 'error';
        result = `🤷 Unsupported command: ${type}`;
      }
    }

    await queryTaskOutput(); // ensure it links properly (noop for now)

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
