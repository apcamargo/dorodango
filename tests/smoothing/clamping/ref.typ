#import "/tests/_helpers/helpers.typ": case-grid
#import "/src/lib.typ": squircle

#let base = (width: 80pt, height: 50pt, radius: 20pt, fill: black)

#case-grid(
  squircle,
  (
    arguments(..base, smoothing: 100%),
    arguments(..base, smoothing: 0%),
    arguments(..base, smoothing: (top-left: 100%, bottom-right: 0%, rest: 50%)),
    arguments(..base, smoothing: 100%),
  ),
  columns: 3,
)
