
(function () {

  window.__DOM_OWNER__ = "bootstrap";

  const originalInnerHTML = Object.getOwnPropertyDescriptor(Element.prototype, "innerHTML");

  Object.defineProperty(Element.prototype, "innerHTML", {

    set(value) {

      if (window.__DOM_OWNER_LOCKED__ && !this.__ALLOWED__) {

        console.warn("[DOM-OWNER] blocked innerHTML write");

        return;

      }

      originalInnerHTML.set.call(this, value);

    },

    get: originalInnerHTML.get

  });

  window.__DOM_OWNER_LOCKED__ = true;

  console.log("[DOM-OWNER] active");

})();

