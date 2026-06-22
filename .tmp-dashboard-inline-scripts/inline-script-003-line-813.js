(function () {
  async function safeJson(url) {
    try {
      const res = await fetch(url, { cache: "no-store" });
      if (!res.ok) return null;
      return await res.json();
    } catch (_) {
      return null;
    }
  }

  function setGuidance(text, metaText) {
    const response = document.getElementById("operator-guidance-response");
    const meta = document.getElementById("operator-guidance-meta");
    if (response) {
      response.textContent = text;
      response.style.whiteSpace = "pre-wrap";
    }
    if (meta) {
      meta.textContent = metaText;
    }
  }

  function extractGuidanceText(data) {
    if (!data || typeof data !== "object") return null;
    if (typeof data.guidance === "string" && data.guidance.trim()) return data.guidance.trim();
    if (data.guidance && typeof data.guidance === "object") {
      for (const key of ["summary", "message", "text", "content", "body", "note"]) {
        if (typeof data.guidance[key] === "string" && data.guidance[key].trim()) {
          return data.guidance[key].trim();
        }
      }
    }
    for (const key of ["summary", "message", "text", "content", "body", "situationSummary"]) {
      if (typeof data[key] === "string" && data[key].trim()) return data[key].trim();
    }
    return null;
  }

  async function refreshOperatorGuidance() {
    const guidanceData = await safeJson("/api/guidance");
    if (guidanceData && guidanceData.guidance_available === true) {
      const text = extractGuidanceText(guidanceData) || "Live guidance available.";
      setGuidance(text, "Sources: /api/guidance");
      return;
    }

    const systemHealth = await safeJson("/diagnostics/system-health");
    const fallbackText =
      extractGuidanceText(systemHealth) ||
      "System stable. No active guidance stream.";
    setGuidance(fallbackText, "Sources: diagnostics/system-health (fallback)");
  }

  if (document.readyState === "loading") {
    document.addEventListener("DOMContentLoaded", refreshOperatorGuidance, { once: true });
  } else {
    refreshOperatorGuidance();
  }
})();
