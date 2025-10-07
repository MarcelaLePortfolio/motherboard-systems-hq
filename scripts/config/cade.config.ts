export default {
  /** if false, new skills run in "dryRun" first and require explicit approve via a flag param */
  autoApprove: true,
  /** skill names must start with one of these prefixes to be auto-learned */
  allowedPrefixes: ["file.", "dashboard.", "tasks.", "logs.", "status."],
  /** sandbox root for generated skills */
  sandboxRoot: "scripts/skills/dynamic",
};
