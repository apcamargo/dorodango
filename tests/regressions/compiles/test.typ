/// Documents that used to fail to compile, kept as smoke tests.
///
/// These are all shapes whose size cannot be known before layout runs, or
/// whose geometry degenerates, which is where the `layout()` / `context`
/// plumbing in `shape.typ` has historically broken. Every shared layout and
/// degeneracy case is applied to all three exported shapes; squircle-only
/// smoothing cases stay in their own page below.

#import "/src/lib.typ": clothoid, squircle, superellipse

// Shared layout and degeneracy cases, applied to every exported shape.
#let smoke(shape) = {
  // A ratio inset in an unbounded region: the box size is the solution of a
  // fixed point, and there is no region size to resolve the ratio against.
  page(width: auto, height: auto)[
    #shape(inset: 25%, fill: aqua)[Auto width]
  ]

  // A ratio height against an auto page height.
  page(width: 300pt, height: auto)[
    #shape(height: 50%, width: 80pt, fill: aqua)
  ]

  page(width: 300pt, height: 200pt)[
    // An auto grid column measures its contents before it has a width.
    #grid(
      columns: (auto, auto),
      shape(inset: 20%, fill: aqua)[a], [b],
    )

    // Nested shapes: the inner `layout()` runs inside the outer one.
    #shape(fill: aqua)[#shape(fill: red)[x]]

    // Degenerate geometry.
    #shape(width: 0pt, height: 0pt, fill: aqua)
    #shape(width: 0pt, height: 40pt, radius: 10pt, stroke: 2pt)
    #shape(width: 40pt, height: 30pt, outset: -30pt, fill: aqua)
    #shape(width: 40pt, height: 30pt, radius: 100%, stroke: 20pt + navy)

    // A body that is wider than the box it is given.
    #shape(width: 20pt, fill: aqua)[a very long body that cannot possibly fit]

    // Zero and negative insets.
    #shape(inset: 0pt, fill: aqua)[x]
    #shape(inset: -4pt, fill: aqua)[x]

    // A fraction inside a fixed box, with an outset that reaches outside it.
    #box(width: 100pt, height: 90pt)[
      #block(height: 30pt, spacing: 0pt)
      #shape(width: 80pt, height: 1fr, outset: 8pt, radius: 30%, fill: eastern)
    ]
  ]
}

#for shape in (squircle, superellipse, clothoid) {
  smoke(shape)
}

page(width: 300pt, height: 400pt)[
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

// An inner contour that keeps a positive fitted radius while both of its
// straight-edge budgets are zero: the corner must collapse onto its point
// rather than draw a chamfered record.
#superellipse(
  width: 2.5pt,
  height: 60pt,
  radius: 20pt,
  stroke: (left: 1pt + red, right: 4pt + blue),
)

// A corner compressed below its nominal radius while adjacent pens differ:
// each contour's seam must stay radial instead of clamping to an endpoint.
#clothoid(
  width: 100pt,
  height: 100pt,
  radius: 30pt,
  smoothing: 60%,
  stroke: (top: 16pt + red, bottom: 4pt + blue),
)
#clothoid(
  width: 100pt,
  height: 100pt,
  radius: 30pt,
  smoothing: 100%,
  stroke: (top: 16pt + red, bottom: 4pt + blue),
)
]

// Smoothing at both extremes on a corner with almost no budget, in both
// preserve modes -- the branch where the budget arithmetic can go negative.
// This is squircle-only behavior: the other families have no smoothing knob
// with these semantics.
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
