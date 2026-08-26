#!/usr/bin/env bash
set -euo pipefail
cd "$(git rev-parse --show-toplevel)"

echo "=== IMPLEMENT PACKAGE SEMANTICS IEL TRANSPORT ==="
echo "EXPECTED_HEAD=881c3551"
echo "AUTHORIZED_BY=ee2d2495"
echo "SCOPE=IEL_PERSISTENCE_RECONSTRUCTION_AND_WORKFLOW_TRANSPORT_ONLY"
echo "DRAFT_SYNTHESIS_CHANGE=NO"

CURRENT_HEAD="$(git rev-parse --short HEAD)"
if [[ "${CURRENT_HEAD}" != "881c3551" ]]; then
  echo "UNEXPECTED_HEAD=${CURRENT_HEAD}"
  exit 1
fi

python3 - << 'PY'
from pathlib import Path

runtime = Path("db/matilda-interpretation-runtime.ts")
text = runtime.read_text()

def replace_once(old: str, new: str, label: str) -> None:
    global text
    count = text.count(old)
    if count != 1:
        raise SystemExit(f"STOP_{label}_EXPECTED_1_FOUND_{count}")
    text = text.replace(old, new, 1)

replace_once(
'''import {
  validateMatildaInvestigationLifecycleArtifact,
  type MatildaInvestigationLifecycleArtifact,
} from "../scripts/utils/ollamaChat";
''',
'''import {
  validateMatildaInvestigationLifecycleArtifact,
  validateMatildaPackageSemanticsArtifact,
  type MatildaInvestigationLifecycleArtifact,
  type MatildaPackageSemanticsArtifact,
} from "../scripts/utils/ollamaChat";
''',
"IEL_IMPORTS",
)

replace_once(
'''  supersession_status?: string | null;
  investigation_lifecycle?: MatildaInvestigationLifecycleArtifact | null;

};
''',
'''  supersession_status?: string | null;
  investigation_lifecycle?: MatildaInvestigationLifecycleArtifact | null;
  package_semantics?: MatildaPackageSemanticsArtifact | null;

};
''',
"IEL_CREATE_INPUT",
)

replace_once(
'''      lineage_references TEXT,

      investigation_lifecycle_json TEXT,
      supersession_status TEXT NOT NULL DEFAULT 'current'
''',
'''      lineage_references TEXT,

      investigation_lifecycle_json TEXT,
      package_semantics_json TEXT,
      supersession_status TEXT NOT NULL DEFAULT 'current'
''',
"IEL_CREATE_TABLE",
)

replace_once(
'''  if (
    !lifecycleColumns.some(
      (column) => column.name === "investigation_lifecycle_json",
    )
  ) {
    sqlite.exec(`
      ALTER TABLE matilda_interpretation_evidence_ledger
      ADD COLUMN investigation_lifecycle_json TEXT;
    `);
  }
}
''',
'''  if (
    !lifecycleColumns.some(
      (column) => column.name === "investigation_lifecycle_json",
    )
  ) {
    sqlite.exec(`
      ALTER TABLE matilda_interpretation_evidence_ledger
      ADD COLUMN investigation_lifecycle_json TEXT;
    `);
  }

  if (
    !lifecycleColumns.some(
      (column) => column.name === "package_semantics_json",
    )
  ) {
    sqlite.exec(`
      ALTER TABLE matilda_interpretation_evidence_ledger
      ADD COLUMN package_semantics_json TEXT;
    `);
  }
}
''',
"IEL_MIGRATION",
)

replace_once(
'''      lineage_references,

      investigation_lifecycle_json,
      supersession_status
''',
'''      lineage_references,

      investigation_lifecycle_json,
      package_semantics_json,
      supersession_status
''',
"IEL_INSERT_COLUMNS",
)

replace_once(
'''      @lineage_references,

      @investigation_lifecycle_json,
      @supersession_status
''',
'''      @lineage_references,

      @investigation_lifecycle_json,
      @package_semantics_json,
      @supersession_status
''',
"IEL_INSERT_VALUES",
)

replace_once(
'''    investigation_lifecycle_json:
      input.investigation_lifecycle === null ||
      input.investigation_lifecycle === undefined
        ? null
        : JSON.stringify(
            input.investigation_lifecycle,
          ),
    supersession_status: optionalText(input.supersession_status) || "current",
''',
'''    investigation_lifecycle_json:
      input.investigation_lifecycle === null ||
      input.investigation_lifecycle === undefined
        ? null
        : JSON.stringify(
            input.investigation_lifecycle,
          ),
    package_semantics_json:
      input.package_semantics === null ||
      input.package_semantics === undefined
        ? null
        : JSON.stringify(
            validateMatildaPackageSemanticsArtifact(
              input.package_semantics,
              "Matilda IEL write contains",
            ),
          ),
    supersession_status: optionalText(input.supersession_status) || "current",
''',
"IEL_WRITE_BINDINGS",
)

