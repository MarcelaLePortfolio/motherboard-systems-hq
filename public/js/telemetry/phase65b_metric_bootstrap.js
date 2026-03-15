/*
PHASE 65B SAFE TELEMETRY BOOTSTRAP

SAFE RULES:
NO SCRIPT ORDER CHANGE
NO BUNDLE MUTATION
ISOLATED LOADER ONLY
*/

(function(){

function loadScript(src){

    const s = document.createElement("script");

    s.src = src;

    s.defer = true;

    document.body.appendChild(s);

}

function init(){

    loadScript("/js/telemetry/running_tasks_metric.js");

}

if(document.readyState === "loading"){
    document.addEventListener("DOMContentLoaded", init);
}else{
    init();
}

})();
