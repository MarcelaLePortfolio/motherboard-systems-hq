export const DASHBOARD_CONSUMPTION_REGISTRY_VERSION = "1.0.0";

export const DASHBOARD_CONSUMPTION_ALLOWED_SECTIONS = [
  "operator",
  "telemetry",
  "agents",
  "atlas",
  "system"
] as const;

export type DashboardConsumptionSection =
  typeof DASHBOARD_CONSUMPTION_ALLOWED_SECTIONS[number];
