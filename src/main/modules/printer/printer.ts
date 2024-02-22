import { BrowserWindow, PrintToPDFOptions } from "electron";
import fsPromises from "fs/promises";
import { pdfPrint } from "./pdfPrint";

export type PrinterParam = {
  path: string;
  toPDFOption: PrintToPDFOptions;
};

export const Printer = {
  savePdf,
  printPdf,
} as const;

async function savePdf(window: BrowserWindow, param: PrinterParam) {
  const pdfData = await window.webContents.printToPDF(param.toPDFOption);
  await fsPromises.writeFile(param.path, pdfData);
}

async function printPdf(window: BrowserWindow, param: PrinterParam) {
  await savePdf(window, param);
  try {
    await pdfPrint(param.path, { printDialog: true });
  } finally {
    await fsPromises.rm(param.path);
  }
}
