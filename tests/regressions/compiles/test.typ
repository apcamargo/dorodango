/// Documents that used to fail to compile, kept as smoke tests.
///
/// These are all shapes whose size cannot be known before layout runs, or
/// whose geometry degenerates, which is where the `layout()` / `context`
/// plumbing in `src/squircle.typ` has historically broken.

#import "/src/lib.typ": squircle

// A ratio inset in an unbounded region: the box size is the solution of a
// fixed point, and there is no region size to resolve the ratio against.
#page(width: auto, height: auto)[
  #squircle(inset: 25%, fill: aqua)[Auto width]
]

// A ratio height against an auto page height.
#page(width: 300pt, height: auto)[
  #squircle(height: 50%, width: 80pt, fill: aqua)
]

#page(width: 300pt, height: 200pt)[
  // An auto grid column measures its contents before it has a width.
  #grid(
    columns: (auto, auto),
    squircle(inset: 20%, fill: aqua)[a], [b],
  )

  // Nested shapes: the inner `layout()` runs inside the outer one.
  #squircle(fill: aqua)[#squircle(fill: red)[x]]

  // Degenerate geometry.
  #squircle(width: 0pt, height: 0pt, fill: aqua)
  #squircle(width: 0pt, height: 40pt, radius: 10pt, stroke: 2pt)
  #squircle(width: 40pt, height: 30pt, outset: -30pt, fill: aqua)
  #squircle(width: 40pt, height: 30pt, radius: 100%, stroke: 20pt + navy)

  // A body that is wider than the box it is given.
  #squircle(width: 20pt, fill: aqua)[a very long body that cannot possibly fit]

  // Zero and negative insets.
  #squircle(inset: 0pt, fill: aqua)[x]
  #squircle(inset: -4pt, fill: aqua)[x]

  // Every side stroked differently, at a radius that forces the filled-ring
  // path on some corners and not others.
  #squircle(
    width: 60pt,
    height: 40pt,
    radius: (top-left: 20pt, rest: 1pt),
    stroke: (
      top: 9pt + red,
      right: none,
      bottom: 2pt + blue,
      left: 9pt + green,
    ),
  )

  // A fraction inside a fixed box, with an outset that reaches outside it.
  #box(width: 100pt, height: 90pt)[
    #block(height: 30pt, spacing: 0pt)
    #squircle(width: 80pt, height: 1fr, outset: 8pt, radius: 30%, fill: eastern)
  ]
]

// Smoothing at both extremes on a corner with almost no budget, in both
// preserve modes -- the branch where the budget arithmetic can go negative.
#page(width: 300pt, height: 200pt)[
  #for keep in (false, true) {
    for s in (0%, 50%, 100%) {
      squircle(
        width: 30pt,
        height: 20pt,
        radius: 15pt,
        smoothing: s,
        preserve-smoothing: keep,
        fill: aqua,
      )
    }
  }
]
