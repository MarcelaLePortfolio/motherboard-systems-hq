
const puppeteer = require("puppeteer");

(async () => {

  const browser = await puppeteer.launch({

    headless: "new",

    args: ["--no-sandbox", "--disable-setuid-sandbox"]

  });

  const page = await browser.newPage();

  await page.setViewport({ width: 1440, height: 1000 });

  await page.goto("http://localhost:8080/?v=recent-layout-dom-inspection", {

    waitUntil: "networkidle2"

  });

  await page.waitForTimeout(2500);

  const result = await page.evaluate(() => {

    function info(el, name) {

      if (!el) return { name, exists: false };

      const rect = el.getBoundingClientRect();

      const style = getComputedStyle(el);

      return {

        name,

        exists: true,

        tag: el.tagName,

        id: el.id || "",

        className: el.className || "",

        text: (el.textContent || "").trim().slice(0, 120),

        rect: {

          x: Math.round(rect.x),

          y: Math.round(rect.y),

          width: Math.round(rect.width),

          height: Math.round(rect.height)

        },

        style: {

          display: style.display,

          position: style.position,

          height: style.height,

          minHeight: style.minHeight,

          maxHeight: style.maxHeight,

          overflow: style.overflow,

          overflowY: style.overflowY,

          flex: style.flex,

          flexGrow: style.flexGrow,

          flexDirection: style.flexDirection,

          gridTemplateRows: style.gridTemplateRows,

          gridTemplateColumns: style.gridTemplateColumns,

          alignItems: style.alignItems

        }

      };

    }

    const recentTasks = document.getElementById("recentTasks");

    const recentLogs = document.getElementById("recentLogs");

    const recentCard = document.getElementById("recent-tasks-card");

    const chain = [];

    let el = recentTasks;

    let depth = 0;

    while (el && depth < 10) {

      chain.push(info(el, `recentTasks ancestor ${depth}`));

      el = el.parentElement;

      depth++;

    }

    return {

      url: location.href,

      recentCard: info(recentCard, "recentCard"),

      recentTasks: info(recentTasks, "recentTasks"),

      recentLogs: info(recentLogs, "recentLogs"),

      ancestorChain: chain

    };

  });

  console.log(JSON.stringify(result, null, 2));

  await browser.close();

})();

