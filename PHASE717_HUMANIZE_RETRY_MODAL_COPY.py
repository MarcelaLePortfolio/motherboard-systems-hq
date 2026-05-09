
from pathlib import Path

path = Path("public/js/phase530_visible_panels_bridge.js")

text = path.read_text()

replacements = {

    'data-task-id="${taskId}" title="Explicit operator action: requeue this task through verified retry contract"':

    'data-task-id="${taskId}" data-task-title="${title}" title="Explicit operator action: requeue this task"',

    'data-task-id="${taskId}" title="Explicit operator action: retry with fresh context through verified retry contract"':

    'data-task-id="${taskId}" data-task-title="${title}" title="Explicit operator action: retry this task differently"',

    'async function phase717RetryTask(taskId, mode, button) {':

    'async function phase717RetryTask(taskId, mode, button, taskTitle) {',

    'const label = mode === "fresh-context" ? "retry differently" : "requeue";':

    'const label = mode === "fresh-context" ? "retry differently" : "requeue";\n\n    const displayName = taskTitle && taskTitle.trim() ? taskTitle.trim() : taskId;\n\n    const modalTitle = mode === "fresh-context" ? "Confirm retry action" : "Confirm requeue";',

    'const ok = await phase717RetryModal({ title: "Confirm retry action", message: `Submit ${label} for task ${taskId}?\\n\\nThis uses the verified /api/delegate-task retry contract and requires explicit operator confirmation.`, confirmLabel: "Submit", cancelLabel: "Cancel" });':

    'const ok = await phase717RetryModal({ title: modalTitle, message: `Submit ${label} for “${displayName}”?\\n\\nThis will create a new queued attempt for this task. Nothing will happen unless you choose Submit.`, confirmLabel: "Submit", cancelLabel: "Cancel" });',

    'const taskId = button.getAttribute("data-task-id");\n\n    const mode = retryDifferently ? "fresh-context" : "standard";\n\n    phase717RetryTask(taskId, mode, button);':

    'const taskId = button.getAttribute("data-task-id");\n\n    const taskTitle = button.getAttribute("data-task-title");\n\n    const mode = retryDifferently ? "fresh-context" : "standard";\n\n    phase717RetryTask(taskId, mode, button, taskTitle);',

}

for old, new in replacements.items():

    if old not in text:

        raise SystemExit(f"EXPECTED STRING NOT FOUND:\\n{old}")

    text = text.replace(old, new, 1)

path.write_text(text)

print("Retry modal copy humanized.")

