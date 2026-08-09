#!/usr/bin/env bash
set -euo pipefail

cd "$HOME/Projects/motherboard-systems-hq-clean"

echo "=== ADAPTIVE DETAIL — MIXED CONTENT LIVE BEHAVIOR DETERMINATION ==="

if [[ "$(git rev-parse --short HEAD)" != "15da3ece" ]]; then
  echo "STOP: HEAD no longer matches child-identity presentation checkpoint 15da3ece."
  exit 2
fi

unexpected="$(
  git status --porcelain |
  grep -vE '^\?\? scripts/document-adaptive-detail-mixed-content-live-failure\.sh$' ||
  true
)"

if [[ -n "$unexpected" ]]; then
  echo "STOP: unexpected working-tree changes exist:"
  printf '%s\n' "$unexpected"
  exit 2
fi

cat <<'FINDINGS'
Classification:

ADAPTIVE_DETAIL_CONTRACT_VALID_BUT_BEHAVIOR_NOT_SUPPORTED

Live behavioral result after child identity presentation separation:

Supplied parent project-context excerpt:

  docs/adaptive-detail-live-validation.md:20

Supplied deterministic child candidates:

  Relevant child:
    relativePath:
      docs/adaptive-detail-live-validation.md
    sourceStartLine:
      20
    sourceEndLine:
      20

    text:
      The selected-context validation observer is optional and absent from the
      normal production workflow.

  Immaterial child:
    relativePath:
      docs/adaptive-detail-live-validation.md
    sourceStartLine:
      22
    sourceEndLine:
      22

    text:
      A future unrelated migration may redesign the dashboard color palette
      after the current runtime work is complete.

Model-authored validated selectedContextSegments:

  [
    {
      "relativePath": "docs/adaptive-detail-live-validation.md",
      "sourceStartLine": 20,
      "sourceEndLine": 20
    },
    {
      "relativePath": "docs/adaptive-detail-live-validation.md",
      "sourceStartLine": 22,
      "sourceEndLine": 22
    }
  ]

Model-authored reply:

  No, the selected-context validation observer is optional and absent from the
  normal production workflow.

Model-authored supportSourceReferences:

  []

Derived Evidence Composition result:

  evidence:
    null

  evidenceSufficient:
    false

Model-authored durableInterpretation:

  The selected-context validation observer is not used in the normal production
  workflow.

Validated behavioral observations:

1. RELEVANT_CHILD_SELECTED=true

2. IMMATERIAL_CHILD_SELECTED=true

3. IMMATERIAL_DETAIL_IN_REPLY=false

4. PARENT_SUPPORT_PRESENT=false

5. The previous invalid parent support identity:

     docs/adaptive-detail-live-validation.md:22

   did not recur.

6. Therefore the child identity presentation separation successfully removed the
   previously observed parent/child support-identity collision in this run.

7. The narrower hypothesis:

     SUPPORT_IDENTITY_PRESENTATION_COLLISION

   is behaviorally supported for the provenance-collision problem.

8. That success does not establish Adaptive Detail Selection closure.

9. The model selected both supplied child candidates.

10. The second child was explicitly unrelated deferred work.

11. The reply correctly omitted that unrelated deferred-work detail.

12. Therefore selectedContextSegments did not accurately represent the material
    project-context content actually used in the immediate reply.

13. This creates a semantic-admission precision mismatch:

      reply materiality:
        relevant child only

      selectedContextSegments:
        relevant child + immaterial child

14. Runtime correctly accepted both child identities because both were valid
    members of the supplied deterministic candidate universe.

15. Runtime has no authority to remove the second child based on semantic
    relevance.

16. Doing so would require semantic post-model filtering and is not authorized.

17. The live run also produced no project_context_excerpt support reference.

18. The reply nevertheless states the fact supplied by the relevant project
    context:

      the validation observer is absent from the normal production workflow.

19. Consequently:

      supportSourceReferences = []

      evidence = null

      evidenceSufficient = false

20. The current runtime contract validates:

      project support -> at least one selected child

    when project support is authored for a parent with child candidates.

21. It does not establish the reverse relationship:

      selected project child -> corresponding parent support provenance

22. Therefore this live result exposes a second possible alignment question:

    whether a project-context-selected child that materially contributes to the
    reply must require its parent project-context excerpt to appear in
    supportSourceReferences.

23. That question must not be answered by changing validation immediately.

24. supportSourceReferences and selectedContextSegments have deliberately
    distinct responsibilities:

      selectedContextSegments:
        semantic project-context admission

      supportSourceReferences:
        support provenance

25. Whether semantic admission should deterministically imply support provenance
    is an architectural contract question that has not yet been established.

26. The current evidence therefore supports two unresolved observations:

    A. SELECTED_CONTEXT_MATERIALITY_PRECISION_MISMATCH

       The model selected an immaterial child even though that content did not
       appear in the reply.

    B. SELECTED_CONTEXT_SUPPORT_ALIGNMENT_UNRESOLVED

       The model used the relevant project-context fact in the reply while
       authoring no project-context support provenance.

27. These observations must not be collapsed into one speculative runtime fix.

28. The next unit must determine whether they share one ownership boundary or
    require separate successor investigations.

29. No evidence currently supports:

    - weakening exact child membership validation;
    - weakening parent support validation;
    - adding deterministic semantic filtering;
    - automatically synthesizing supportSourceReferences from selected children;
    - another wording-only Boundary Composition instruction;
    - another model invocation;
    - changing Evidence Composition;
    - changing evidenceSufficient;
    - changing retrieval;
    - changing segmentation;
    - changing ranking.

