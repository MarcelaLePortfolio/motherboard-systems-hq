TERMINAL-SAFE CODEBLOCK PROTOCOL (MANDATORY)

ALL ENGINEERING OUTPUTS MUST FOLLOW:

1. SINGLE CODEBLOCK RULE
- All commands must exist inside ONE codeblock
- No commands outside the codeblock
- No split blocks

2. ZERO NARRATIVE RULE
- No explanation inside the codeblock
- No comments unless operationally required
- No descriptive text

3. EXECUTABLE OUTPUT RULE
- Must be copy-paste runnable
- No placeholders
- No partial commands

4. ROOT ANCHOR RULE
Always begin with:
cd "$(git rev-parse --show-toplevel)"

5. FILE WRITE RULE
- All artifacts must be written to docs/ or appropriate directory
- Use full overwrite pattern:

cat > filepath <<'EOF'

6. VERSION CONTROL RULE
Every operation must end with:

git add .
git commit -m "clear, scoped message"
git push

7. CHECKPOINT DISCIPLINE
- Tag when stabilizing:

git tag -a <tag_name> -m "checkpoint"
git push origin <tag_name>

8. MUTATION CONTROL
- One concern per execution
- No multi-layer changes
- No implicit dependencies

9. ORDERING INVARIANT
Definition → Proof → Isolation → Expansion

10. FAILURE RULE
- If uncertain: STOP
- Do not guess
- Do not simulate

THIS PROTOCOL IS NON-OPTIONAL.
