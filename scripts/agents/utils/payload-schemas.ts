import { z } from 'zod';

export const payloadSchemas = {
  'write to file': z.object({
    path: z.string().min(1),
    content: z.string()
  }),
  // You can add more command schemas here later
};
