export async function ollamaPlan(message) {
  const lower = message.toLowerCase();

  // broaden trigger for frontend/dashboard work
  if (
    lower.includes("dashboard") &&
    (lower.includes("repair") ||
     lower.includes("restore") ||
     lower.includes("update") ||
     lower.includes("fix"))
  ) {
    return {
      action: "modify_dashboard",
      description: "Analyze and repair dashboard updatePanel logic and restore visible panels",
      input: message
    };
  }

  if (lower.includes("self-check") || lower.includes("verify system")) {
    return {
      action: "system_self_check",
      description: "Perform a simulated system health verification",
      input: message
    };
  }

  // fallback
  return {
    action: "generic_analysis",
    description: "Generic Cade fallback plan",
    input: message
  };
}
