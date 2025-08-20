import { z } from 'zod';

export const taskSchema = z.object({
  id: z.number(),
  type: z.enum(['echo', 'read', 'write', 'patch', 'delete']),
  payload: z.object({
    path: z.string(),
    content: z.string().optional(), // required only for 'write'
  }),
});
