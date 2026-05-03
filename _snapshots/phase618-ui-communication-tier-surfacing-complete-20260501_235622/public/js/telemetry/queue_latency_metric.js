/*
Phase 80.2 — Queue Latency Metric

Derived telemetry only.
No ownership conflicts.
Follows Phase 65 metric ownership rules.
*/

(function(){

let queueTimes = []

function recordLatency(task){
  if(!task) return

  if(task.created_ts && task.started_ts){
    const latency = task.started_ts - task.created_ts
    if(latency >= 0){
      queueTimes.push(latency)
      if(queueTimes.length > 200){
        queueTimes.shift()
      }
    }
  }
}

function avgLatency(){
  if(queueTimes.length === 0) return 0
  return Math.round(
    queueTimes.reduce((a,b)=>a+b,0) / queueTimes.length
  )
}

function processEvent(evt){
  if(!evt) return

  if(evt.type === "task.started"){
    recordLatency(evt.task || evt)
  }
}

if(window.telemetryBus && window.telemetryBus.subscribe){
  window.telemetryBus.subscribe("task-events", processEvent)
}

window.queueLatencyMetric = {
  getAverage: avgLatency
}

})()
