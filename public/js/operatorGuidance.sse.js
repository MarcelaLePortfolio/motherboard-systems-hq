(function () {
  const ENDPOINT = "/events/operator-guidance";

  function safe(id){
    return document.getElementById(id);
  }

  function render(payload){
    const responseEl = safe("operator-guidance-response");
    const metaEl = safe("operator-guidance-meta");

    if(!responseEl || !metaEl) return;

    const text =
      payload?.guidance?.message ||
      payload?.message ||
      "Guidance stream active.";

    const confidence =
      payload?.confidence ||
      payload?.guidance?.confidence ||
      "unknown";

    const sources =
      payload?.sources ||
      payload?.guidance?.sources ||
      ["system-health"];

    responseEl.innerHTML = text;

    metaEl.innerHTML =
      "Confidence: " + confidence +
      "<br>Sources: " + sources.join(", ");
  }

  try{
    const stream = new EventSource(ENDPOINT);

    stream.addEventListener("operator_guidance", function(e){
      try{
        const payload = JSON.parse(e.data);
        render(payload);
      }catch(err){
        console.error("Operator guidance parse failure", err);
      }
    });

    stream.onerror = function(){
      console.warn("Operator guidance stream disconnected");
    };

    console.log("Operator guidance stream connected");

  }catch(err){
    console.error("Operator guidance SSE failed", err);
  }

})();
