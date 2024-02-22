export const TARGET_PRINTER_UTIL = {
  DefaultFooter,
};

function DefaultFooter(props: { leftText?: string }) {
  return (
    <div
      style={{
        display: "flex",
        justifyContent: "space-between",
        alignItems: "baseline",
        width: "100%",
        padding: "0.25in 0.5in 0.25in 0.5in",
        fontSize: "0.2in",
      }}
    >
      <div>{props.leftText}</div>
      {/* className is API protocol */}
      <div style={{ display: "flex", gap: "0.1in" }}>
        <span className="pageNumber" />
        /
        <span className="totalPages" />
      </div>
    </div>
  );
}
