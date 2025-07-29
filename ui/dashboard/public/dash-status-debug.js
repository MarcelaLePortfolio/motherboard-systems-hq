// 🔍 Debug: Log each .agent element’s textContent
document.querySelectorAll(".agent").forEach((agentDiv, index) => {
  console.log(`Agent[${index}]:`, agentDiv.textContent.trim());
});
