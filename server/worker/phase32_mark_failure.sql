WITH upd AS (
  UPDATE tasks
  SET attempts = attempts + 1,
      last_error = $2,
      last_error_at = now(),
      status = CASE
        WHEN (attempts + 1) >= max_attempts THEN 'failed'
        ELSE 'queued'
      END,
      next_run_at = CASE
        WHEN (attempts + 1) >= max_attempts THEN NULL
        ELSE now() + make_interval(
          secs => LEAST(300, (2 * power(2, (attempts + 1) - 1))::int)
        )
      END,
      updated_at = now()
  WHERE id = $1
    AND status = 'running'
  RETURNING *
)
SELECT * FROM upd;
