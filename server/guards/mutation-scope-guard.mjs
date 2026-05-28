
import path from "node:path";

function normalize(p) {

  return path.normalize(String(p || ""));

}

export function assertPathAllowed({

  candidatePath,

  allowedPaths = [],

  forbiddenPaths = [],

}) {

  const normalizedCandidate = normalize(candidatePath);

  const forbidden = forbiddenPaths.some((p) =>

    normalizedCandidate.startsWith(normalize(p)),

  );

  if (forbidden) {

    const err = new Error(

      `forbidden mutation path: ${candidatePath}`,

    );

    err.code = "FORBIDDEN_MUTATION_PATH";

    throw err;

  }

  const allowed = allowedPaths.some((p) =>

    normalizedCandidate.startsWith(normalize(p)),

  );

  if (!allowed) {

    const err = new Error(

      `path outside allowed mutation scope: ${candidatePath}`,

    );

    err.code = "OUTSIDE_MUTATION_SCOPE";

    throw err;

  }

  return true;

}

