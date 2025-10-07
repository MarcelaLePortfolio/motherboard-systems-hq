// Auto-generated dynamic skill for "dashboard.moveSection"
type Params = Record<string, any>;

/**
 * Convention: export default async function(params, ctx)
 * Return a short human string summarizing the result.
 */
export default async function run(params: Params, ctx: { dryRun?: boolean }) {
  if (ctx?.dryRun) {
    return `(dry-run) would perform: dashboard.moveSection with ${JSON.stringify(params)}`;
  }
  // TODO: replace with real logic. Keep file-system/network changes minimal here.
  return `✅ dashboard.moveSection completed with ${JSON.stringify(params)}`;
}
