import { print, PrintOptions } from "pdf-to-printer";

export function pdfPrint(pdfPath: string, options: PrintOptions) {
  return print(pdfPath, options);
}
