// Argument matrices for the rendered parity tests.
//
// Each list is imported by both the `test.typ` and the `ref.typ` of its test,
// so a case is written once and rendered twice: once through
// `squircle(smoothing: 0%)` and once through `rect`. There is deliberately no
// per-side hook here -- if the two documents could disagree about a case, the
// comparison would not mean anything.

#let size = (width: 80pt, height: 50pt)

// -- radius, scalar forms ---------------------------------------------------

#let radius-scalar = (
  arguments(..size, radius: 10pt, fill: black),
  arguments(..size, radius: 25pt, fill: black),
  arguments(..size, radius: 10%, fill: black),
  arguments(..size, radius: 25%, fill: black),
  arguments(..size, radius: 30%, fill: black),
  // A ratio radius resolves against half the short side, so 50% and above are
  // the pill case.
  arguments(..size, radius: 50%, fill: black),
  arguments(..size, radius: 100%, fill: black),
  arguments(..size, radius: 30% + 5pt, fill: black),
  // Well past what fits: both must clamp to the same place.
  arguments(..size, radius: 60pt, fill: black),
  arguments(..size, radius: -5pt, fill: black),
  // The short side is the vertical one here, which swaps which side clamps.
  arguments(width: 50pt, height: 80pt, radius: 50%, fill: black),
  arguments(width: 50pt, height: 80pt, radius: 30pt, fill: black),
)

// -- radius, dictionary forms ----------------------------------------------

// Corner-precedence cases rendered end to end against `rect`.
#let radius-dict = (
  arguments(..size, radius: (rest: 10pt), fill: black),
  arguments(..size, radius: (top-left: 10pt), fill: black),
  arguments(..size, radius: (top: 10pt), fill: black),
  arguments(..size, radius: (left: 10pt), fill: black),
  arguments(..size, radius: (left: 5pt, rest: 20pt), fill: black),
  arguments(..size, radius: (right: 10pt, rest: 3pt), fill: black),
  arguments(..size, radius: (bottom: 10pt, rest: 3pt), fill: black),
  arguments(..size, radius: (top: 20pt, left: 5pt), fill: black),
  arguments(..size, radius: (top: 10pt, right: 4pt, rest: 2pt), fill: black),
  arguments(..size, radius: (top: 25pt, bottom: 5pt), fill: black),
  arguments(
    ..size,
    radius: (top-left: 30pt, bottom-right: 15pt, rest: 0pt),
    fill: black,
  ),
  // Neighbouring corners fighting over the same side.
  arguments(
    ..size,
    radius: (
      top-left: 40pt,
      top-right: 5pt,
      bottom-right: 40pt,
      bottom-left: 5pt,
    ),
    fill: black,
  ),
  arguments(
    ..size,
    radius: (top-left: 50pt, top-right: 50pt, rest: 5pt),
    fill: black,
  ),
  arguments(
    width: 35pt,
    height: 100pt,
    radius: (top-left: 30pt, top-right: 10pt, rest: 0pt),
    fill: black,
  ),
)

// -- outset -----------------------------------------------------------------

#let outset-cases = (
  arguments(..size, outset: 10pt, radius: 12pt, fill: black),
  arguments(..size, outset: 10%, radius: 12pt, fill: black),
  arguments(..size, outset: 10% + 2pt, radius: 12pt, fill: black),
  arguments(
    ..size,
    outset: (left: 2pt, right: 14pt, top: 14pt, bottom: 2pt),
    radius: 12pt,
    fill: black,
  ),
  arguments(..size, outset: (x: 10pt), radius: 12pt, fill: black),
  arguments(..size, outset: -5pt, radius: 12pt, fill: black),
  // Outsets change the box the radius is clamped against.
  arguments(..size, outset: 10pt, radius: 50%, fill: black),
  arguments(..size, outset: 10pt, radius: 60pt, fill: black),
)

// -- radius zero ------------------------------------------------------------

