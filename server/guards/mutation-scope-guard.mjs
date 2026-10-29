import path from "node:path";

function normalizeCandidate(value) {
  if (typeof value !== "string" || value.length === 0) {
    throw new TypeError("mutation path must be a non-empty string");
  }

  if (value.includes("\0")) {
    throw new TypeError("mutation path must not contain NUL bytes");
  }

  return path.normalize(value);
}

function isWithinScope(candidate, scope) {
  const relative = path.relative(scope, candidate);

  return (
    relative === "" ||
    (
      relative !== ".." &&
      !relative.startsWith(`..${path.sep}`) &&
      !path.isAbsolute(relative)
    )
  );
}

export function assertPathAllowed({
  candidatePath,
  allowedPaths = [],
  forbiddenPaths = [],
}) {
  const candidate = normalizeCandidate(candidatePath);

  if (!Array.isArray(allowedPaths) || !Array.isArray(forbiddenPaths)) {
    throw new TypeError("mutation scope lists must be arrays");
  }

  const forbidden = forbiddenPaths.some((entry) =>
    isWithinScope(candidate, normalizeCandidate(entry))
  );

  if (forbidden) {
    const err = new Error(
      `forbidden mutation path: ${candidatePath}`
    );
    err.code = "FORBIDDEN_MUTATION_PATH";
    throw err;
  }

  const allowed = allowedPaths.some((entry) =>
    isWithinScope(candidate, normalizeCandidate(entry))
  );

  if (!allowed) {
    const err = new Error(
      `path outside allowed mutation scope: ${candidatePath}`
    );
    err.code = "OUTSIDE_MUTATION_SCOPE";
    throw err;
  }

  return true;
}

export function assertMutationScopeAllowed(envelope, candidatePath) {
  return assertPathAllowed({
    candidatePath,
    allowedPaths: envelope?.mutation_scope?.allowed_paths ?? [],
    forbiddenPaths: envelope?.mutation_scope?.forbidden_paths ?? [],
  });
}
