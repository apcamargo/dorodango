// Exported-API cases whose geometry is defined by figma-squircle fixtures.
// The matching SVGs are generated from `fixtures.json` by
// `scripts/generate-figma-fixtures.mjs`.

#let cases = (
  (
    id: "uniform-quarter",
    width: 120pt,
    height: 80pt,
    args: arguments(
      width: 120pt,
      height: 80pt,
      radius: 20pt,
      smoothing: 25%,
      fill: black,
    ),
  ),
  (
    id: "uniform-high",
    width: 120pt,
    height: 80pt,
    args: arguments(
      width: 120pt,
      height: 80pt,
      radius: 20pt,
      smoothing: 80%,
      fill: black,
    ),
  ),
  (
    id: "uniform-full",
    width: 120pt,
    height: 80pt,
    args: arguments(
      width: 120pt,
      height: 80pt,
      radius: 20pt,
      smoothing: 100%,
      fill: black,
    ),
  ),
  (
    id: "constrained-clamped",
    width: 80pt,
    height: 50pt,
    args: arguments(
      width: 80pt,
      height: 50pt,
      radius: 20pt,
      smoothing: 100%,
      fill: black,
    ),
  ),
  (
    id: "constrained-preserved",
    width: 80pt,
    height: 50pt,
    args: arguments(
      width: 80pt,
      height: 50pt,
      radius: 20pt,
      smoothing: 100%,
      preserve-smoothing: true,
      fill: black,
    ),
  ),
  (
    id: "asymmetric",
    width: 120pt,
    height: 80pt,
    args: arguments(
      width: 120pt,
      height: 80pt,
      radius: (
        top-left: 35pt,
        top-right: 12pt,
        bottom-right: 26pt,
        bottom-left: 6pt,
      ),
      smoothing: 80%,
      fill: black,
    ),
  ),
  (
    id: "budget-order",
    width: 80pt,
    height: 50pt,
    args: arguments(
      width: 80pt,
      height: 50pt,
      radius: (
        top-left: 25pt,
        top-right: 25pt,
        bottom-right: 5pt,
        bottom-left: 5pt,
      ),
      smoothing: 100%,
      fill: black,
    ),
  ),
)
