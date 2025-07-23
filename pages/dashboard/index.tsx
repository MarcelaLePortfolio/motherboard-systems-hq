import OpsStreamTicker from "../../components/OpsStreamTicker";

export default function DashboardHome() {
  return (
    <div className="min-h-screen bg-white text-black">
      <OpsStreamTicker />
      <main className="max-w-5xl mx-auto p-6">
        <h1 className="text-2xl font-bold mb-4">📋 Project Tracker</h1>
        <p>This is your home dashboard. More widgets to come.</p>
        <ul className="space-y-3 mt-6">
          {[
            "Design new homepage",
            "Prepare investor presentation",
            "Implement authentication",
            "Conduct user interviews"
          ].map((task, i) => (
            <li key={i} className="flex items-center justify-between bg-gray-100 p-4 rounded-md">
              <span>{task}</span>
              <button className="text-sm px-3 py-1 bg-white border border-gray-400 rounded hover:bg-gray-200">
                Request Modification
              </button>
            </li>
          ))}
        </ul>
      </main>
    </div>
  );
}
