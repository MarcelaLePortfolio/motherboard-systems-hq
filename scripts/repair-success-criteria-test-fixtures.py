from pathlib import Path

def replace(path_str, old, new, count=None):
    path = Path(path_str)
    source = path.read_text()
    if old not in source:
        raise SystemExit(f"Expected anchor not found in {path_str}:\n{old}")
    source = source.replace(old, new, count if count is not None else -1)
    path.write_text(source)

contract = "scripts/utils/ollamaChat.package-semantics-contract.test.ts"
observer = "scripts/utils/ollamaChat.package-semantics-observer.test.ts"
fidelity = "scripts/utils/ollamaChat.package-semantics-fidelity.test.ts"

replace(
    contract,
    '''    expectedOutcome: "A request-specific approval outcome.",
    proposedWork:''',
    '''    expectedOutcome: "A request-specific approval outcome.",
    successCriteria: "The requested outcome is verifiably complete.",
    proposedWork:''',
    1,
)

replace(
    contract,
    '''        expectedOutcome: null,
        proposedWork: null,''',
    '''        expectedOutcome: null,
        successCriteria: null,
        proposedWork: null,''',
    1,
)

replace(
    contract,
    '''        expectedOutcome: null,
        proposedWork: null,''',
    '''        expectedOutcome: null,
        successCriteria: null,
        proposedWork: null,''',
    1,
)

replace(
    observer,
    '''          expectedOutcome: "A visible checklist.",
          proposedWork:''',
    '''          expectedOutcome: "A visible checklist.",
          successCriteria: "The checklist is visible and complete.",
          proposedWork:''',
    1,
)

replace(
    observer,
    '''        expectedOutcome: "",
        proposedWork:''',
    '''        expectedOutcome: "",
        successCriteria: null,
        proposedWork:''',
    1,
)

replace(
    fidelity,
    '''  expectedOutcome,
  proposedWork:''',
    '''  expectedOutcome,
  successCriteria: null,
  proposedWork:''',
    1,
)

print("Success-criteria test fixtures repaired.")