// Kept apart from everything else, and kept on whole points: with no rounding
// anywhere `rect` keeps a plain rectangle primitive, which Typst rasterises
// through a pixel-snapped fast path, while `squircle` always emits a curve.
// On the pixel grid the two still agree exactly; off it they can differ by a
// sub-pixel sliver along each edge. See `tests/parity/radius-zero/test.typ`.
#let radius-zero = (
  arguments(..size, radius: 0pt, fill: black),
  arguments(..size, radius: 0%, fill: black),
  arguments(..size, radius: (:), fill: black),
  arguments(..size, radius: 0pt, outset: 10pt, fill: black),
  arguments(..size, radius: 0pt, outset: (x: 10pt), fill: black),
  arguments(..size, radius: 0pt, stroke: 4pt + black),
)

// -- fractional geometry ----------------------------------------------------

// Everything else in this file sits on whole points, which at 144 ppi lands on
// exact pixel boundaries -- so an exact match there could in principle be the
// pixel grid hiding a sub-pixel disagreement. These sizes, radii and stroke
// widths deliberately fall between pixels. Rounded shapes still match exactly,
// which is the stronger statement.
#let fractional = (
  arguments(width: 80.37pt, height: 50.13pt, radius: 9.31pt, fill: black),
  arguments(width: 80.37pt, height: 50.13pt, radius: 23.7%, fill: black),
  arguments(
    width: 80.37pt,
    height: 50.13pt,
    radius: 17.3% + 2.9pt,
    fill: black,
  ),
  arguments(
    width: 80.37pt,
    height: 50.13pt,
    radius: 9.31pt,
    stroke: 3.7pt + navy,
  ),
  arguments(width: 63.9pt, height: 41.07pt, radius: 100%, fill: black),
  arguments(
    width: 80.37pt,
    height: 50.13pt,
    radius: (top-left: 19.4pt, rest: 3.3pt),
    fill: black,
  ),
  arguments(
    width: 80.37pt,
    height: 50.13pt,
    radius: 4.7pt,
    stroke: 13.3pt + navy,
  ),
  arguments(
    width: 80.37pt,
    height: 50.13pt,
    radius: 11.9pt,
    stroke: (top: 5.3pt + red, left: 2.1pt + blue),
  ),
)

// -- fractional heights -----------------------------------------------------

// A fraction is resolved by the layout engine, and `layout()` reports the
// region it was measured against rather than the resolved size, so `squircle`
// has to recover the drawn height through a nested `100%` block. Each of these
// is a container that resolves `1fr` differently.
#let fraction-layouts = (
  shape => box(width: 120pt, height: 120pt)[
    #block(height: 40pt, spacing: 0pt)
    #shape(
      width: 100%,
      height: 1fr,
      radius: 12pt,
      fill: aqua,
      stroke: 2pt + navy,
    )
  ],
  shape => box(width: 120pt, height: 120pt)[
    #block(height: 30pt, spacing: 0pt)
    #shape(width: 100%, height: 1fr, radius: 10pt, fill: teal)[body]
  ],
  shape => grid(
    rows: (70pt,),
    columns: 100pt,
    shape(
      width: 100%,
      height: 1fr,
      radius: 20pt,
      fill: orange,
      stroke: 3pt + black,
    ),
  ),
  shape => grid(
    columns: (40pt, 100pt),
    rows: (80pt,),
    [a], shape(width: 100%, height: 1fr, radius: 14pt, fill: lime),
  ),
  // A ratio radius on a fractional height: the radius can only be resolved
  // once the fraction has been.
  shape => box(width: 120pt, height: 100pt)[
    #block(height: 20pt, spacing: 0pt)
    #shape(width: 100%, height: 1fr, radius: 50%, fill: yellow, stroke: 2pt)
  ],
  shape => box(width: 120pt, height: 120pt)[
    #block(height: 30pt, spacing: 0pt)
    #shape(width: 100%, height: 3fr, radius: 8pt, fill: purple)
  ],
  shape => box(width: 120pt, height: 120pt)[
    #block(height: 40pt, spacing: 0pt)
    #shape(width: 100%, height: 1fr, radius: 5pt, stroke: 14pt + navy)
  ],
  shape => box(width: 100pt, height: 110pt)[
    #block(height: 40pt, spacing: 0pt)
    #shape(width: 80pt, height: 1fr, outset: 8pt, radius: 30%, fill: eastern)
  ],
)

