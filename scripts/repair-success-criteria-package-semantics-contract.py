from pathlib import Path

path = Path("scripts/utils/ollamaChat.ts")
source = path.read_text()

replacements = [
    (
'''            "expectedOutcome",
            "proposedWork",''',
'''            "expectedOutcome",
            "successCriteria",
            "proposedWork",'''
    ),
    (
'''            expectedOutcome: {
              anyOf: [{ type: "null" }, { type: "string" }],
            },
            proposedWork:''',
'''            expectedOutcome: {
              anyOf: [{ type: "null" }, { type: "string" }],
            },
            successCriteria: {
              anyOf: [{ type: "null" }, { type: "string" }],
            },
            proposedWork:'''
    ),
    (
'''    "expectedOutcome",
    "proposedWork",''',
'''    "expectedOutcome",
    "successCriteria",
    "proposedWork",'''
    ),
    (
'''    expectedOutcome: null,
    proposedWork: null,''',
'''    expectedOutcome: null,
    successCriteria: null,
    proposedWork: null,'''
    ),
    (
'''"Otherwise set packageSemantics to one atomic non-authoritative artifact describing the user's requested outcome, proposed work, proposed artifacts, scope, constraints, and unresolved questions.",''',
'''"Otherwise set packageSemantics to one atomic non-authoritative artifact describing the user's requested outcome, success criteria, proposed work, proposed artifacts, scope, constraints, and unresolved questions.",'''
    ),
    (
'''"For expectedOutcome, proposedWork, proposedArtifacts, inScope, outOfScope, constraints, and unresolvedQuestions, use a concise non-empty string only when that semantic is actually established; otherwise use null.",''',
'''"For expectedOutcome, successCriteria, proposedWork, proposedArtifacts, inScope, outOfScope, constraints, and unresolvedQuestions, use a concise non-empty string only when that semantic is actually established; otherwise use null.",'''
    ),
]

for old, new in replacements:
    if old not in source:
        raise SystemExit(f"Expected anchor not found:\n{old}")
    source = source.replace(old, new, 1)

path.write_text(source)
print("Package Semantics contract repaired.")
