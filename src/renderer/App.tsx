import { useRef } from "react";
import { renderToString } from "react-dom/server";
import "./App.css";
import reactLogo from "./assets/react.svg";
import { TARGET_PRINTER } from "./modules/targetPrinter/targetPrinter";
import { TARGET_PRINTER_UTIL } from "./modules/targetPrinter/targetPrinter.util";
import viteLogo from "/vite.svg";

function App() {
  const { refTargetElement, printTarget } = useAppPrinter();

  return (
    <>
      <div ref={refTargetElement}>
        <a href="https://vitejs.dev" target="_blank">
          <img src={viteLogo} className="logo" alt="Vite logo" />
        </a>
        <a href="https://react.dev" target="_blank">
          <img src={reactLogo} className="logo react" alt="React logo" />
        </a>
      </div>
      <h1>Vite + React</h1>
      <div className="card">
        <button onClick={printTarget}>print Target</button>
        <p>
          Edit <code>src/App.tsx</code> and save to test HMR
        </p>
      </div>
      <p className="read-the-docs">
        Click on the Vite and React logos to learn more
      </p>
    </>
  );
}

function useAppPrinter() {
  const refTargetElement = useRef<HTMLDivElement>(null);

  function printTarget() {
    if (refTargetElement.current === null) return;
    TARGET_PRINTER.print(refTargetElement.current, {
      path: "./TARGET_PRINTER_TEST.pdf",
      toPDFOption: {
        displayHeaderFooter: true,
        headerTemplate: "<div></div>",
        footerTemplate: renderToString(
          <TARGET_PRINTER_UTIL.DefaultFooter leftText="hello world" />
        ),
      },
    });
  }

  return { refTargetElement, printTarget };
}

export default App;
