try {
  // ⚠️ Insert into tasks table only if not already present
  const existingTask = await db.query.tasks.findFirst({
    where: (t, { eq }) => eq(t.id, id),
  });

  if (!existingTask) {
    await db.insert(tasks).values({
      id,
      type,
      status,
      actor,
      payload,
      result,
      file_hash,
      created_at: now,
      completed_at: now,
    });
  }

  // ✅ Always insert into task_events table
  await db.insert(task_events).values({
    id: uuidv4(),
    task_id: id,
    actor,
    type: eventType,
    status,
    payload,
    result,
    file_hash,
    created_at: now,
  });

  // ✅ Always insert into task_output table
  await db.insert(task_output).values({
    id: uuidv4(),
    task_id: id,
    actor,
    type: eventType,
    result,
    reflection,
    created_at: now,
  });
} catch (err) {
  console.error('logTask: failed to insert/update tasks', err);
}
