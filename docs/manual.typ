#import "@preview/tidy:0.4.3"
#import "../src/lib.typ": clothoid, squircle, superellipse

#let light-gray = oklch(93%, 0.005, 265deg)
#let medium-gray = oklch(60%, 0.005, 265deg)

#set document(title: "dorodango manual")

#set page(
  paper: "a4",
  numbering: "1",
  number-align: center + bottom,
)

#set text(font: "Source Sans 3", size: 10.8pt)

#set raw(lang: "manual-inline")

#show raw.where(block: false, lang: "manual-inline"): set text(size: 9.2pt)

#show raw.where(block: false, lang: "manual-inline"): box.with(
  outset: (y: 2.6pt, x: 0.3pt),
  inset: (x: 2.5pt),
  fill: light-gray,
  radius: 2.2pt,
)

#set par(justify: true, leading: 0.72em, justification-limits: (
  tracking: (min: -0.012em, max: 0.012em),
  spacing: (min: 70%, max: 130%),
))

#set heading(numbering: none)

#show heading.where(level: 1): it => {
  set text(size: 16pt)
  set block(below: 0.8em)
  block(it)
}

#show heading.where(level: 2): it => {
  set block(below: 0.8em)
  block(it)
}

#show link: set text(fill: rgb("4B69BE"))

#show footnote: set text(fill: rgb("4B69BE"))

#let api-squircle = tidy.parse-module(
  read("../src/squircle.typ"),
  name: "squircle",
  label-prefix: "api-squircle-",
  require-all-parameters: true,
  scope: (squircle: squircle),
)

#let api-superellipse = tidy.parse-module(
  read("../src/superellipse.typ"),
  name: "superellipse",
  label-prefix: "api-superellipse-",
  require-all-parameters: true,
  scope: (superellipse: superellipse),
)

#let api-clothoid = tidy.parse-module(
  read("../src/clothoid.typ"),
  name: "clothoid",
  label-prefix: "api-clothoid-",
  require-all-parameters: true,
  scope: (clothoid: clothoid),
)

#show: tidy.render-examples.with(
  scope: (
    squircle: squircle,
    superellipse: superellipse,
    clothoid: clothoid,
  ),
  layout: (code, preview) => grid(
    columns: (1fr, 0.5fr),
    gutter: 10pt,
    block(breakable: false, inset: 10pt, fill: rgb("ddd3"), width: 100%)[#code],
    block(breakable: false, inset: 10pt, width: 100%)[
      #set text(font: "Source Sans 3", size: 10.8pt)
      #preview
    ],
  ),
)

#grid(
  columns: (1fr,),
  rows: 2,
  align: center,
  gutter: 0.525cm,
  text(size: 27pt, weight: "bold")[dorodango],
  text(
    fill: medium-gray,
  )[Draw squircles in Typst with tunable corner smoothing],
)

#v(1cm)

#outline(title: [Contents], depth: 2)

#pagebreak()

= Introduction

`dorodango` provides three functions for drawing rectangles with smoothly rounded corners:

- `squircle`: the [Figma curve family](https://www.figma.com/blog/desperately-seeking-squircles/), transitioning from straight edges into circular arcs via two cubic Bézier shoulders.
- `superellipse`: cubic approximations of Lamé curve ($|x/a|^n + |y/b|^n = 1$) corners, parameterized by an exponent $n$. For $n > 2$, the ideal curve meets straight edges with zero curvature.
- `clothoid`: cubic approximations of Euler-spiral blend corners, whose ideal curvature ramps linearly along arc length from zero to $1/r$ into a central arc.

#align(center)[
  #grid(
    columns: 4,
    rows: 2,
    align: center,
    row-gutter: 7pt,
    column-gutter: 15pt,
    rect(
      width: 80pt,
      height: 55pt,
      radius: (top-left: 50%),
      fill: aqua,
    ),
    squircle(
      width: 80pt,
      height: 55pt,
      radius: (top-left: 50%),
      smoothing: 100%,
      fill: aqua,
    ),
    superellipse(
      width: 80pt,
      height: 55pt,
      radius: (top-left: 50%),
      exponent: 5,
      fill: aqua,
    ),
    clothoid(
      width: 80pt,
      height: 55pt,
      radius: (top-left: 50%),
      smoothing: 100%,
      fill: aqua,
    ),

    text(fill: medium-gray)[Rectangle],
    text(fill: medium-gray)[Squircle],
    text(fill: medium-gray)[Superellipse],
    text(fill: medium-gray)[Clothoid],
  )
]

