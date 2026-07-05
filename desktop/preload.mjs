
import { contextBridge } from "electron";

const desktopApi = Object.freeze({

  version: "v2c-desktop-foundation",

  platform: process.platform,

  isDesktop: true

});

contextBridge.exposeInMainWorld("motherboardDesktop", desktopApi);

