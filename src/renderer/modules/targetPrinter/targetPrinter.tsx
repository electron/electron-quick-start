import { PrinterParam } from "../../../main/modules/printer/printer";
import { ipcInvoke } from "../electronUtil/electronUtil";
import { sleep } from "../sleep/sleep";

export const TARGET_PRINTER = {
  save,
  print,
} as const;

async function save(targetElement: HTMLElement, param: PrinterParam) {
  return await tpAlgoV1(targetElement, ipcInvoke("printer::savePdf", param));
}

async function print(targetElement: HTMLElement, param: PrinterParam) {
  return await tpAlgoV1(targetElement, ipcInvoke("printer::printPdf", param));
}

async function tpAlgoV1(
  targetElement: HTMLElement,
  cbPromise: Promise<unknown>
) {
  const targetWrapper = document.createElement("div");
  document.body.appendChild(targetWrapper);
  targetWrapper.id = "target-printer";
  const cloned = targetElement.cloneNode(true) as HTMLElement;
  targetWrapper.appendChild(cloned);

  const headStyle = document.createElement("style");
  document.head.appendChild(headStyle);
  headStyle.textContent = `
  body > #target-printer {
    display: none;
  }
  @media print {
    body > * {
      display: none;
    }
    body > #target-printer {
      display: block !important;
      -webkit-print-color-adjust: exact;
    } 
  }
  `;

  await sleep(100); // for font-display opt
  try {
    return await cbPromise;
  } finally {
    document.head.removeChild(headStyle);
    document.body.removeChild(targetWrapper);
  }
}
