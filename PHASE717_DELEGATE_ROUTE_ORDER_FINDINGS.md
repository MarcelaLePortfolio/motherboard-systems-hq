
# Phase 717 Delegate Route Order Findings

## Critical Finding

`/api/delegate-task` is currently defined before `app.use(express.json())`.

This means JSON request bodies are not guaranteed to be parsed before the first delegate-task handler runs.

## Additional Finding

A second `/api/delegate-task` handler exists after `app.listen(...)`, but the earlier handler is the first matching route and responds first.

## Safe Conclusion

Do not wire or enable retry buttons yet.

The next safe patch is to normalize `/api/delegate-task` routing by ensuring:

1. `app.use(express.json())` runs before delegate-task routes.

2. Only one authoritative `/api/delegate-task` route remains.

3. `enforceRetryContract` is attached narrowly to that route.

4. `routeRetryExecution` runs after validation.

5. Docker validation passes before UI buttons become active.

