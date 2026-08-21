/// `preserve-smoothing` only does anything when a corner asks for more
/// smoothing than its budget allows. Where there is room to spare it must be
/// completely inert, so that turning it on is never a silent visual change.
///
/// Every case here has a radius small enough relative to the sides that the
/// requested smoothing fits. The reference is the same document with the flag
/// off. The constrained cases are compared against the independent Figma
/// fixtures in `tests/smoothing/figma-reference`.

#import "/tests/_helpers/helpers.typ": case-grid
#import "/src/lib.typ": squircle

#let roomy = (width: 160pt, height: 120pt, fill: black)

#case-grid(
  squircle.with(preserve-smoothing: true),
  (
    arguments(..roomy, radius: 10pt, smoothing: 100%),
    arguments(..roomy, radius: 15pt, smoothing: 0%),
    arguments(..roomy, radius: (top-left: 12pt, rest: 6pt), smoothing: 80%),
  ),
  cell: (200pt, 150pt),
  columns: 3,
)
