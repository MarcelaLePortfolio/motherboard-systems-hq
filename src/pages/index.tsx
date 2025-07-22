import AgentStatusRow from "@/components/AgentStatusRow";
import Image from "next/image";

export default function Home() {
  return (
    <main className="flex justify-center items-center min-h-screen bg-gray-50 p-4">
      <div className="w-full max-w-2xl rounded-xl border shadow-lg bg-white px-6 py-10">
        <h1 className="text-3xl font-bold text-center">Motherboard Dash</h1>
        <p className="text-center text-gray-500 italic mt-1">Command Console</p>

        <AgentStatusRow />

        <div className="mt-6 space-y-2 bg-gray-100 p-4 rounded-md">
          <div className="bg-gray-200 rounded-md px-3 py-2 text-sm">
            What’s the status of our marketing campaign?
          </div>
          <div className="bg-blue-100 rounded-md px-3 py-2 text-sm text-right">
            Our marketing campaign is still in progress.
          </div>
          <div className="flex mt-2">
            <input type="text" placeholder="Send a message..." className="flex-1 px-3 py-2 border rounded-l-md" />
            <button className="px-4 bg-violet-600 text-white rounded-r-md">
              <Image src="/send-icon.svg" alt="Send" width={20} height={20} />
            </button>
          </div>
        </div>

        <div className="mt-10">
          <div className="flex space-x-6 justify-center border-b pb-2 mb-3 font-medium">
            <button className="text-violet-600 border-b-2 border-violet-600 pb-1">Project Activity</button>
            <button className="text-gray-600">Tasks</button>
            <button className="text-gray-600">Settings</button>
          </div>

          <h2 className="text-xl font-semibold mb-4">Project Tracker</h2>
          <ul className="space-y-3">
            {[
              { label: "Design new homepage", color: "bg-blue-600" },
              { label: "Prepare investor presentation", color: "bg-blue-600" },
              { label: "Implement authentication", color: "bg-teal-400" },
              { label: "Conduct user interviews", color: "bg-gray-400" },
            ].map((task) => (
              <li key={task.label} className="flex items-center justify-between">
                <div className="flex items-center space-x-3">
                  <span className={`w-3 h-3 rounded-full ${task.color}`}></span>
                  <span>{task.label}</span>
                </div>
                <button className="px-3 py-1 text-sm border border-gray-300 rounded-md hover:bg-gray-50">
                  Request Modification
                </button>
              </li>
            ))}
          </ul>
        </div>
      </div>
    </main>
  );
}
