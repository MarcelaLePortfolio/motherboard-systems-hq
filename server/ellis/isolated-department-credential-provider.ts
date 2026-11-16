import type {
  DepartmentServiceCredential,
} from "./department-service-identity";

import type {
  ServerControlledDepartmentCredentialProvider,
} from "./production-department-identity-admission";

/**
 * Isolated Stage 3 department credential provider.
 *
 * The credential source is supplied independently at construction.
 * Request callers cannot replace it through the resulting provider.
 *
 * This component does not establish source provenance, activate
 * credentials, connect to production persistence, or grant authority.
 */

export type IsolatedDepartmentCredentialSource = Readonly<{
  readCredentials:
    () => readonly DepartmentServiceCredential[] | null;
}>;

function validCredential(
  value: unknown,
): value is DepartmentServiceCredential {
  if (!value || typeof value !== "object") {
    return false;
  }

  const record = value as Partial<DepartmentServiceCredential>;

  return (
    typeof record.department_id === "string" &&
    record.department_id.trim().length > 0 &&
    typeof record.credential_digest === "string" &&
    /^[a-f0-9]{64}$/.test(record.credential_digest)
  );
}

export function createIsolatedDepartmentCredentialProvider(
  source: IsolatedDepartmentCredentialSource,
): ServerControlledDepartmentCredentialProvider {
  if (
    !source ||
    typeof source.readCredentials !== "function"
  ) {
    throw new Error(
      "Server-held department credential source required.",
    );
  }

  const readCredentials = source.readCredentials.bind(source);

  return () => {
    try {
      const records = readCredentials();

      if (
        !Array.isArray(records) ||
        records.length === 0 ||
        !records.every(validCredential)
      ) {
        return null;
      }

      const departments = new Set<string>();

      for (const record of records) {
        if (departments.has(record.department_id)) {
          return null;
        }

        departments.add(record.department_id);
      }

      return Object.freeze(
        records.map((record) =>
          Object.freeze({
            department_id: record.department_id,
            credential_digest: record.credential_digest,
          }),
        ),
      );
    } catch {
      return null;
    }
  };
}
