export default function OpsStreamTicker() {
  return (
    <div className="w-full bg-gray-900 text-white text-sm py-1 px-4 font-mono flex justify-between items-center">
      <span>🚦 Ops Stream: Cade merged snapshot · Effie updated state</span>
      <a href="/ops/history" className="underline text-blue-300 hover:text-blue-100 ml-4">View All</a>
    </div>
  );
}
