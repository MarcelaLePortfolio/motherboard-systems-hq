import { queryTaskOutput } from '../../../db/helpers/memory';

/**
 * Ask if Cade has already attempted a specific task recently.
 * You can filter by actor, type, and optionally a file path, hash, or keyword in result.
 */
export async function reflectBeforeAction({
  actor = 'cade',
  type,
  contains
}: {
  actor?: string;
  type: string;
  contains?: string;
}) {
  const pastAttempts = await queryTaskOutput({ actor, type, contains });

  const last = pastAttempts.at(-1);

  return {
    pastAttempts,
    lastSuccess: pastAttempts.findLast(a => a.status === 'success'),
    lastFailure: pastAttempts.findLast(a => a.status === 'error'),
    last
  };
}
