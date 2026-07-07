
export type DepsResolution =

  | { ok: true; blockedBy: string[] }

  | { ok: false; blockedBy: string[]; error: string };

export function resolveDeps(r: DepsResolution) {

  if (!r.ok) {

    const failure = r as Extract<DepsResolution, { ok: false }>;

    return {

      runnable: false,

      blockedBy: failure.blockedBy,

      terminalBlock: failure.error

    };

  }

  return {

    runnable: true,

    blockedBy: r.blockedBy,

    terminalBlock: null

  };

}

