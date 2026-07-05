
import { contextBridge } from "electron";

contextBridge.exposeInMainWorld("motherboardDesktop", {

  version: "v2c-desktop-foundation"

});