30. Boundary Composition remains closed.

31. Adaptive Detail Selection remains open.

32. Current capability state is:

    DETERMINISTIC_SEGMENTATION_SUPPORTED
    CHILD_RANGE_PROVENANCE_SUPPORTED
    CHILD_CANDIDATE_CONTEXT_TRANSPORT_SUPPORTED
    CHILD_PARENT_LINEAGE_SUPPORTED
    SELECTED_CONTEXT_STRUCTURED_CONTRACT_SUPPORTED
    SELECTED_CONTEXT_MEMBERSHIP_VALIDATION_SUPPORTED
    VALIDATION_OBSERVABILITY_SUPPORTED
    CHILD_IDENTITY_PRESENTATION_COLLISION_RESOLVED_IN_LIVE_RUN
    RELEVANT_CHILD_SELECTION_SUPPORTED_IN_LIVE_RUN
    IMMATERIAL_CHILD_OMISSION_FROM_SELECTION_NOT_SUPPORTED_IN_LIVE_RUN
    IMMATERIAL_DETAIL_OMISSION_FROM_REPLY_SUPPORTED_IN_LIVE_RUN
    PROJECT_SUPPORT_PROVENANCE_NOT_AUTHORED_IN_LIVE_RUN
    ADAPTIVE_DETAIL_MIXED_CONTENT_BEHAVIOR_NOT_SUPPORTED

Smallest next unit:

INVESTIGATE_ADAPTIVE_DETAIL_SELECTION_SUPPORT_ALIGNMENT

Purpose:

Determine the ownership and architecture of the two remaining live mismatches
before any additional implementation.

The investigation must answer:

1. Why can the model correctly omit immaterial content from reply while still
   selecting that content in selectedContextSegments?

2. Does the current prompt define selectedContextSegments as:

   - content materially necessary to the reply;
   - content considered during response composition;
   - content relevant to the question;
   - or some broader semantic-admission concept?

3. Is the current instruction:

   "Select only child segments whose content materially affects the immediate
   reply."

   sufficiently precise and internally consistent with the rest of the prompt?

4. Is another wording-only selection instruction supported by evidence, or would
   that repeat the already-exhausted prompt-layering pattern seen in Boundary
   Composition?

5. Does the structured selectedContextSegments artifact have a repository-backed
   purpose requiring exact correspondence with material reply content?

6. Is selectedContextSegments intended to represent:

   - pre-composition semantic admission;
   - post-composition utilized evidence;
   - or another lifecycle stage?

7. Can that lifecycle meaning explain why an admitted child may not appear in
   the final reply?

8. If so, is the current mixed-content validation criterion:

   IMMATERIAL_CHILD_SELECTED=false

   actually the correct architectural requirement?

9. If not, what repository-supported criterion should replace it?

10. Separately, determine whether selection of a project child should require
    parent support provenance.

11. Does the established supportSourceReferences contract require every
    project-context fact used in reply to be represented as support provenance?

12. If yes, is the missing parent support a model-authorship failure or an
    insufficient deterministic consistency contract?

13. If no, explain how:

      selected project context
      supportSourceReferences = []
      evidenceSufficient = false

    can remain semantically coherent.

14. Determine whether selected-context admission and support provenance require:

    - one-way consistency only;
    - two-way consistency;
    - or independent semantics.

15. Determine whether evidenceSufficient should remain exclusively
    support-driven under every possible resolution.

16. Determine whether the two observed mismatches share one safe implementation
    seam.

17. If they do not, explicitly separate the successor corridors rather than
    layering fixes.

Required classification:

Exactly one of:

ADAPTIVE_DETAIL_SELECTION_SEMANTICS_NEED_RECONCILIATION
ADAPTIVE_DETAIL_SUPPORT_ALIGNMENT_NEEDS_RECONCILIATION
ADAPTIVE_DETAIL_SELECTION_AND_SUPPORT_NEED_SEPARATE_RECONCILIATION
ADAPTIVE_DETAIL_LIVE_VALIDATION_CRITERION_NEEDS_REVISION

Do not implement in this unit.

Do not change ollamaChat.ts.

Do not change selectedContextSegments.

Do not change supportSourceReferences.

Do not change evidenceSufficient.

Do not change Evidence Composition.

Do not change validation observers.

Do not change retrieval.

Do not change segmentation.

Do not change ranking.

Do not add another prompt instruction.

Do not add another model invocation.

Do not perform semantic post-filtering.

Do not reopen Boundary Composition.

Preserve:

one user message -> one workflow -> one Ollama invocation.

Preserve Matilda as Interpretation Authority.
FINDINGS

echo
echo "=== BASELINE ==="
git status --short
echo "BRANCH: $(git branch --show-current)"
echo "HEAD: $(git rev-parse --short HEAD)"
echo "COMMIT: $(git log -1 --format=%s)"

echo
echo "=== DIFF CHECK ==="
git diff --check

echo
echo "ADAPTIVE_DETAIL_CONTRACT_VALID_BUT_BEHAVIOR_NOT_SUPPORTED"
echo "NEXT_UNIT=INVESTIGATE_ADAPTIVE_DETAIL_SELECTION_SUPPORT_ALIGNMENT"
echo "IMPLEMENTATION_NOT_STARTED"

git add scripts/document-adaptive-detail-mixed-content-live-failure.sh && \
git commit -m "Document Adaptive Detail mixed content live result" && \
git push
