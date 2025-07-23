import OpsStreamTicker from "@/components/OpsStreamTicker";

export default function DashboardHome() {
  return (
    <div>
      <OpsStreamTicker />
      <main className="max-w-5xl mx-auto p-6">
        <h1 className="text-2xl font-bold mb-4">📋 Project Tracker</h1>
        <p>This is your home dashboard. More widgets to come.</p>
      </main>
    </div>
  );
}