= API reference

// squircle

#tidy.show-module(
  api-squircle,
  style: tidy.styles.default,
  first-heading-level: 1,
  show-module-name: false,
  show-outline: false,
)

// superellipse

#tidy.show-module(
  api-superellipse,
  style: tidy.styles.default,
  first-heading-level: 1,
  show-module-name: false,
  show-outline: false,
)

// clothoid

#tidy.show-module(
  api-clothoid,
  style: tidy.styles.default,
  first-heading-level: 1,
  show-module-name: false,
  show-outline: false,
)

= Concepts and examples

== Squircle

=== Smoothing

`smoothing` controls the gradual transition between edges and corners. In the example below, the shapes use `0%`, `60%`, and `100%` smoothing.

```example
#grid(
  rows: 3,
  gutter: 12pt,
  ..(0%, 60%, 100%).map(s => align(center + horizon)[
    #squircle(
      width: 75pt,
      height: 48pt,
      radius: 35%,
      smoothing: s,
      fill: aqua,
    )[smoothing: #repr(s)]
  ]),
)
```

=== Preserve smoothing

Large radii and high smoothing both consume space along a corner's two edges. When they require more space than is available, `preserve-smoothing` controls whether smoothing is reduced to fit or retained by compressing the Bézier transitions.

- `preserve-smoothing: false` keeps the requested radius within the limits of the shape and lowers smoothing until the corner fits.
- `preserve-smoothing: true` keeps both the requested radius and smoothing, shortening the Bézier transitions between the straight edges and the arc to make the corner fit.

Each corner has available space along each of its two edges, determined by the edge length and the radii of the corners at either end. With radius $r$ and smoothing $s$, a corner needs $p = (1 + s) r$ along each edge. If $p$ exceeds the available space $b$, `preserve-smoothing: false` reduces smoothing to $b / r - 1$ while keeping the radius within the limits of the shape. With `preserve-smoothing: true`, the radius and requested smoothing are kept, and the Bézier transitions are shortened to fit.

```example
#grid(
  rows: 2,
  gutter: 12pt,
  ..(false, true).map(keep => align(center + horizon)[
    #squircle(
      width: 75pt,
      height: 48pt,
      radius: 18pt,
      smoothing: 100%,
      preserve-smoothing: keep,
      fill: aqua,
    )[preserve-smoothing: #repr(keep)]
  ]),
)
```

=== Per-edge smoothing

Each half of a corner uses space along one of its two edges. The edges can have different amounts of available space. For example, on an elongated shape, the short edge may not accommodate the requested smoothing while the long edge still can. `per-edge-smoothing` controls whether the two halves share the tighter limit or use their available space independently.

- `per-edge-smoothing: false` uses the smaller of the two edge budgets for both halves, keeping the corner symmetric. If one edge has less room for smoothing, the other half is also limited to it and is less smoothed than it could be.
- `per-edge-smoothing: true` determines the response to limited space independently for each half.

When `preserve-smoothing` is `false`, smoothing is reduced only for corner halves that do not have enough space for the requested smoothing. Because the two halves can have different amounts of space available, their smoothing may be reduced by different amounts, resulting in different transition angles. When `preserve-smoothing` is `true`, both halves retain the requested smoothing and transition angles. Any half without enough space instead has its Bézier transition compressed to fit.

```example
#grid(
  rows: 2,
  gutter: 12pt,
  ..(false, true).map(u => align(center + horizon)[
    #squircle(
      width: 150pt,
      height: 48pt,
      radius: 25pt,
      smoothing: 100%,
      per-edge-smoothing: u,
      fill: aqua,
    )[per-edge-smoothing: #repr(u)]
  ]),
)
```

== Superellipse

=== Exponent

