import { BrowserWindow } from "electron";
import { registPrinterHandle } from "./handlers/registPrinterHandle";

export function registMainHandles(window: BrowserWindow) {
  registPrinterHandle(window);
}
