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
        <li>Governance: {signals?.governance ?? "—"}</li>
        <li>Execution: {signals?.execution ?? "—"}</li>
        <li>Approval: {signals?.approval ?? "—"}</li>
        <li>Execution Mode: {signals?.executionMode ?? "—"}</li>
      </ul>
    </section>
  );
}
