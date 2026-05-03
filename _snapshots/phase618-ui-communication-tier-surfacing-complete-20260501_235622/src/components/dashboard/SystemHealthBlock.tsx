type SystemHealthSignals = {
  governance?: string;
  execution?: string;
  approval?: string;
  executionMode?: string;
};

export function SystemHealthBlock({ signals }: { signals?: SystemHealthSignals }) {
  return (
    <section aria-label="System status">
      <h2>SYSTEM STATUS</h2>
      <p>DEMO CAPABLE</p>
      <ul>
        <li>Governance: {signals?.governance ?? "UNKNOWN"}</li>
        <li>Execution: {signals?.execution ?? "UNKNOWN"}</li>
        <li>Approval: {signals?.approval ?? "UNKNOWN"}</li>
        <li>Execution Mode: {signals?.executionMode ?? "UNKNOWN"}</li>
      </ul>
    </section>
  );
}
