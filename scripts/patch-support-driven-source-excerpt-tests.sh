#!/usr/bin/env bash
set -euo pipefail

cd "$HOME/Projects/motherboard-systems-hq-clean"

python3 - <<'PY'
from pathlib import Path

path = Path("scripts/utils/ollamaChat.ts")
text = path.read_text()

old = '''    const supportDrivenEvidenceSources =
      deduplicatedSupportSourceReferences
        .filter(
          (
            reference,
          ): reference is Extract<
            MatildaSupportSourceReference,
            { type: "project_context_excerpt" }
          > =>
            reference.type ===
            "project_context_excerpt",
        )
        .map((reference) => {
          const sourceKey =
            `${reference.relativePath}:${reference.lineNumber}`;

          const suppliedExcerpt =
            suppliedProjectContextExcerptBySource.get(
              sourceKey,
            );

          if (suppliedExcerpt === undefined) {
            throw new Error(
              "Ollama returned an evidence project-context source that was not supplied in this invocation.",
            );
          }

          return {
            reference,
            excerpt: suppliedExcerpt,
          };
        });

    const validatedEvidence =
      supportDrivenEvidenceSources.length > 0
        ? {
            sources: supportDrivenEvidenceSources,
          }
        : null;

    for (const reference of deduplicatedSupportSourceReferences) {
      if (reference.type === "conversation_turn") {
        if (
          !reference.sourceTurnId ||
          !suppliedConversationSourceIds.has(
            reference.sourceTurnId,
          )
        ) {
          throw new Error(
            "Ollama returned a conversation support reference that was not supplied in this invocation.",
          );
        }

        continue;
      }

      const sourceKey =
        `${reference.relativePath}:${reference.lineNumber}`;

      if (
        !reference.relativePath ||
        !reference.lineNumber ||
        !suppliedProjectContextSources.has(sourceKey)
      ) {
        throw new Error(
          "Ollama returned a project-context support reference that was not supplied in this invocation.",
        );
      }
    }
'''

new = '''    for (const reference of deduplicatedSupportSourceReferences) {
      if (reference.type === "conversation_turn") {
        if (
          !reference.sourceTurnId ||
          !suppliedConversationSourceIds.has(
            reference.sourceTurnId,
          )
        ) {
          throw new Error(
            "Ollama returned a conversation support reference that was not supplied in this invocation.",
          );
        }

        continue;
      }

      const sourceKey =
        `${reference.relativePath}:${reference.lineNumber}`;

      if (
        !reference.relativePath ||
        !reference.lineNumber ||
        !suppliedProjectContextSources.has(sourceKey)
      ) {
        throw new Error(
          "Ollama returned a project-context support reference that was not supplied in this invocation.",
        );
      }
    }

    const supportDrivenEvidenceSources =
      deduplicatedSupportSourceReferences
        .filter(
          (
            reference,
          ): reference is Extract<
            MatildaSupportSourceReference,
            { type: "project_context_excerpt" }
          > =>
            reference.type ===
            "project_context_excerpt",
        )
        .map((reference) => {
          const sourceKey =
            `${reference.relativePath}:${reference.lineNumber}`;

          const suppliedExcerpt =
            suppliedProjectContextExcerptBySource.get(
              sourceKey,
            );

          if (suppliedExcerpt === undefined) {
            throw new Error(
              "Validated project-context support reference has no supplied excerpt.",
            );
          }

          return {
            reference,
            excerpt: suppliedExcerpt,
          };
        });

    const validatedEvidence =
      supportDrivenEvidenceSources.length > 0
        ? {
            sources: supportDrivenEvidenceSources,
          }
        : null;
'''

if old not in text:
    raise SystemExit(
        "Expected support-driven validation block not found; stopping without speculative edit."
    )

path.write_text(text.replace(old, new, 1))
print("Reordered support validation before deterministic evidence construction.")
PY
