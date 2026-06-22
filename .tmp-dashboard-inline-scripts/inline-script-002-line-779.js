(() => {

  const phase487ReasoningButtonHtml = '<span>Confidence: limited</span><br><button id="phase493-view-reasoning" style="margin-top:6px;font-size:12px;opacity:0.8;">View reasoning</button>';

  function repairConfidenceMeta() {

    const el = document.getElementById("operator-guidance-meta");

    if (!el) return;

    if (el.innerHTML.includes(phase487ReasoningButtonHtml)) {

      el.innerHTML = el.innerHTML.replace(phase487ReasoningButtonHtml, "Confidence: limited");

    }

  }

  if (document.readyState === "loading") {

    document.addEventListener("DOMContentLoaded", repairConfidenceMeta, { once: true });

  } else {

    repairConfidenceMeta();

  }

})();
