// Wrapper bundle to ensure both the legacy dashboard code and the Matilda Chat Console load.

(function () {
  function injectScript(src) {
    try {
      var s = document.createElement("script");
      s.src = src;
      s.async = false;
      document.head.appendChild(s);
      console.log("[BundleWrapper] Injected:", src);
    } catch (e) {
      console.error("[BundleWrapper] Failed to inject:", src, e);
    }
  }

  // Load the original dashboard bundle
  injectScript("/bundle-core.js");

  // Load the Matilda Chat Console script
  injectScript("/js/matilda-chat-console.js");
})();