// -- strokes, one pen all round ---------------------------------------------

#let stroke-uniform = (
  // `auto` is a 1pt black stroke, but only while nothing fills the shape.
  arguments(..size, radius: 12pt),
  arguments(..size, radius: 12pt, fill: aqua, stroke: auto),
  arguments(..size, radius: 12pt, fill: aqua, stroke: none),
  arguments(..size, radius: 12pt, stroke: 3pt),
  arguments(..size, radius: 12pt, stroke: 4pt + blue),
  arguments(..size, radius: 12pt, stroke: 4pt + gradient.linear(red, blue)),
  arguments(
    ..size,
    radius: 12pt,
    stroke: (paint: purple, thickness: 3pt, dash: "dashed"),
  ),
  arguments(
    ..size,
    radius: 12pt,
    stroke: (paint: red, thickness: 6pt, join: "bevel", cap: "square"),
  ),
  arguments(..size, radius: 0pt, stroke: (
    paint: red,
    thickness: 6pt,
    join: "round",
  )),
  // A ratio radius resolves against the short side plus the thinner of the two
  // strokes meeting at the corner.
  arguments(..size, radius: 25%, stroke: 6pt + navy),
  arguments(..size, radius: 50%, stroke: 6pt + navy),
  arguments(..size, radius: 100%, stroke: 8pt + navy),
  arguments(..size, radius: 20% + 4pt, stroke: 5pt + navy),
  arguments(..size, radius: -5pt, stroke: 4pt + navy),
)

// Solid sides of a different thickness but the same paint are one continuous
// ring. A bare paint receives `rect`'s 1pt default thickness.
#let stroke-joins = (
  arguments(width: 80pt, height: 50pt, radius: 12pt, stroke: red),
  arguments(
    width: 80pt,
    height: 50pt,
    radius: 12pt,
    stroke: (
      top: 2pt + red,
      right: 5pt + red,
      bottom: 2pt + red,
      left: 5pt + red,
    ),
  ),
  arguments(
    width: 80pt,
    height: 50pt,
    radius: 20pt,
    stroke: (
      top: 1pt + navy,
      right: 4pt + navy,
      bottom: 1pt + navy,
      left: 4pt + navy,
    ),
  ),
)

// -- strokes, per side ------------------------------------------------------

#let stroke-per-side = (
  arguments(
    ..size,
    radius: 18pt,
    stroke: (
      top: 4pt + red,
      right: 4pt + blue,
      bottom: 4pt + green,
      left: 4pt + orange,
    ),
  ),
  arguments(..size, radius: 18pt, stroke: (top: 4pt + red)),
  arguments(..size, radius: 18pt, fill: aqua, stroke: (top: 4pt + red)),
  arguments(..size, radius: 18pt, stroke: (x: 4pt + red, y: 4pt + blue)),
  arguments(..size, radius: 18pt, stroke: (top: none, rest: 4pt + red)),
  arguments(..size, radius: 18pt, stroke: (:)),
  arguments(..size, radius: 0pt, stroke: (top: 4pt + red, left: 4pt + blue)),
  arguments(
    ..size,
    radius: 100%,
    stroke: (
      top: 4pt + red,
      right: 4pt + blue,
      bottom: 4pt + green,
      left: 4pt + orange,
    ),
  ),
  arguments(
    ..size,
    radius: (top-left: 25pt, rest: 4pt),
    stroke: (
      top: 4pt + red,
      right: 4pt + blue,
      bottom: 4pt + green,
      left: 4pt + orange,
    ),
  ),
  // Adjacent sides of different thickness: the thinner one decides how much
  // radius the drawn outline keeps, and the corner is filled rather than
  // stroked.
  arguments(
    ..size,
    radius: 20pt,
    stroke: (
      top: 8pt + red,
      left: 2pt + blue,
      bottom: 8pt + green,
      right: 2pt + orange,
    ),
  ),
  arguments(..size, radius: 14pt, stroke: (x: 10pt + red, y: 3pt + blue)),
  arguments(..size, radius: 14pt, fill: aqua, stroke: (
    x: 10pt + red,
    y: 3pt + blue,
  )),
  // An unstroked side lends its neighbour half its thickness, but only while
  // the radius is wide enough for the cap to keep its shape.
  arguments(..size, radius: 3pt, stroke: (top: 4pt + red)),
  arguments(..size, radius: 3pt, stroke: (top: 6pt + red, left: 6pt + blue)),
)

