
import { db } from "./runtime";

export function mapOperationalIntake(row: any) {

  return {

    scheduler_authorized: Boolean(row.scheduler_authorized),

    worker_claim_authorized: Boolean(row.worker_claim_authorized),

    execution_authorized: Boolean(row.execution_authorized),

  };

}