The `exponent` parameter on `superellipse` controls how sharp or square the corner profile is. It must be finite and is clamped into $[2, 12]$. At $n = 2$, the curve is a circle, drawing the same circular arc as `rect` rather than an approximation. Near the upper bound the cubic fit trades fidelity for staying inside the corner's footprint.

```example
#grid(
  rows: 3,
  gutter: 12pt,
  ..(2, 3, 6).map(n => align(center + horizon)[
    #superellipse(
      width: 75pt,
      height: 48pt,
      radius: 35%,
      exponent: n,
      fill: aqua,
    )[exponent: #n]
  ]),
)
```

== Clothoid

=== Smoothing

The `clothoid` function approximates Euler spirals to transition into rounded corners. Its ideal profile ramps curvature continuously across every seam.

For positive smoothing, the natural blend can require more space than the tighter adjacent-edge budget allows. In that case, `clothoid` uniformly scales the clothoid lengths and effective circular radius to fit while preserving its angular smoothing proportions. This happens after ordinary radius clamping. At `0%`, the function follows rounded-rectangle geometry instead.

```example
#grid(
  rows: 3,
  gutter: 12pt,
  ..(0%, 60%, 100%).map(s => align(center + horizon)[
    #clothoid(
      width: 75pt,
      height: 48pt,
      radius: 35%,
      smoothing: s,
      fill: aqua,
    )[smoothing: #repr(s)]
  ]),
)
```

== Common parameters

=== Size and body

`width` and `height` set the squircle's layout size. When both are `auto`, the squircle takes its size from the positional body passed in square brackets, as the first shape below illustrates, while the second uses fixed dimensions.

```example
#grid(
  rows: 2,
  gutter: 12pt,
  squircle(radius: 10pt, fill: aqua)[Auto-sized body],
  squircle(
    width: 150pt,
    height: 55pt,
    radius: 10pt,
    fill: aqua,
  )[Fixed width and height],
)
```

=== Fill

`fill` sets the squircle's interior paint. In the example below, the first shape uses a solid color and the second uses a linear gradient.

```example
#grid(
  rows: 2,
  gutter: 12pt,
  squircle(width: 75pt, height: 48pt, radius: 10pt, fill: aqua),
  squircle(width: 75pt, height: 48pt, radius: 10pt, fill: gradient.linear(..color.map.flare)),
)
```

=== Stroke

`stroke` draws the outline. In the example below, the first shape uses one stroke on every edge, while the second assigns each edge its own stroke.

```example
#grid(
  rows: 2,
  gutter: 12pt,
  squircle(
    width: 75pt,
    height: 48pt,
    radius: 10pt,
    stroke: 3pt + fuchsia,
  ),
  squircle(
    width: 75pt,
    height: 48pt,
    radius: 10pt,
    stroke: (top: 3pt + red, bottom: none, right: blue, left: 5pt + orange),
  ),
)
```

=== Radius

`radius` controls corner rounding. In the example below, the shapes show square corners, one shared radius, and a smaller top-left radius with a shared value for the remaining corners.

```example
#grid(
  rows: 3,
  gutter: 12pt,
  squircle(
    width: 75pt,
    height: 48pt,
    radius: 0pt,
    fill: aqua,
  ),
  squircle(
    width: 75pt,
    height: 48pt,
    radius: 35%,
    fill: aqua,
  ),
  squircle(
    width: 75pt,
    height: 48pt,
    radius: (top-left: 4pt, rest: 20pt),
    fill: aqua,
  ),
)
```

=== Inset and outset

`inset` pads the body, while `outset` expands the drawing without changing layout. In the example below, the first shape has neither, the second uses an inset, and the third uses an outset.

```example
#grid(
  rows: 3,
  gutter: 12pt,
  squircle(
    width: 90pt,
    height: 48pt,
    radius: 10pt,
    fill: aqua,
  )[No inset or outset],
  squircle(
    width: 90pt,
    height: 48pt,
    inset: (x: 20pt, y: 10pt),
    radius: 10pt,
    fill: aqua,
  )[Inset adds padding],
  squircle(
    width: 90pt,
    height: 48pt,
    radius: 10pt,
    outset: 8pt,
    fill: aqua,
  )[Outset expands the drawing],
)
```
