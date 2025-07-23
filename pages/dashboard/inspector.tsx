import LiveMemoryViewer from "@/ui/inspector_dashboard/live_memory_viewer";
import ReflectionOverlay from "@/ui/inspector_dashboard/reflection_overlay";
import PlaybackBrowser from "@/ui/inspector_dashboard/playback_browser";

export default function InspectorDashboard() {
  return (
    <div className="max-w-4xl mx-auto p-6">
      <h1 className="text-2xl font-bold mb-6">🛠 Inspector Dashboard</h1>
      <LiveMemoryViewer />
      <ReflectionOverlay />
      <PlaybackBrowser />
    </div>
  );
}
