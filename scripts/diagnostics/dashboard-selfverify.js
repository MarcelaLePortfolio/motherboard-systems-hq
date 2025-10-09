export async function loadSelfVerification() {
  const res = await fetch("/adaptation/verify");
  const data = await res.json();
  document.getElementById("self-verify").innerHTML =
    `<div>Audit Interval: ${data.interval}</div>
     <div>Next Run: ${data.next}</div>
     <div>Status: ${data.status}</div>`;
}
