/*
Phase 293 — Governance Advisory Presenter
Deterministic presentation builder (read-only cognition layer)
No routing
No execution
No mutation
*/

export type GovernanceSignal = {
  id: string
  severity: string
}

export type GovernanceSeverityGroup = {
  severity: string
  count: number
  signals: GovernanceSignal[]
}

export type GovernancePresentation = {
  total_signals: number
  groups: GovernanceSeverityGroup[]
}

const SEVERITY_ORDER = [
  "critical",
  "risk",
  "warning",
  "info"
]

export function groupSignalsBySeverity(
  signals: GovernanceSignal[]
): GovernanceSeverityGroup[] {

  const map = new Map<string, GovernanceSignal[]>()

  for (const signal of signals) {

    if (!map.has(signal.severity)) {
      map.set(signal.severity, [])
    }

    map.get(signal.severity)!.push(signal)

  }

  const groups: GovernanceSeverityGroup[] = []

  for (const [severity, items] of map.entries()) {

    groups.push({
      severity,
      count: items.length,
      signals: items
    })

  }

  groups.sort((a,b) => {
    return (
      SEVERITY_ORDER.indexOf(a.severity)
      - SEVERITY_ORDER.indexOf(b.severity)
    )
  })

  return groups

}

export function buildGovernancePresentation(
  signals: GovernanceSignal[]
): GovernancePresentation {

  const groups = groupSignalsBySeverity(signals)

  return {
    total_signals: signals.length,
    groups
  }

}
