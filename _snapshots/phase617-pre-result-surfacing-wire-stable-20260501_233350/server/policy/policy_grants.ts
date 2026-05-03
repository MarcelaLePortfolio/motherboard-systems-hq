export type PolicyGrantDecision = "allow" | "deny";

export type PolicyGrant = {
  grant_id: string;
  created_at: string;
  created_by: string;
  subject: string;
  scope: string;
  decision: PolicyGrantDecision;
  reason: string;
  expires_at: string | null;
  metadata: unknown;
};

export type ResolveGrantInput = {
  subject: string;
  scope: string;
  want: PolicyGrantDecision;
};

export type ResolveGrantResult =
  | { hit: false }
  | { hit: true; grant: PolicyGrant };

async function getPool(): Promise<any> {
  const candidates = [
    "../db/pool",
    "../db",
    "../db/index",
    "../pg",
    "../postgres",
    "../pg/pool",
  ];

  let lastErr: unknown = null;

  for (const modPath of candidates) {
    try {
      // eslint-disable-next-line @typescript-eslint/no-var-requires
      const mod = require(modPath);
      if (mod?.pool) return mod.pool;
      if (mod?.default?.pool) return mod.default.pool;
    } catch (e) {
      lastErr = e;
    }
  }

  const err = new Error(
    `Phase45: could not locate a PG pool export. Tried: ${candidates.join(", ")}`
  );
  (err as any).cause = lastErr;
  throw err;
}

/**
 * Deterministic lookup:
 * - active grants only (expires_at is null OR > now())
 * - stable ordering: created_at desc, grant_id desc
 */
export async function resolvePolicyGrant(
  input: ResolveGrantInput
): Promise<ResolveGrantResult> {
  const pool = await getPool();

  const sql = `
    SELECT
      grant_id,
      created_at,
      created_by,
      subject,
      scope,
      decision,
      reason,
      expires_at,
      metadata
    FROM policy_grants
    WHERE subject = $1
      AND scope = $2
      AND decision = $3
      AND (expires_at IS NULL OR expires_at > now())
    ORDER BY created_at DESC, grant_id DESC
    LIMIT 1
  `;

  const args = [input.subject, input.scope, input.want];
  const res = await pool.query(sql, args);

  if (!res?.rows?.length) return { hit: false };

  const row = res.rows[0];
  return {
    hit: true,
    grant: {
      grant_id: String(row.grant_id),
      created_at: new Date(row.created_at).toISOString(),
      created_by: String(row.created_by),
      subject: String(row.subject),
      scope: String(row.scope),
      decision: row.decision as "allow" | "deny",
      reason: String(row.reason),
      expires_at: row.expires_at ? new Date(row.expires_at).toISOString() : null,
      metadata: row.metadata,
    },
  };
}
