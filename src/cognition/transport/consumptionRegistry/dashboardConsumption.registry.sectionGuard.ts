import {
  DASHBOARD_CONSUMPTION_ALLOWED_SECTIONS
} from "./dashboardConsumption.registry.constants";

import {
  DashboardConsumptionRegistryEntry
} from "./dashboardConsumption.registry.types";

export function assertValidConsumptionSection(
  entry: DashboardConsumptionRegistryEntry
): void {

  if (!DASHBOARD_CONSUMPTION_ALLOWED_SECTIONS.includes(entry.section as any)) {
    throw new Error(
      "Invalid dashboard consumption section: " + entry.section
    );
  }

}
