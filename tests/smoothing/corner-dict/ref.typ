#import "/tests/_helpers/helpers.typ": case-grid
#import "/src/lib.typ": squircle

#let base = (width: 80pt, height: 50pt, radius: 20pt, fill: black)
#let per-corner(tl, tr, br, bl) = arguments(
  ..base,
  smoothing: (top-left: tl, top-right: tr, bottom-right: br, bottom-left: bl),
)

#case-grid(
  squircle,
  (
    per-corner(100%, 100%, 100%, 100%),
    per-corner(100%, 100%, 100%, 100%),
    // `left: 0%` only survives at bottom-left, where no vertical key competes
    // with it. Bottom-right has neither key and falls to the 60% default.
    per-corner(100%, 100%, 60%, 0%),
    per-corner(100%, 100%, 0%, 0%),
    per-corner(100%, 60%, 60%, 60%),
    per-corner(60%, 60%, 60%, 60%),
  ),
  columns: 3,
)
