export type DashboardContractPrimitive =
  | string
  | number
  | boolean
  | null;

export type DashboardContractValue =
  | DashboardContractPrimitive
  | readonly DashboardContractValue[]
  | { readonly [key: string]: DashboardContractValue };

export interface DashboardConsumptionContract {
  readonly contractId: string;
  readonly version: string;
  readonly generatedAt: string;
  readonly source: string;
  readonly section: string;
  readonly payload: Readonly<Record<string, DashboardContractValue>>;
  readonly metadata?: Readonly<Record<string, DashboardContractValue>>;
}

export interface DashboardConsumptionEntry {
  readonly key: string;
  readonly value: DashboardContractValue;
}

export interface DashboardConsumptionSection {
  readonly contractId: string;
  readonly version: string;
  readonly generatedAt: string;
  readonly source: string;
  readonly section: string;
  readonly entries: readonly DashboardConsumptionEntry[];
}

export interface DashboardConsumptionAdapter {
  readonly contractId: string;
  readonly section: string;
  readonly entries: readonly DashboardConsumptionEntry[];
}

export type DashboardConsumptionMapper = (
  contract: DashboardConsumptionContract
) => DashboardConsumptionAdapter;
