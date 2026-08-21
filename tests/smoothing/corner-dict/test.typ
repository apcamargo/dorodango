/// `smoothing` takes a corner dictionary with the same precedence rules as
/// `radius`: own key, then the vertical side key, then the horizontal one,
/// with `rest` folded in at the side level. Each case here is the dictionary
/// spelling; the reference is the equivalent written out per corner.

#import "/tests/_helpers/helpers.typ": case-grid
#import "/src/lib.typ": squircle

#let base = (width: 80pt, height: 50pt, radius: 20pt, fill: black)

#case-grid(
  squircle,
  (
    arguments(..base, smoothing: (rest: 100%)),
    // `rest` outranks a horizontal key, so this is a uniform 100%.
    arguments(..base, smoothing: (left: 0%, rest: 100%)),
    // A vertical key outranks a horizontal one.
    arguments(..base, smoothing: (top: 100%, left: 0%)),
    arguments(..base, smoothing: (top: 100%, bottom: 0%)),
    arguments(..base, smoothing: (top-left: 100%)),
    // An empty dictionary falls back to the parameter's own default of 60%.
    arguments(..base, smoothing: (:)),
  ),
  columns: 3,
)
