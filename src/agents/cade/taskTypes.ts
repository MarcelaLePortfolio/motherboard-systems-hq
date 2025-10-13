 
import { z } from "zod";

export const TaskType = z.enum(["shell", "fileWrite", "httpRequest", "noop"]);

const BaseTask = z.object({
  taskId: z.string().min(1),
  type: TaskType,
  createdAt: z.string().optional(),
  meta: z.record(z.any()).optional(),
});

export const ShellTask = BaseTask.extend({
  type: z.literal("shell"),
  command: z.string().min(1),
  cwd: z.string().optional(),
  timeoutMs: z.number().int().positive().max(5 * 60 * 1000).default(60_000),
});

export const FileWriteTask = BaseTask.extend({
  type: z.literal("fileWrite"),
  path: z.string().min(1),
  contents: z.string().default(""),
  mode: z.number().optional(),
});

export const HttpRequestTask = BaseTask.extend({
  type: z.literal("httpRequest"),
  url: z.string().url(),
  method: z.enum(["GET", "POST", "PUT", "PATCH", "DELETE"]).default("GET"),
  headers: z.record(z.string()).optional(),
  body: z.any().optional(),
  timeoutMs: z.number().int().positive().max(120_000).default(30_000),
});

export const AnyTask = z.union([
  ShellTask,
  FileWriteTask,
  HttpRequestTask,
  BaseTask.extend({ type: z.literal("noop") }),
]);

export type AnyTaskT = z.infer<typeof AnyTask>;