replace_once(
'''  lineage_references: string | null;
  investigationLifecycle: MatildaInvestigationLifecycleArtifact | null;
  supersession_status: string;
};
''',
'''  lineage_references: string | null;
  investigationLifecycle: MatildaInvestigationLifecycleArtifact | null;
  packageSemantics: MatildaPackageSemanticsArtifact | null;
  supersession_status: string;
};
''',
"IEL_READ_TYPE",
)

replace_once(
'''type InterpretationEvidenceLedgerStoredReadEntry = Omit<
  InterpretationEvidenceLedgerReadEntry,
  "investigationLifecycle"
> & {
  investigation_lifecycle_json: string | null;
};
''',
'''type InterpretationEvidenceLedgerStoredReadEntry = Omit<
  InterpretationEvidenceLedgerReadEntry,
  "investigationLifecycle" | "packageSemantics"
> & {
  investigation_lifecycle_json: string | null;
  package_semantics_json: string | null;
};
''',
"IEL_STORED_READ_TYPE",
)

reconstruction_anchor = '''export interface ListInterpretationEvidenceLedgerEntriesOptions {
'''
if text.count(reconstruction_anchor) != 1:
    raise SystemExit(
        f"STOP_RECONSTRUCTION_ANCHOR_EXPECTED_1_FOUND_{text.count(reconstruction_anchor)}"
    )

reconstruct_package = '''function reconstructPackageSemantics(
  value: string | null,
): MatildaPackageSemanticsArtifact | null {
  if (value === null) {
    return null;
  }

  let parsed: unknown;

  try {
    parsed = JSON.parse(value) as unknown;
  } catch {
    throw new Error(
      "Matilda IEL contains malformed package semantics JSON.",
    );
  }

  return validateMatildaPackageSemanticsArtifact(
    parsed,
    "Matilda IEL contains",
  );
}

'''

text = text.replace(
    reconstruction_anchor,
    reconstruct_package + reconstruction_anchor,
    1,
)

replace_once(
'''      lineage_references,

      investigation_lifecycle_json,

      supersession_status
''',
'''      lineage_references,

      investigation_lifecycle_json,

      package_semantics_json,

      supersession_status
''',
"IEL_SELECT_COLUMN",
)

replace_once(
'''    investigationLifecycle:
      reconstructInvestigationLifecycle(
        row.investigation_lifecycle_json,
      ),
    supersession_status: row.supersession_status,
''',
'''    investigationLifecycle:
      reconstructInvestigationLifecycle(
        row.investigation_lifecycle_json,
      ),
    packageSemantics:
      reconstructPackageSemantics(
        row.package_semantics_json,
      ),
    supersession_status: row.supersession_status,
''',
"IEL_READ_MAPPING",
)

runtime.write_text(text)

workflow = Path("server/matilda-chat-workflow.ts")
workflow_text = workflow.read_text()

old = '''      investigation_lifecycle:
        ollamaResult.investigationLifecycle,
    });
'''
new = '''      investigation_lifecycle:
        ollamaResult.investigationLifecycle,
      package_semantics:
        ollamaResult.packageSemantics,
    });
'''

count = workflow_text.count(old)
if count != 1:
    raise SystemExit(
        f"STOP_WORKFLOW_TRANSPORT_EXPECTED_1_FOUND_{count}"
    )

workflow.write_text(workflow_text.replace(old, new, 1))
PY

echo
echo "=== VERIFY IEL PACKAGE SEMANTICS MARKERS ==="
rg -n \
  'package_semantics|packageSemantics|validateMatildaPackageSemanticsArtifact|reconstructPackageSemantics' \
  db/matilda-interpretation-runtime.ts \
  server/matilda-chat-workflow.ts

echo
echo "=== VERIFY DRAFT SYNTHESIS UNCHANGED ==="
if git diff --quiet -- db/matilda-draft-synthesis-runtime.ts; then
  echo "DRAFT_SYNTHESIS_UNCHANGED=YES"
else
  echo "DRAFT_SYNTHESIS_UNCHANGED=NO"
  exit 1
fi

echo
echo "=== TYPECHECK ==="
npx tsc --noEmit --pretty false

echo
echo "=== DIFF CHECK ==="
git diff --check
git diff -- \
  db/matilda-interpretation-runtime.ts \
  server/matilda-chat-workflow.ts

echo
echo "IEL_TRANSPORT_SUBUNIT_VALIDATED=YES"
echo "DRAFT_SYNTHESIS_IMPLEMENTED=NO"

git add \
  implement-package-semantics-iel-transport.sh \
  db/matilda-interpretation-runtime.ts \
  server/matilda-chat-workflow.ts

git commit -m "Implement Matilda package semantics IEL transport"
git push

echo
echo "IEL_TRANSPORT_SUBUNIT_COMMITTED=YES"
echo "NEXT_ACTION=IMPLEMENT_DETERMINISTIC_LIVING_DRAFT_PACKAGE_SEMANTICS_SYNTHESIS"
