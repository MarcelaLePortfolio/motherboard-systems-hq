(()=>{(function(){let p=window,u="__HB";if(!p[u]){let c={ops:null,tasks:null,reflections:null,unknown:null};p[u]={record(w,v){let k=Object.prototype.hasOwnProperty.call(c,w)?w:"unknown";return c[k]=typeof v=="number"?v:Date.now(),c[k]},get(w){let v=Object.prototype.hasOwnProperty.call(c,w)?w:"unknown";return c[v]},snapshot(){return{...c}}}}let b=p.EventSource;if(!b||b.__hbWrapped)return;function S(c){let w=String(c||"");return w.includes("/events/ops")?"ops":w.includes("/events/task-events")||w.includes("/events/tasks")?"tasks":w.includes("/events/reflections")?"reflections":"unknown"}function i(c,w){let v=S(c);try{p[u].record(v,Date.now())}catch{}let k=new b(c,w),l=()=>{try{p[u].record(v,Date.now())}catch{}};try{k.addEventListener("open",l)}catch{}try{k.addEventListener("message",l)}catch{}let I=null;Object.defineProperty(k,"onmessage",{get(){return I},set(y){I=function(s){if(l(),typeof y=="function")return y.call(k,s)}},configurable:!0});try{k.addEventListener("error",l)}catch{}return k}i.prototype=b.prototype,i.__hbWrapped=!0,p.EventSource=i})();(function(){let u=window.__HB;function b(){return Date.now()}function S(l){return Math.max(0,Number(l)||0)}let i=15e3;function c(l){if(!l)return"\u2014";let I=Math.floor((b()-l)/1e3);return I<=0?"0s":`${I}s`}function w(){let l=document.getElementById("hb-badge");return l||(l=document.createElement("div"),l.id="hb-badge",l.setAttribute("role","status"),l.style.position="fixed",l.style.top="12px",l.style.right="12px",l.style.zIndex="9999",l.style.fontFamily="ui-sans-serif, system-ui, -apple-system, Segoe UI, Roboto, Helvetica, Arial",l.style.fontSize="12px",l.style.padding="6px 10px",l.style.borderRadius="999px",l.style.border="1px solid rgba(255,255,255,0.14)",l.style.background="rgba(0,0,0,0.55)",l.style.backdropFilter="blur(6px)",l.style.webkitBackdropFilter="blur(6px)",l.style.color="rgba(255,255,255,0.92)",l.style.boxShadow="0 8px 18px rgba(0,0,0,0.35)",l.style.userSelect="none",l.style.cursor="default",document.body.appendChild(l),l)}function v(l,I){l.textContent=I?`HB \u2713 (ops ${c(u&&u.get("ops"))}, tasks ${c(u&&u.get("tasks"))})`:`HB ! (ops ${c(u&&u.get("ops"))}, tasks ${c(u&&u.get("tasks"))})`}function k(){let l=w();if(!u||typeof u.get!="function"){l.textContent="HB ? (shim not loaded)";return}let I=u.get("ops"),y=u.get("tasks"),s=!!I&&S(b()-I)<=i,r=!!y&&S(b()-y)<=i;v(l,s&&r)}document.readyState==="loading"?document.addEventListener("DOMContentLoaded",()=>{k(),setInterval(k,1e3)}):(k(),setInterval(k,1e3))})();(()=>{"use strict";let p="/events/ops",u="/events/reflections",b=()=>Date.now();function S(a){try{return JSON.parse(a)}catch{return null}}function i(a){if(!Number.isFinite(a))return"\u2014";let d=Math.floor(a/1e3);if(d<60)return`${d}s`;let x=Math.floor(d/60);return x<60?`${x}m`:`${Math.floor(x/60)}h`}function c(a,d={},x=""){let f=document.createElement(a);for(let[t,n]of Object.entries(d))t==="class"?f.className=n:t==="style"?f.setAttribute("style",n):f.setAttribute(t,n);return x&&(f.textContent=x),f}function w(){if(document.getElementById("phase16-sse-style"))return;let a=c("style",{id:"phase16-sse-style"});a.textContent=`
      .sse-indicator {
        display:inline-flex;
        align-items:center;
        gap:6px;
        font-size:11px;
        line-height:1;
        opacity:.85;
        user-select:none;
        white-space:nowrap;
      }
      .sse-indicator .dot {
        width:7px; height:7px; border-radius:999px;
        background:#555;
        box-shadow:0 0 0 1px rgba(255,255,255,.08) inset;
      }
      .sse-indicator[data-connected="true"] .dot { background:#2dd4bf; }
      .sse-indicator[data-connected="false"] .dot { background:#f97316; }
      .sse-indicator .meta { font-variant-numeric: tabular-nums; }
    `,document.head.appendChild(a)}function v(a,d,x){if(w(),!a){let t=document.getElementById("phase16-sse-tray");t||(t=c("div",{id:"phase16-sse-tray",style:["position:fixed","left:10px","bottom:10px","display:flex","flex-direction:column","gap:6px","z-index:9999","pointer-events:none"].join(";")}),document.body.appendChild(t)),a=t}let f=document.getElementById(d);if(f)return f;f=c("span",{id:d,class:"sse-indicator","data-connected":"false"}),f.append(c("span",{class:"dot","aria-hidden":"true"}),c("span",{class:"meta"},`${x}: disconnected \xB7 last: \u2014`));try{if(a.matches&&a.matches("header,h1,h2,h3,h4,strong")){let t=c("span",{style:"margin-left:8px"});t.appendChild(f),a.appendChild(t)}else{let t=c("div",{style:"margin-top:4px"});t.appendChild(f),a.appendChild(t)}}catch{a.appendChild(f)}return f}function k(a,d,x,f){if(!a)return;a.dataset.connected=x?"true":"false";let t=a.querySelector(".meta");t&&(t.textContent=`${d}: ${x?"connected":"disconnected"} \xB7 last: ${f?i(b()-f):"\u2014"}`)}function l(){return window.__MB_STREAMS||(window.__MB_STREAMS={ops:{connected:!1,lastAt:0,state:{},es:null},reflections:{connected:!1,lastAt:0,state:{},es:null}}),window.__MB_STREAMS}function I(a,d){return(!a||typeof a!="object")&&(a={}),!d||typeof d!="object"?a:Object.assign(a,d)}function y(a,d){(!a||typeof a!="object")&&(a={});let x=d&&typeof d.path=="string"?d.path:"";if(!x)return a;let f=x.split(".").filter(Boolean);if(!f.length)return a;let t=a;for(let n=0;n<f.length-1;n++){let o=f[n];(!t[o]||typeof t[o]!="object")&&(t[o]={}),t=t[o]}return t[f[f.length-1]]=d.value,a}function s(a,d){return!!(typeof a=="string"&&a.endsWith(".state")||d&&typeof d=="object"&&(d.state&&typeof d.state=="object"||typeof d.type=="string"&&d.type.includes("state")||typeof d.event=="string"&&d.event.includes("state")))}function r(a){return!a||typeof a!="object"?a:a.payload!==void 0?a.payload:a.data!==void 0?a.data:a.delta!==void 0?a.delta:a.patch!==void 0?a.patch:a.state!==void 0?a.state:a}function h(a,d,x,f){if(typeof window<"u"&&window.__PHASE16_SSE_OWNER_STARTED)return null;let t=l();try{t[a].es&&t[a].es.close()}catch{}t[a].es=null;let n=window.__PHASE16_SSE_OWNER_STARTED?null:new EventSource(x);if(t[a].es=n,!n)return null;let o=()=>k(f,d,t[a].connected,t[a].lastAt);n.onopen=()=>{t[a].connected=!0,o()},n.onerror=()=>{t[a].connected=!1,o()};let g=(m,_)=>{t[a].lastAt=b();let C=S(_&&_.data?_.data:""),L=r(C);s(m,C)?t[a].state=L&&typeof L=="object"?L:{value:L}:L&&typeof L=="object"?typeof L.path=="string"&&"value"in L?t[a].state=y(t[a].state,L):t[a].state=I(t[a].state,L):L!=null&&(t[a].state=I(t[a].state,{lastValue:L})),o();try{window.dispatchEvent(new CustomEvent(`mb:${a}:update`,{detail:{event:m,state:t[a].state,raw:C}}))}catch{}};n.onmessage=m=>g("message",m);let e=["hello",`${a}.state`,`${a}.update`,`${a}.patch`,`${a}.delta`,"state","update","patch","delta"];for(let m of e)try{n.addEventListener(m,_=>g(m,_))}catch{}o()}function E(){return document.getElementById("ops-pill")||document.querySelector("[data-widget='ops-pill']")||document.querySelector(".ops-pill")||document.querySelector("#ops")||null}function T(){return document.getElementById("reflections-header")||document.getElementById("reflections")||document.querySelector("[data-panel='reflections']")||document.querySelector(".reflections")||Array.from(document.querySelectorAll("h1,h2,h3,h4,header,strong")).find(d=>(d.textContent||"").toLowerCase().includes("reflections"))||null}function A(){let a=v(E(),"ops-sse-indicator","OPS SSE"),d=v(T(),"reflections-sse-indicator","Reflections SSE");h("ops","OPS SSE",p,a),h("reflections","Reflections SSE",u,d),setInterval(()=>{let x=l();k(a,"OPS SSE",x.ops.connected,x.ops.lastAt),k(d,"Reflections SSE",x.reflections.connected,x.reflections.lastAt)},1e3)}document.readyState==="loading"?document.addEventListener("DOMContentLoaded",A,{once:!0}):A()})();(()=>{let p=document.getElementById("agent-status-container");if(!p){console.warn("agent-status-row.js: #agent-status-container not found.");return}let u=p.querySelector("h2");p.innerHTML="",u&&p.appendChild(u);let b=["Matilda","Atlas","Cade","Effie"],S={matilda:"\u{1F5E3}\uFE0F",atlas:"\u{1F9ED}",cade:"\u{1F4BB}",effie:"\u{1F4CA}"},i={},c=Object.create(null),w=60*1e3,v=document.getElementById("metric-agents");function k(t,n){t&&(t.textContent=n)}function l(t){if(typeof t=="number"&&Number.isFinite(t))return t;if(typeof t=="string"&&t.trim()){let n=Number(t);if(Number.isFinite(n))return n;let o=Date.parse(t);if(Number.isFinite(o))return o}return null}function I(){if(!v)return;let t=Date.now(),n=0;for(let o of b){let g=o.toLowerCase(),e=l(c[g]);e!=null&&t-e<=w&&(n+=1)}k(v,String(n))}k(v,"\u2014");let y=document.createElement("div");y.className="w-full flex flex-col gap-0.5",p.appendChild(y),b.forEach(t=>{let n=t.toLowerCase(),o=document.createElement("div");o.className="w-full min-h-0 rounded-md bg-slate-600/55 border border-slate-500/35 px-3 py-1.5 flex items-center justify-between shadow-sm";let g=document.createElement("div");g.className="flex items-center gap-3 min-w-0 h-[18px]";let e=document.createElement("span");e.className="inline-flex items-center justify-center shrink-0",e.textContent=S[n]||"\u2022",e.style.width="18px",e.style.minWidth="18px",e.style.height="18px",e.style.minHeight="18px",e.style.fontSize="14px",e.style.lineHeight="1",e.style.background="transparent",e.style.borderRadius="0",e.style.boxShadow="none",e.style.marginRight="0";let m=document.createElement("span");m.className="text-[13px] font-semibold tracking-tight text-slate-100/95 truncate",m.textContent=t;let _=document.createElement("span");_.className="text-[12px] font-medium text-slate-200/90 truncate",_.textContent="unknown",g.append(e,m),o.append(g,_),y.appendChild(o),i[n]={row:o,emoji:e,label:m,status:_}});let s="/events/ops",r=(typeof window<"u"&&window.__DISABLE_OPTIONAL_SSE)===!0;function h(t){if(typeof window<"u"&&window.__PHASE16_SSE_OWNER_STARTED)return"unknown";let n=(t||"").toLowerCase();return n?n.includes("error")||n.includes("failed")||n.includes("offline")?"error":n.includes("online")||n.includes("ready")||n.includes("ok")?"online":n.includes("queued")||n.includes("pending")||n.includes("init")||n.includes("running")?"pending":"unknown":"unknown"}function E(t,n){let o=i[t];if(!o)return;let g=h(n),e=n||"unknown";switch(o.status.textContent=e,o.row.className="w-full min-h-0 rounded-md border px-3 py-1.5 flex items-center justify-between shadow-sm",o.emoji.className="inline-flex items-center justify-center shrink-0",o.emoji.textContent=S[t]||"\u2022",o.emoji.style.display="inline-flex",o.emoji.style.width="18px",o.emoji.style.minWidth="18px",o.emoji.style.height="18px",o.emoji.style.minHeight="18px",o.emoji.style.fontSize="14px",o.emoji.style.lineHeight="1",o.emoji.style.background="transparent",o.emoji.style.borderRadius="0",o.emoji.style.boxShadow="none",o.emoji.style.marginRight="0",o.label.className="text-[13px] font-semibold tracking-tight truncate",o.status.className="text-[11px] font-medium truncate",g){case"online":o.row.classList.add("bg-gray-900","border-gray-700"),o.label.classList.add("text-slate-100"),o.status.classList.add("text-emerald-300/90");break;case"error":o.row.classList.add("bg-gray-900","border-gray-700"),o.label.classList.add("text-slate-100"),o.status.classList.add("text-rose-300/90");break;case"pending":o.row.classList.add("bg-gray-900","border-gray-700"),o.label.classList.add("text-slate-100"),o.status.classList.add("text-amber-200/90");break;default:o.row.classList.add("bg-gray-900","border-gray-700"),o.label.classList.add("text-slate-100"),o.status.classList.add("text-slate-300/75");break}}if(Object.keys(i).forEach(t=>E(t,"unknown")),r){console.warn("[agent-status-row] Optional SSE disabled:",s);return}function T(t){try{return JSON.parse(t)}catch{return null}}function A(t){return!t||typeof t!="object"?null:t.payload&&typeof t.payload=="object"?t.payload:t.data&&typeof t.data=="object"?t.data:t.state&&typeof t.state=="object"?t.state:t}function a(t){if(!t||typeof t!="object")return!1;let n=t.agents;if(!n||typeof n!="object")return!1;let o=!1;for(let[g,e]of Object.entries(n)){let m=String(g||"").toLowerCase();if(!i[m])continue;let _="unknown";if(typeof e=="string")_=e;else if(e&&typeof e=="object"){_=e.status??e.state??e.level??e.health??e.mode??"unknown";let C=e.at??e.ts??e.last_activity??e.lastActivity??e.last_seen??e.lastSeen??null;C!=null&&(c[m]=C)}E(m,String(_||"unknown")),o=!0}return I(),o}function d(t){if(!t||typeof t!="object")return!1;let n=(t.agent||t.actor||t.source||t.worker||t.name||"").toString().toLowerCase();if(!n||!i[n])return!1;let o=t.status??t.state??t.level??t.health??t.mode??"unknown",g=t.at??t.ts??t.last_activity??t.lastActivity??t.last_seen??t.lastSeen??null;return g!=null&&(c[n]=g),E(n,String(o||"unknown")),I(),!0}function x(t,n){let o=T(n.data);if(!o)return;let g=A(o);t==="ops.state"&&a(g)||a(o)||a(g)||(d(g),d(o))}let f;try{f=window.__PHASE16_SSE_OWNER_STARTED?null:new EventSource(s)}catch(t){console.error("agent-status-row.js: Failed to open OPS SSE connection:",t);return}f&&(f.onmessage=t=>x("message",t),f.addEventListener("hello",t=>x("hello",t)),f.addEventListener("ops.state",t=>x("ops.state",t)),f.addEventListener("state",t=>x("state",t)),f.addEventListener("update",t=>x("update",t)),f.onerror=t=>{console.warn("agent-status-row.js: OPS SSE error:",t),Object.keys(i).forEach(n=>E(n,"unknown")),k(v,"\u2014")})})();var D="__broadcastVisualizationInited",j=["Matilda","Cade","Effie"];function R(){let p=document.getElementById("broadcast-visual");if(!p)return;let u=[];for(let b=0;b<j.length;b++){let S=j[b];u.push('<div class="node" id="node-'+S+'">'+S+"</div>"),b<j.length-1&&u.push('<div class="arrow">\u279C</div>')}p.innerHTML=u.join("")}function $(){let p=0;setInterval(()=>{document.querySelectorAll(".node").forEach(i=>i.classList.remove("active"));let b="node-"+j[p],S=document.getElementById(b);S&&S.classList.add("active"),p=(p+1)%j.length},1500)}function H(){if(typeof window>"u"||typeof document>"u"||window[D])return;window[D]=!0;let p=()=>{R(),$()};document.readyState==="loading"?window.addEventListener("DOMContentLoaded",p):p()}typeof window<"u"&&(window.initBroadcastVisualization=H);(function(){if(!(typeof document>"u")){var p=document.getElementById("ops-dashboard-pill");if(!p){var u=document.querySelector("[data-ops-pill]");u&&(u.id="ops-dashboard-pill")}}})();(()=>{if(typeof window<"u"&&window.__PHASE16_SSE_OWNER_STARTED||typeof window>"u"||typeof EventSource>"u"||window.__opsGlobalsBridgeInitialized)return;window.__opsGlobalsBridgeInitialized=!0,typeof window.lastOpsHeartbeat>"u"&&(window.lastOpsHeartbeat=null),typeof window.lastOpsStatusSnapshot>"u"&&(window.lastOpsStatusSnapshot=null);let p="/events/ops";if((typeof window<"u"&&window.__DISABLE_OPTIONAL_SSE)===!0){console.warn("[ops-globals-bridge] Optional SSE disabled (Phase 16 pending):",p);return}let b=S=>{try{let i=JSON.parse(S.data||"null");if(!i)return;window.lastOpsHeartbeat=Math.floor(Date.now()/1e3),window.lastOpsStatusSnapshot=i}catch(i){console.warn("[ops-globals-bridge] Failed to parse OPS event:",i)}try{window.dispatchEvent(new CustomEvent("mb:ops:update",{detail:{event:"message",state:window.lastOpsStatusSnapshot}}))}catch{}};try{let S=window.__PHASE16_SSE_OWNER_STARTED?null:new EventSource(p);if(!S)return null;if(S.onmessage=b,S.addEventListener("hello",b),!S)return;S.onerror=i=>{console.warn("[ops-globals-bridge] EventSource error:",i)}}catch(S){console.warn("[ops-globals-bridge] Failed to init EventSource:",S)}})();(function(){if(typeof window>"u"||typeof document>"u"||window.location.pathname!=="/dashboard")return;var p=5e3,u="ops-dashboard-pill";function b(){var i=document.getElementById(u);return i||(i=document.createElement("span"),i.id=u,i.className="ops-pill ops-pill-unknown",i.textContent="OPS: Unknown",i.style.display="inline-block",document.body.firstChild?document.body.insertBefore(i,document.body.firstChild):document.body.appendChild(i),i)}function S(){var i=document.getElementById("ops-status-pill");i&&(i.style.display="none");var c=b();if(c){var w=typeof window.lastOpsHeartbeat=="number",v=w?"OPS: Online":"OPS: Unknown",k=w?"ops-pill-online":"ops-pill-unknown";c.classList.remove("ops-pill-unknown","ops-pill-online","ops-pill-stale","ops-pill-error"),c.classList.add(k),c.textContent=v}}S(),setInterval(S,p)})();(function(){function p(i){console.log("[matilda-chat]",i)}function u(i,c,w){if(i){var v=document.createElement("p");v.className="mb-1 text-sm";var k=c?c+": ":"";v.textContent=k+w,i.appendChild(v),i.scrollTop=i.scrollHeight}}function b(i,c,w){i&&(i.disabled=w,i.classList.toggle("opacity-60",w),i.textContent=w?"Sending...":"Send"),c&&(c.disabled=w)}async function S(){var i=document.getElementById("matilda-chat-root");if(!i){p("No #matilda-chat-root found; skipping wiring.");return}var c=document.getElementById("matilda-chat-transcript"),w=document.getElementById("matilda-chat-input"),v=document.getElementById("matilda-chat-send");if(window.appendMessage=window.appendMessage||function(y){try{var s=y&&y.role?String(y.role):"system",r=y&&(y.content??y.text??y.message)?String(y.content??y.text??y.message):"",h=s==="user"?"You":s==="matilda"?"Matilda":"System";u(c,h,r)}catch{}},window.__appendMessage=window.__appendMessage||window.appendMessage,!c||!w||!v){p("Missing one or more Matilda chat elements; aborting wiring.");return}function k(y){return(y||"").toString().trim()}async function l(){var y=k(w.value);if(y){u(c,"You",y),w.value="",b(v,w,!0);try{var s=await fetch("/api/chat",{method:"POST",headers:{"Content-Type":"application/json"},body:JSON.stringify({message:y,agent:"matilda"})});if(!s.ok){u(c,"Matilda","(error talking to /api/chat)");return}var r=await s.json(),h=r&&(r.reply||r.message||r.response)||"(no reply)";u(c,"Matilda",h)}catch(E){console.error(E),u(c,"Matilda","(network error)")}finally{b(v,w,!1)}}}v.addEventListener("click",l);var I=document.getElementById("matilda-chat-quick-check");I&&I.addEventListener("click",function(){w.value="Quick systems check from dashboard Phase 11.4.",l()}),w.addEventListener("keydown",function(y){y.key==="Enter"&&!y.shiftKey&&(y.preventDefault(),l())}),p("Matilda chat wiring complete.")}document.addEventListener("DOMContentLoaded",S)})();(function(){console.log("[dashboard-delegation] module loaded");function p(s){return document.getElementById(s)}function u(){var s=window.fetch,r=typeof s;return console.log("[dashboard-delegation] detected fetch type:",r),r!=="function"?(console.error("[dashboard-delegation] fetch is not a function; value:",s),null):s.bind(window)}function b(s){return String(s??"").replace(/&/g,"&amp;").replace(/</g,"&lt;").replace(/>/g,"&gt;").replace(/"/g,"&quot;").replace(/'/g,"&#39;")}function S(s){return'<pre class="mt-3 overflow-x-auto whitespace-pre-wrap break-words rounded-lg bg-black/20 p-3 text-xs text-gray-300">'+b(JSON.stringify(s,null,2))+"</pre>"}function i(s,r){var h=p("delegation-response"),E=p("delegation-status-panel");h&&(h.innerHTML=r,E&&(E.classList.remove("border-gray-700","border-teal-600","border-green-600","border-red-600","border-amber-500"),s==="sending"?E.classList.add("border-teal-600"):s==="success"?E.classList.add("border-green-600"):s==="error"?E.classList.add("border-red-600"):s==="waiting"?E.classList.add("border-amber-500"):E.classList.add("border-gray-700")))}function c(){i("idle","Awaiting operator input.<br>Results from delegation requests will appear here.")}function w(s){i("sending",'<div class="text-teal-300 font-medium">Sending delegation\u2026</div><div class="mt-2 text-gray-400">Preparing request for the orchestration layer.</div>'+(s?'<div class="mt-3 rounded-lg bg-black/20 p-3 text-xs text-gray-300 break-words">'+b(s)+"</div>":""))}function v(){i("waiting",'<div class="text-amber-300 font-medium">Still waiting on delegation response\u2026</div><div class="mt-2 text-gray-400">The request may still be processing.</div>')}function k(s){var r="Delegation accepted.";s&&typeof s=="object"&&(r=s.message||s.status||s.result||s.reply||s.ok&&"Delegation accepted."||r),i("success",'<div class="text-green-300 font-medium">'+b(r)+'</div><div class="mt-2 text-gray-400">Request completed successfully.</div>'+(s&&typeof s=="object"?S(s):""))}function l(s,r){i("error",'<div class="text-red-300 font-medium">Delegation failed.</div><div class="mt-2 text-gray-300">'+b(s||"Unknown error")+"</div>"+(r?'<div class="mt-3 text-xs text-gray-400 break-words">'+b(r)+"</div>":""))}async function I(){var s=p("delegation-input"),r=p("delegation-submit");if(!s){console.warn("[dashboard-delegation] delegation input not found at click time"),l("Delegation input field was not found.");return}var h=String(s.value||"").trim();if(!h){console.warn("[dashboard-delegation] empty delegation input; skipping"),l("Please enter a delegation request before submitting.");return}console.log("[dashboard-delegation] sending delegation:",h);var E=u();if(!E){console.error("[dashboard-delegation] aborting delegation because fetch is unavailable or invalid"),l("Browser fetch is unavailable.");return}var T=r&&r.textContent||"Submit Delegation",A=null;try{r&&(r.disabled=!0,r.textContent="Sending...",r.classList.add("opacity-70","cursor-not-allowed")),w(h),A=window.setTimeout(v,4e3);var a;try{a=await E("/api/delegate-task",{method:"POST",headers:{"Content-Type":"application/json",Accept:"application/json"},body:JSON.stringify({prompt:h,message:h,text:h,task:h})})}catch(f){throw console.error("[dashboard-delegation] fetch threw before response:",f),f}console.log("[dashboard-delegation] fetch returned:",{ok:a&&a.ok,status:a&&a.status,statusText:a&&a.statusText});var d=null,x="";try{x=await a.text(),d=x?JSON.parse(x):{}}catch(f){console.error("[dashboard-delegation] error parsing JSON response:",f),d={error:"Non-JSON response from /api/delegate-task",raw:x||""}}if(console.log("[dashboard-delegation] delegation response:",d),!a.ok){l(d&&(d.error||d.message||d.statusText)||"HTTP "+a.status+" "+(a.statusText||""),x);return}k(d)}catch(f){l(f&&f.message?f.message:String(f))}finally{A&&window.clearTimeout(A),r&&(r.disabled=!1,r.textContent=T,r.classList.remove("opacity-70","cursor-not-allowed"))}}function y(){var s=p("delegation-submit"),r=p("delegation-input");if(!s||!r){console.warn("[dashboard-delegation] delegation button or input not found in init");return}if(c(),s.dataset.delegationWired==="true"){console.log("[dashboard-delegation] Task Delegation wiring already active");return}s.dataset.delegationWired="true",s.addEventListener("click",I),r.addEventListener("keydown",function(h){(h.metaKey||h.ctrlKey)&&h.key==="Enter"&&(h.preventDefault(),I())}),console.log("[dashboard-delegation] Task Delegation wiring active")}document.readyState==="loading"?document.addEventListener("DOMContentLoaded",y,{once:!0}):y()})();(()=>{let p="/events/task-events",u="mb-task-events-panel",b="mb-task-events-feed",S="mb-task-events-counts",i="mb-task-events-panel-anchor";function c(){let n=document.getElementById(i);return n||document.body}function w(){if(document.getElementById(u))return;let n=c(),o=document.createElement("div");o.id=u;let g=n&&n.id===i;o.style.width=g?"100%":"360px",o.style.maxWidth=g?"100%":"calc(100vw - 24px)",o.style.maxHeight=g?"260px":"40vh",o.style.overflow="hidden",o.style.zIndex="9999",o.style.border="1px solid rgba(255,255,255,0.12)",o.style.borderRadius="14px",o.style.background="rgba(10,10,14,0.92)",o.style.backdropFilter="blur(10px)",o.style.boxShadow="0 10px 30px rgba(0,0,0,0.35)",o.style.color="rgba(255,255,255,0.92)",o.style.fontFamily="ui-sans-serif, system-ui, -apple-system, Segoe UI, Roboto, Helvetica, Arial",g?o.style.marginTop="12px":(o.style.position="fixed",o.style.right="12px",o.style.bottom="12px");let e=document.createElement("div");e.style.display="flex",e.style.alignItems="center",e.style.justifyContent="space-between",e.style.gap="8px",e.style.padding="10px 12px",e.style.borderBottom="1px solid rgba(255,255,255,0.10)";let m=document.createElement("div");m.textContent="Task Events",m.style.fontSize="12px",m.style.letterSpacing="0.06em",m.style.opacity="0.9";let _=document.createElement("div");_.style.display="flex",_.style.alignItems="center",_.style.gap="10px";let C=document.createElement("div");C.id=S,C.textContent="created:0  completed:0  failed:0",C.style.fontSize="11px",C.style.opacity="0.85",C.style.fontVariantNumeric="tabular-nums";let L=document.createElement("span");L.setAttribute("aria-label","task-events connection"),L.title="task-events connection",L.style.display="inline-block",L.style.width="10px",L.style.height="10px",L.style.borderRadius="999px",L.style.background="rgba(255,255,255,0.25)",L.style.boxShadow="0 0 0 2px rgba(255,255,255,0.08) inset";let O=document.createElement("button");O.type="button",O.textContent="\xD7",O.title="hide",O.style.cursor="pointer",O.style.border="1px solid rgba(255,255,255,0.14)",O.style.background="transparent",O.style.color="rgba(255,255,255,0.85)",O.style.borderRadius="10px",O.style.width="28px",O.style.height="24px",O.style.lineHeight="22px",O.style.fontSize="14px",O.onclick=()=>o.remove(),_.appendChild(L),_.appendChild(C),_.appendChild(O),e.appendChild(m),e.appendChild(_);let N=document.createElement("div");N.id=b,N.style.padding="10px 12px",N.style.overflow="auto",N.style.maxHeight=g?"200px":"calc(40vh - 46px)",o.appendChild(e),o.appendChild(N),n.appendChild(o),window.__MB_TASK_EVENTS_PANEL={dot:L,feed:N,counts:C},console.log("[phase22] task-events panel mounted (anchored=%s)",g)}function v(n){w();let o=window.__MB_TASK_EVENTS_PANEL?.dot;o&&(n==="open"?o.style.background="rgba(80,200,120,0.85)":n==="error"?o.style.background="rgba(240,90,90,0.85)":o.style.background="rgba(255,255,255,0.25)")}let k=new Set,l={created:0,completed:0,failed:0},Q=new Set,F=document.getElementById("metric-running");function U(){F||(F=document.getElementById("metric-running")),F&&(F.textContent=String(Q.size))}function z(n){return n&&typeof n=="object"?String(n.task_id??n.taskId??n.meta?.task_id??n.meta?.taskId??"").trim():""}function G(n,o){let g=String(n?.kind??o??"").toLowerCase(),e=String(n?.status??n?.meta?.status??"").toLowerCase(),m=z(n);if(!m)return;/task\.created|task\.started|task\.running|task\.queued|task\.resumed/.test(g)||/created|started|running|queued|pending|active/.test(e)?Q.add(m):(/task\.completed|task\.failed|task\.cancelled|task\.canceled|task\.done/.test(g)||/completed|failed|cancelled|canceled|done|error/.test(e))&&Q.delete(m),U()}function I(n){n==="task.created"&&(l.created+=1),n==="task.completed"&&(l.completed+=1),n==="task.failed"&&(l.failed+=1);let o=document.getElementById(S);o&&(o.textContent=`created:${l.created}  completed:${l.completed}  failed:${l.failed}`),U()}function y(n){if(typeof n=="number")return new Date(n).toISOString();if(typeof n=="string"&&n.trim()){let o=new Date(n);return Number.isNaN(o.getTime())?n.trim():o.toISOString()}return new Date().toISOString()}function s(n,o,g){let e=`${n||""} ${o||""} ${g||""}`.toLowerCase();return/fail|error|cancel|timeout/.test(e)?"terminal-error":/complete|done|success/.test(e)?"terminal-success":/queue|pending|retry|wait|hold|sleep/.test(e)?"waiting":/open|start|run|resume|lease|dispatch|ack|progress|update|active|heartbeat/.test(e)?"active":"neutral"}function r(n){return n==="terminal-error"?"rgba(240,90,90,0.95)":n==="terminal-success"?"rgba(80,200,120,0.95)":n==="waiting"?"rgba(250,204,21,0.95)":n==="active"?"rgba(96,165,250,0.95)":"rgba(255,255,255,0.18)"}function h(n,o){let g=y(n.ts),e=String(n.kind??o??"event"),m=n.task_id??n.taskId??"unknown",_=n.run_id??n.runId??"",C=n.actor??n.meta?.actor??n.meta?.owner??"",L=n.status??n.meta?.status??"",O=typeof n.cursor=="number"||typeof n.cursor=="string"?String(n.cursor):"",N=String(n.msg??n.message??"").trim(),B=[];B.push(`task=${m}`),_&&B.push(`run=${_}`),C&&B.push(`actor=${C}`),L&&B.push(`status=${L}`),O&&B.push(`cursor=${O}`),N&&B.push(N);let M=B.join(" \u2022 "),P=s(e,N,L);return{ts:g,kind:e,detail:M,tone:P}}function E(n,o){w();let g=document.getElementById(b);if(!g)return;let e=h(n,o),m=document.createElement("div");m.className=`phase61-task-event phase61-task-event-${e.tone}`,m.dataset.eventKind=e.kind,m.dataset.eventTone=e.tone,m.style.position="relative",m.style.display="grid",m.style.gridTemplateColumns="minmax(112px, 132px) minmax(150px, 170px) 1fr",m.style.gap="10px",m.style.alignItems="start",m.style.padding="10px 12px 10px 14px",m.style.marginBottom="8px",m.style.border="1px solid rgba(255,255,255,0.10)",m.style.borderRadius="12px",m.style.background="rgba(255,255,255,0.03)",m.style.lineHeight="1.35",m.style.fontSize="12px";let _=document.createElement("span");_.setAttribute("aria-hidden","true"),_.style.position="absolute",_.style.left="0",_.style.top="10px",_.style.bottom="10px",_.style.width="3px",_.style.borderRadius="999px",_.style.background=r(e.tone);let C=document.createElement("div");C.textContent=e.ts,C.style.color="rgba(255,255,255,0.68)",C.style.fontVariantNumeric="tabular-nums",C.style.whiteSpace="nowrap";let L=document.createElement("div");L.textContent=e.kind,L.style.color="rgba(255,255,255,0.92)",L.style.fontWeight="600",L.style.letterSpacing="0.01em",L.style.wordBreak="break-word";let O=document.createElement("div");O.textContent=e.detail||"\u2014",O.style.color="rgba(255,255,255,0.78)",O.style.wordBreak="break-word",m.appendChild(_),m.appendChild(C),m.appendChild(L),m.appendChild(O),g.prepend(m);let N=Array.from(g.children);if(N.length>60)for(let B=60;B<N.length;B++)N[B].remove()}function T(n){try{window.dispatchEvent(new CustomEvent("mb.task.event",{detail:n}))}catch{}}function A(n){try{return JSON.parse(n)}catch{return null}}function a(n,o){let g=typeof o=="string"?A(o):o,e=g&&typeof g=="object"?g:{kind:n,raw:o};n==="task.event"&&(e.actor==null&&e.meta&&typeof e.meta=="object"&&(e.actor=e.meta.actor??e.meta.owner??null),!e.kind&&e.type&&(e.kind=e.type),e.kind==="task.event"&&e.type&&(e.kind=e.type),e.task_id==null&&e.taskId!=null&&(e.task_id=e.taskId),e.run_id==null&&e.runId!=null&&(e.run_id=e.runId),e&&e.meta&&typeof e.meta=="object"&&(e.task_id==null&&e.meta.task_id!=null&&(e.task_id=e.meta.task_id),e.run_id==null&&e.meta.run_id!=null&&(e.run_id=e.meta.run_id),e.actor==null&&e.meta.actor!=null&&(e.actor=e.meta.actor),e.actor==null&&e.meta.owner!=null&&(e.actor=e.meta.owner),e.status==null&&e.meta.status!=null&&(e.status=e.meta.status))),e.kind||(e.kind=n);let m=`${n}|${e.kind}|${e.ts??""}|${e.task_id??""}|${e.run_id??""}|${e.cursor??""}`;if(!k.has(m)){if(k.add(m),(e.kind==="task.created"||e.kind==="task.completed"||e.kind==="task.failed")&&I(String(e.kind)),G(e,n),E(e,n),window.__UI_DEBUG)try{console.log("[task-events] mb.task.event",e)}catch{}T(e)}}let d=null,x=0;function f(){if(w(),d){try{d.close()}catch{}d=null}let n=p;d=new EventSource(n),d.onopen=()=>{x=0,v("open"),E({ts:Date.now(),kind:"sse.open",message:`url=${n}`},"sse.open"),console.log("[phase22] task-events SSE open",n)},d.onerror=()=>{v("error");try{d.close()}catch{}d=null,x+=1;let g=Math.min(15e3,500*Math.pow(2,Math.min(6,x)));E({ts:Date.now(),kind:"sse.error",message:`reconnect_in=${g}ms`},"sse.error"),console.log("[phase22] task-events SSE error; reconnect in",g),setTimeout(f,g)},d.onmessage=g=>a("message",g.data);let o=["hello","heartbeat","task.event","task.created","task.completed","task.failed","task.updated","task.status"];for(let g of o)d.addEventListener(g,e=>a(g,e.data))}function t(){f(),setInterval(()=>{if(!document.getElementById(u))try{f()}catch{}},2e3)}document.readyState==="loading"?document.addEventListener("DOMContentLoaded",t,{once:!0}):t(),window.__MB_TASK_EVENTS={url:p,reconnect:()=>f()}})();(()=>{let p="mb.task.event",u=new Map,b={queued:"task-status-queued",done:"task-status-done",failed:"task-status-failed"};function S(s){let r=String(s??"").toLowerCase();return r==="queued"||r==="pending"?"queued":r==="done"||r==="complete"||r==="completed"?"done":r==="failed"||r==="error"?"failed":r||"unknown"}function i(s){return s?.task_id??s?.taskId??s?.task?.id??null}function c(s){let r=s?.task&&typeof s.task=="object"?s.task:null,h=i(s),E=s?.status??s?.payload?.status??r?.status??(s?.kind==="task.created"?"queued":null);return{id:h!=null?String(h):null,status:E!=null?S(E):null,title:r?.title??s?.title??null,agent:r?.agent??s?.agent??null,error:s?.error??s?.payload?.error??r?.error??null,updated_at:r?.updated_at??s?.ts??Date.now()}}function w(s,r){if(!s)return;let h=S(r);s.setAttribute("data-task-status",h),s.classList?.remove(...Object.values(b)),b[h]&&s.classList?.add(b[h]);let E=s.querySelector?.("[data-task-field='status']")||s.querySelector?.(".task-status")||s.querySelector?.(".status")||null;E&&(E.textContent=h)}function v(s){if(!s?.id)return;let r=String(s.id),h=[document.getElementById(`task-${r}`),document.getElementById(`task_${r}`),document.querySelector?.(`[data-task-id="${CSS.escape(r)}"]`),document.querySelector?.(`[data-taskid="${CSS.escape(r)}"]`)].filter(Boolean);for(let E of h)w(E,s.status)}function k(){let s=0,r=0,h=0;for(let T of u.values()){let A=S(T.status);A==="queued"?s++:A==="done"?r++:A==="failed"&&h++}let E=[["queued",s],["done",r],["failed",h]];for(let[T,A]of E){let a=document.getElementById(`task-count-${T}`)||document.getElementById(`tasks-${T}-count`)||document.querySelector?.(`[data-task-count="${T}"]`)||null;a&&(a.textContent=String(A))}}function l(s){if(!s?.id)return;let r=String(s.id),h=u.get(r)||{},E={...h,...s,id:r,status:s.status??h.status};u.set(r,E),v(E),k()}function I(s){let r=c(s);!r.id&&s?.kind&&(s.kind==="task.completed"&&(r.status="done"),s.kind==="task.failed"&&(r.status="failed")),r.id&&l(r)}function y(){window.__PHASE22_TASK_UI_BOUND||(window.__PHASE22_TASK_UI_BOUND=!0,window.addEventListener(p,s=>{try{(window.__UI_DEBUG||window.__PHASE22_DEBUG)&&(window.__UI_DEBUG||window.__PHASE22_DEBUG)&&console.log("[phase22] mb.task.event",s.detail),I(s.detail)}catch{}}),window.__PHASE22_TASK_UI={tasks:u},console.log("[phase22] bindings attached"))}document.readyState==="loading"?document.addEventListener("DOMContentLoaded",y,{once:!0}):y()})();typeof window<"u"&&typeof window.__DISABLE_OPTIONAL_SSE>"u"&&(window.__DISABLE_OPTIONAL_SSE=!1);})();
;/* PHASE63_SHARED_TASK_EVENTS_METRICS */
(() => {
  if (typeof window === 'undefined') return;
  if (window.__PHASE63_SHARED_TASK_EVENTS_METRICS__) return;
  window.__PHASE63_SHARED_TASK_EVENTS_METRICS__ = true;

  const tasksNode = document.getElementById('metric-tasks');
  const successNode = document.getElementById('metric-success');
  const latencyNode = document.getElementById('metric-latency');

  const runningTaskIds = new Set();
  const taskStartTimes = new Map();
  const seenTerminalEvents = new Set();
  const recentDurationsMs = [];
  const maxSamples = 50;

  let completedCount = 0;
  let failedCount = 0;

  const runningTypes = new Set([
    'created',
    'queued',
    'leased',
    'started',
    'running',
    'in_progress',
    'delegated',
    'retrying'
  ]);

  const terminalSuccessTypes = new Set([
    'completed',
    'complete',
    'done',
    'success'
  ]);

  const terminalFailureTypes = new Set([
    'failed',
    'error',
    'cancelled',
    'canceled',
    'timed_out',
    'timeout',
    'terminated',
    'aborted'
  ]);

  const terminalTypes = new Set([
    ...terminalSuccessTypes,
    ...terminalFailureTypes
  ]);

  const normalize = (value) =>
    String(value || '')
      .trim()
      .toLowerCase()
      .replace(/\s+/g, '_');

  const safeJsonParse = (value) => {
    try {
      return JSON.parse(value);
    } catch {
      return null;
    }
  };

  const getTaskId = (payload) =>
    payload?.task_id ??
    payload?.taskId ??
    payload?.id ??
    payload?.data?.task_id ??
    payload?.data?.taskId ??
    null;

  const getEventType = (eventName, payload) =>
    normalize(
      payload?.type ??
      payload?.event ??
      payload?.status ??
      payload?.state ??
      eventName
    );

  const toMs = (value) => {
    if (typeof value === 'number' && Number.isFinite(value)) {
      return value > 1e12 ? value : value * 1000;
    }

    if (typeof value === 'string' && value.trim()) {
      const asNum = Number(value);
      if (Number.isFinite(asNum)) {
        return asNum > 1e12 ? asNum : asNum * 1000;
      }

      const parsed = Date.parse(value);
      if (Number.isFinite(parsed)) return parsed;
    }

    return Date.now();
  };

  const getEventTs = (payload) =>
    toMs(
      payload?.ts ??
      payload?.timestamp ??
      payload?.at ??
      payload?.time ??
      payload?.created_at ??
      payload?.updated_at ??
      Date.now()
    );

  const formatLatency = (ms) => {
    if (!Number.isFinite(ms) || ms <= 0) return '—';
    if (ms < 1000) return `${Math.round(ms)}ms`;
    const seconds = ms / 1000;
    if (seconds < 60) return `${seconds.toFixed(seconds >= 10 ? 0 : 1)}s`;
    const minutes = seconds / 60;
    return `${minutes.toFixed(minutes >= 10 ? 0 : 1)}m`;
  };

  const render = () => {
    if (tasksNode) {
      tasksNode.textContent = String(runningTaskIds.size);
    }

    if (successNode) {
      const total = completedCount + failedCount;
      successNode.textContent = total > 0
        ? `${Math.round((completedCount / total) * 100)}%`
        : '—';
    }

    if (latencyNode) {
      if (!recentDurationsMs.length) {
        latencyNode.textContent = '—';
      } else {
        const avg =
          recentDurationsMs.reduce((sum, value) => sum + value, 0) /
          recentDurationsMs.length;
        latencyNode.textContent = formatLatency(avg);
      }
    }
  };

  const ingestEvent = (eventName, payload) => {
    const taskId = getTaskId(payload);
    const eventType = getEventType(eventName, payload);
    const eventTs = getEventTs(payload);

    if (!taskId) {
      render();
      return;
    }

    if (runningTypes.has(eventType)) {
      runningTaskIds.add(taskId);
      if (!taskStartTimes.has(taskId)) {
        taskStartTimes.set(taskId, eventTs);
      }
    }

    if (terminalTypes.has(eventType)) {
      runningTaskIds.delete(taskId);

      const dedupeKey = `${taskId}|${eventType}|${eventTs}`;
      if (!seenTerminalEvents.has(dedupeKey)) {
        seenTerminalEvents.add(dedupeKey);

        if (terminalSuccessTypes.has(eventType)) completedCount += 1;
        if (terminalFailureTypes.has(eventType)) failedCount += 1;

        const startTs = taskStartTimes.get(taskId);
        if (Number.isFinite(startTs)) {
          const duration = Math.max(0, eventTs - startTs);
          recentDurationsMs.push(duration);
          if (recentDurationsMs.length > maxSamples) {
            recentDurationsMs.splice(0, recentDurationsMs.length - maxSamples);
          }
        }
      }

      taskStartTimes.delete(taskId);
    }

    render();
  };

  const ingestMessage = (raw, forcedEventName = null) => {
    const parsed = typeof raw === 'string' ? safeJsonParse(raw) : raw;
    if (!parsed) return;

    if (Array.isArray(parsed)) {
      parsed.forEach((item) => ingestEvent(forcedEventName, item));
      return;
    }

    const candidateLists = [
      parsed?.events,
      parsed?.payload?.events,
      parsed?.task_events,
      parsed?.items
    ];

    for (const list of candidateLists) {
      if (Array.isArray(list)) {
        list.forEach((item) => ingestEvent(forcedEventName, item));
        return;
      }
    }

    ingestEvent(
      forcedEventName ?? parsed?.event ?? parsed?.type ?? parsed?.status,
      parsed?.payload ?? parsed?.data ?? parsed
    );
  };

  const attachTypedListener = (es, eventName) => {
    es.addEventListener(eventName, (evt) => {
      const parsed = safeJsonParse(evt.data);
      if (parsed !== null) {
        ingestMessage({ event: eventName, payload: parsed }, eventName);
      } else {
        ingestMessage({ event: eventName, payload: { type: eventName } }, eventName);
      }
    });
  };

  const connect = () => {
    let es;
    try {
      es = new EventSource('/events/task-events');
    } catch {
      render();
      return;
    }

    es.onmessage = (evt) => ingestMessage(evt.data);

    [
      ...runningTypes,
      ...terminalSuccessTypes,
      ...terminalFailureTypes
    ].forEach((eventName) => attachTypedListener(es, eventName));

    es.onerror = () => render();
    window.addEventListener('beforeunload', () => es.close(), { once: true });
  };

  render();
  connect();
  window.setInterval(render, 10000);
})();
