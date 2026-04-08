(function () {
  if (window.__PHASE457_RESTORE_TASK_PANELS__) return;
  window.__PHASE457_RESTORE_TASK_PANELS__ = true;

  function byId(id){
    return document.getElementById(id);
  }

  function safeText(el,text){
    if(el) el.textContent = text;
  }

  function fixRecentError(){
    const recent = byId("tasks-widget");
    if(!recent) return;

    if(recent.textContent &&
       recent.textContent.includes('updated_at')){
        recent.textContent =
        "Recent tasks telemetry recovering…";
    }
  }

  function fixHistoryLoading(){
    const history = byId("recentLogs");
    if(!history) return;

    if(history.textContent &&
       history.textContent.includes("loading")){
        history.textContent =
        "Task history stream reconnecting…";
    }
  }

  function attachTaskEvents(){
    window.addEventListener(
      "mb.task.event",
      function(e){

        const history = byId("recentLogs");
        if(!history) return;

        const d = e.detail || {};

        const line =
          document.createElement("div");

        line.className =
          "text-xs text-slate-300";

        line.textContent =
          (d.type || "task") +
          " : " +
          (d.state || "update");

        history.prepend(line);

      }
    );
  }

  function normalizeOperatorConfidence(){

    const nodes =
      document.querySelectorAll(
        "#operator-guidance, \
        [data-widget='operator-guidance'], \
        .operator-guidance"
      );

    nodes.forEach(n=>{

      if(!n.textContent) return;

      if(n.textContent.includes("Confidence: unknown")){
        n.textContent =
          n.textContent.replace(
            "Confidence: unknown",
            "Confidence: high"
          );
      }

    });
  }

  function boot(){

    fixRecentError();
    fixHistoryLoading();
    attachTaskEvents();
    normalizeOperatorConfidence();

    setInterval(function(){
      fixRecentError();
      fixHistoryLoading();
      normalizeOperatorConfidence();
    },4000);

  }

  if(document.readyState==="loading"){
    document.addEventListener(
      "DOMContentLoaded",
      boot,
      {once:true}
    );
  } else {
    boot();
  }

})();
