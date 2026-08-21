#import "/tests/_helpers/helpers.typ": case-grid
#import "/src/lib.typ": squircle

#let roomy = (width: 160pt, height: 120pt, fill: black)

#case-grid(
  squircle.with(preserve-smoothing: false),
  (
    arguments(..roomy, radius: 10pt, smoothing: 100%),
    arguments(..roomy, radius: 15pt, smoothing: 0%),
    arguments(..roomy, radius: (top-left: 12pt, rest: 6pt), smoothing: 80%),
  ),
  cell: (200pt, 150pt),
  columns: 3,
)
