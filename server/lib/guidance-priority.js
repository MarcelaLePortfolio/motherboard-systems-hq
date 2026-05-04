export function applyGuidancePriority(guidance = []) {
  const rank = { critical: 0, warning: 1, info: 2 };

  return [...guidance].sort((a, b) => {
    const severityScore = (rank[a.severity] ?? 9) - (rank[b.severity] ?? 9);

    if (severityScore !== 0) return severityScore;

    const aTime = new Date(a.generated_at || 0).getTime();
    const bTime = new Date(b.generated_at || 0).getTime();

    return bTime - aTime;
  });
}
