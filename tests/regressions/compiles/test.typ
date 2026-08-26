/// Compile cases for deferred layout and degenerate geometry.

#import "/src/lib.typ": clothoid, squircle, superellipse

#let smoke(shape) = {
  // Ratio inset in an unbounded region.
  page(width: auto, height: auto)[
    #shape(inset: 25%, fill: aqua)[Auto width]
  ]

  // Ratio height on an auto-height page.
  page(width: 300pt, height: auto)[
    #shape(height: 50%, width: 80pt, fill: aqua)
  ]

  page(width: 300pt, height: 200pt)[
    #grid(
      columns: (auto, auto),
      shape(inset: 20%, fill: aqua)[a], [b],
    )

    #shape(fill: aqua)[#shape(fill: red)[x]]

    #shape(width: 0pt, height: 0pt, fill: aqua)
    #shape(width: 0pt, height: 40pt, radius: 10pt, stroke: 2pt)
    #shape(width: 40pt, height: 30pt, outset: -30pt, fill: aqua)
    #shape(width: 40pt, height: 30pt, radius: 100%, stroke: 20pt + navy)

    #shape(width: 20pt, fill: aqua)[a very long body that cannot possibly fit]

    #shape(inset: 0pt, fill: aqua)[x]
    #shape(inset: -4pt, fill: aqua)[x]

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
// Mixed side strokes with a filled-ring corner.
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

// An inner contour with no straight-edge budget must collapse to the corner.
#superellipse(
  width: 2.5pt,
  height: 60pt,
  radius: 20pt,
  stroke: (left: 1pt + red, right: 4pt + blue),
)

// A compressed corner with different adjacent pens must keep radial seams.
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

// Exercise both preserve modes with almost no corner budget.
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
