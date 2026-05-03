export function assertTransportReplaySafety(snapshot: unknown): boolean {
  if (snapshot === null || snapshot === undefined) return false

  if (typeof snapshot !== "object") return false

  try {
    JSON.stringify(snapshot)
    return true
  } catch {
    return false
  }
}
