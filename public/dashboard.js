
document.addEventListener("DOMContentLoaded", () => {

  const delegateBtn =

    document.getElementById("delegate-btn") ||

    document.getElementById("delegateButton") ||

    document.getElementById("delegation-submit");

  const input =

    document.getElementById("delegation-input") ||

    document.getElementById("task-input");

  const responsePanel =

    document.getElementById("delegation-response") ||

    document.getElementById("delegation-status-panel");

  async function delegateTask() {

    try {

      const prompt = input ? input.value.trim() : "";

      if (!prompt) {

        alert("Please enter a task prompt before delegating.");

        return;

      }

      const res = await fetch("/tasks/delegate", {

        method: "POST",

        headers: {

          "Content-Type": "application/json"

        },

        body: JSON.stringify({ prompt })

      });

      if (!res.ok) throw new Error(`HTTP ${res.status}`);

      const data = await res.json().catch(() => ({}));

      alert("✅ Task delegated successfully!");

      if (responsePanel) {

        responsePanel.innerText =

          data.message || "Task delegation completed successfully.";

      }

    } catch (err) {

      console.error(err);

      alert("❌ Failed to delegate task.");

      if (responsePanel) {

        responsePanel.innerText =

          "Error submitting delegation task.";

      }

    }

  }

  if (delegateBtn) {

    delegateBtn.addEventListener("click", delegateTask);

  }

  // Optional fallback binding for older DOM variants

  const legacyBtn = document.querySelector("#delegateButton");

  if (legacyBtn && legacyBtn !== delegateBtn) {

    legacyBtn.addEventListener("click", delegateTask);

  }

});

