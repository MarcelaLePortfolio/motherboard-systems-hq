import type {
  MatildaSupportSourceReference,
} from "../scripts/utils/ollamaChat";

export interface MatildaPersistedSupportProvenance {
  supportSourceReferences:
    MatildaSupportSourceReference[];
  evidenceSufficient: boolean;
}

export function createMatildaPersistedSupportProvenance(
  supportSourceReferences:
    MatildaSupportSourceReference[],
  evidenceSufficient: boolean,
): MatildaPersistedSupportProvenance {
  return {
    supportSourceReferences:
      supportSourceReferences.map(
        (reference) => ({ ...reference }),
      ),
    evidenceSufficient,
  };
}

export function readMatildaPersistedSupportProvenance(
  supportingRawEvidence: string,
): MatildaPersistedSupportProvenance | null {
  let parsed: unknown;

  try {
    parsed = JSON.parse(supportingRawEvidence);
  } catch {
    return null;
  }

  if (
    !parsed ||
    typeof parsed !== "object" ||
    Array.isArray(parsed)
  ) {
    return null;
  }

  const record =
    parsed as Record<string, unknown>;

  const rawReferences =
    record.support_source_references;

  const evidenceSufficient =
    record.evidence_sufficient;

  if (
    !Array.isArray(rawReferences) ||
    typeof evidenceSufficient !== "boolean"
  ) {
    return null;
  }

  const references:
    MatildaSupportSourceReference[] = [];

  for (const reference of rawReferences) {
    if (
      !reference ||
      typeof reference !== "object" ||
      Array.isArray(reference)
    ) {
      return null;
    }

    const candidate =
      reference as Record<string, unknown>;

    if (candidate.type === "conversation_turn") {
      if (
        typeof candidate.sourceTurnId !== "string" ||
        !candidate.sourceTurnId.trim()
      ) {
        return null;
      }

      references.push({
        type: "conversation_turn",
        sourceTurnId:
          candidate.sourceTurnId.trim(),
      });

      continue;
    }

    if (
      candidate.type ===
      "project_context_excerpt"
    ) {
      if (
        typeof candidate.relativePath !== "string" ||
        !candidate.relativePath.trim() ||
        typeof candidate.lineNumber !== "number" ||
        !Number.isInteger(candidate.lineNumber) ||
        candidate.lineNumber < 1
      ) {
        return null;
      }

      references.push({
        type: "project_context_excerpt",
        relativePath:
          candidate.relativePath.trim(),
        lineNumber: candidate.lineNumber,
      });

      continue;
    }

    return null;
  }

  return {
    supportSourceReferences: references,
    evidenceSufficient,
  };
}
