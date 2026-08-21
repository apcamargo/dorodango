/// `smoothing` is clamped to 0%..100% rather than refused, so a caller can
/// sweep past either end without special-casing. Out-of-range values must draw
/// exactly what the nearest in-range value draws.

#import "/tests/_helpers/helpers.typ": case-grid
#import "/src/lib.typ": squircle

#let base = (width: 80pt, height: 50pt, radius: 20pt, fill: black)

#case-grid(
  squircle,
  (
    arguments(..base, smoothing: 200%),
    arguments(..base, smoothing: -50%),
    // The clamp applies per corner, not to the parameter as a whole.
    arguments(..base, smoothing: (
      top-left: 300%,
      bottom-right: -80%,
      rest: 50%,
    )),
    // `smoothing` resolves against 1pt, so 1.5pt is past the top end too.
    arguments(..base, smoothing: 1.5pt),
  ),
  columns: 3,
)
