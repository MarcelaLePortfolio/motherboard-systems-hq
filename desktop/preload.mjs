
import { contextBridge, ipcRenderer } from "electron";

const desktopApi = Object.freeze({

  version: "v2c-desktop-foundation",

  platform: process.platform,

  isDesktop: true,

  selectProjectFolder: () => ipcRenderer.invoke("motherboard:select-project-folder")

});

contextBridge.exposeInMainWorld("motherboardDesktop", desktopApi);

