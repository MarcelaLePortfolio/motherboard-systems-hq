function enforceRetryContract(req, res, next) {
  const body = req.body || {};

  if (body.kind !== "retry") {
    return next();
  }

  // Ensure deterministic retry strategy
  const allowedStrategies = new Set(["standard", "fresh-context"]);

  if (!body.strategy) {
    body.strategy = "standard";
  }

  if (!allowedStrategies.has(body.strategy)) {
    return res.status(400).json({
      error: "INVALID_RETRY_STRATEGY",
      allowed: Array.from(allowedStrategies)
    });
  }

  if (!body.meta || !body.meta.retry_of_task_id) {
    return res.status(400).json({
      error: "MISSING_RETRY_CONTEXT"
    });
  }

  // Freeze intent (prevent UI-only ambiguity)
  body.source = body.source || "execution-inspector";
  req.body = body;

  next();
}

module.exports = { enforceRetryContract };
