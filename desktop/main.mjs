
import { app, BrowserWindow, dialog, ipcMain } from "electron";

const DASHBOARD_URL = process.env.MOTHERBOARD_DASHBOARD_URL || "http://localhost:3001/dashboard";

function createMainWindow() {

  const mainWindow = new BrowserWindow({

    width: 1440,

    height: 1000,

    minWidth: 1100,

    minHeight: 760,

    title: "Motherboard Systems",

    webPreferences: {

      preload: new URL("./preload.mjs", import.meta.url).pathname,

      contextIsolation: true,

      nodeIntegration: false,

      sandbox: false

    }

  });

  mainWindow.loadURL(DASHBOARD_URL);

}

ipcMain.handle("motherboard:select-project-folder", async () => {

  const result = await dialog.showOpenDialog({

    title: "Select Project Folder",

    properties: ["openDirectory"]

  });

  if (result.canceled || !result.filePaths?.[0]) {

    return { ok: false, canceled: true };

  }

  return { ok: true, path: result.filePaths[0] };

});

app.whenReady().then(createMainWindow);

app.on("window-all-closed", () => {

  if (process.platform !== "darwin") app.quit();

});

app.on("activate", () => {

  if (BrowserWindow.getAllWindows().length === 0) createMainWindow();

});