// -- strokes, thick enough to become a filled ring --------------------------

// Once the pen is wider than twice the radius, `rect` stops stroking the
// outline and fills a ring instead. These straddle that switch.
#let stroke-thick = (
  arguments(..size, radius: 6pt, stroke: 11.5pt + navy),
  arguments(..size, radius: 6pt, stroke: 12pt + navy),
  arguments(..size, radius: 6pt, stroke: 16pt + navy),
  arguments(..size, radius: 6pt, stroke: 16pt + navy, fill: yellow),
  arguments(..size, radius: 10%, stroke: 14pt + navy),
  arguments(
    ..size,
    radius: 6pt,
    stroke: (paint: navy, thickness: 16pt, dash: "dashed"),
  ),
  arguments(..size, radius: 5pt, stroke: (top: 16pt + red, left: 16pt + blue)),
  arguments(..size, radius: 6pt, stroke: 16pt + gradient.linear(red, blue)),
)

// -- stroke caps ------------------------------------------------------------

// A cap is only drawn where a stroke really ends, which is where the
// neighbouring side is unstroked.
#let stroke-caps = (
  arguments(..size, radius: 14pt, stroke: (
    top: (paint: red, thickness: 5pt, cap: "butt"),
  )),
  arguments(
    ..size,
    radius: 14pt,
    stroke: (top: (paint: red, thickness: 5pt, cap: "square")),
  ),
  arguments(
    ..size,
    radius: 14pt,
    stroke: (top: (paint: red, thickness: 5pt, cap: "round")),
  ),
  // Small radii keep the plain butt end, since anything else would be
  // misshapen there.
  arguments(
    ..size,
    radius: 2pt,
    stroke: (top: (paint: red, thickness: 5pt, cap: "square")),
  ),
  arguments(
    ..size,
    radius: 2pt,
    stroke: (top: (paint: red, thickness: 5pt, cap: "round")),
  ),
  arguments(
    ..size,
    radius: 14pt,
    stroke: (
      top: (paint: red, thickness: 5pt, cap: "round"),
      bottom: (paint: blue, thickness: 5pt, cap: "square"),
    ),
  ),
)

// -- fills ------------------------------------------------------------------

#let fills = (
  arguments(..size, radius: 12pt, fill: gradient.linear(yellow, red)),
  arguments(..size, radius: 12pt, fill: gradient.radial(yellow, red)),
  arguments(
    ..size,
    radius: 12pt,
    fill: tiling(size: (10pt, 10pt), place(square(size: 5pt, fill: navy))),
  ),
  arguments(..size, radius: 12pt, fill: maroon.transparentize(50%)),
  arguments(..size, radius: 12pt, fill: aqua, stroke: 3pt + navy),
)

// -- insets, with a body ----------------------------------------------------

#let insets = (
  arguments(radius: 12pt, fill: aqua)[Hello],
  arguments(radius: 12pt, fill: aqua, inset: 0pt)[Hello],
  arguments(radius: 12pt, fill: aqua, inset: 12pt)[Hello],
  arguments(radius: 12pt, fill: aqua, inset: 25%)[Hello],
  arguments(radius: 12pt, fill: aqua, inset: (x: 18pt, y: 4pt))[Hello],
  arguments(radius: 12pt, fill: aqua, inset: (top: 20pt))[Hello],
  arguments(width: 120pt, radius: 12pt, fill: aqua)[Wrapping body text here],
  arguments(
    width: 90pt,
    radius: 12pt,
    fill: aqua,
    inset: 15%,
  )[Wrapping body text],
)
