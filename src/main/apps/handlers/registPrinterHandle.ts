import { BrowserWindow, ipcMain } from "electron";
import { Printer, PrinterParam } from "../../modules/printer/printer";

export function registPrinterHandle(window: BrowserWindow) {
  ipcMain.handle("printer::savePdf", async (_, param: PrinterParam) => {
    try {
      await Printer.savePdf(window, param);
    } catch (e) {
      console.error(e);
    }
  });

  ipcMain.handle("printer::printPdf", async (_, param: PrinterParam) => {
    try {
      await Printer.printPdf(window, param);
    } catch (e) {
      console.error(e);
    }
  });
}
