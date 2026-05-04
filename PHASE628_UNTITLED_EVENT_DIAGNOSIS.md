PHASE 628 UNTITLED EVENT DIAGNOSIS

Finding:
- The visible “untitled event” is from the seeded Phase 626/628 recovery event path.
- It is not evidence of a task title regression.

Database evidence:
- tasks.title is present:
  Phase 626 Guidance Visual Test
- task_events payload is guidance-only and does not include title.
- Event inspectors that render directly from task_events may label it generically unless they join/resolve task title from tasks.

Conclusion:
- Task title storage is intact.
- /api/tasks title path is intact.
- The generic/untitled display is an event-rendering/title-resolution gap only.

Next safe option:
- Add read-only event-title fallback by resolving event task_id against /api/tasks data, or leave as-is because it is seeded verification data.
