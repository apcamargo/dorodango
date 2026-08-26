# dorodango

[![Typst package](https://img.shields.io/badge/dynamic/toml?url=https%3A%2F%2Fraw.githubusercontent.com%2Fapcamargo%2Fdorodango%2Fmain%2Ftypst.toml&query=%24.package.version&prefix=v&logo=typst&label=package&color=239DAD)](https://typst.app/universe/package/dorodango)
[![Manual](https://img.shields.io/badge/User_manual-blue)](./docs/manual.pdf)
[![GitHub repository](https://img.shields.io/badge/GitHub-Repository-black?logo=github)](https://github.com/apcamargo/dorodango)

`dorodango` is a Typst package for drawing squircles with tunable corner smoothing.

## Background

Smooth-cornered rectangles blend their corners gradually into straight edges. Unlike a standard rounded rectangle, which transitions abruptly from a straight edge to a circular arc, these curves approximate profiles with continuous curvature around each corner.

`dorodango` provides three corner curve families:

- `squircle`: the [Figma](https://www.figma.com/blog/desperately-seeking-squircles/) curve family (cubic shoulders into circular arcs).
- `superellipse`: cubic approximations of Lamé curves parameterized by an exponent.
- `clothoid`: cubic approximations of Euler-spiral blends with linear curvature ramps.

# Documentation

Refer to the [manual](./docs/manual.pdf) for a full API reference and usage examples.

## Quickstart

In a Typst document, import the `dorodango` package:

```typ
#import "@preview/dorodango:0.2.0": *
```

`dorodango` provides a `squircle` function that mirrors the built-in `rect` element but adds parameters for controlling corner smoothing. The example below compares a rectangle and a squircle with the same size and corner radius to show how their corner-to-edge transitions differ.

```typ
#grid(
  columns: (1fr, 1fr),
  gutter: 14pt,
  rect(width: 90pt, height: 60pt, radius: (top-left: 50%), fill: aqua),
  squircle(
    width: 90pt,
    height: 60pt,
    radius: (top-left: 50%),
    smoothing: 100%,
    fill: aqua,
  ),
)
```

<picture>
  <source
    media="(prefers-color-scheme: dark)"
    srcset="assets/rectangle-vs-squircle-dark.svg"
  />
  <img
    src="assets/rectangle-vs-squircle-light.svg"
    alt="Side-by-side comparison of a rounded rectangle and a squircle with the same size and corner radius. The rectangle's top-left corner has an abrupt transition from straight edge to circular arc, while the squircle's corner curves smoothly into the edges."
  />
</picture>

## Customize squircle corners

Three parameters control the appearance of a squircle's corners:

- `smoothing` controls how gradually a straight edge blends into its rounded corner. At `0%`, the shape is an ordinary rounded rectangle. Higher values make the transition more gradual, and at `100%` the circular arc has zero length and the two Bézier transitions meet at a single point.
- `preserve-smoothing` determines how the corner adapts when its requested radius and smoothing do not both fit.
- `per-edge-smoothing` lets each edge of a corner use its own available space instead of limiting both to the tighter edge.

The shapes below share the same size and radius. The final shape preserves its requested smoothing after it no longer fits.

```typ
#grid(
  columns: (1fr, 1fr, 1fr),
  gutter: 14pt,
  squircle(
    width: 85pt,
    height: 55pt,
    radius: 20pt,
    smoothing: 5%,
    fill: aqua,
  ),
  squircle(
    width: 85pt,
    height: 55pt,
    radius: 20pt,
    smoothing: 100%,
    fill: aqua,
  ),
  squircle(
    width: 85pt,
    height: 55pt,
    radius: 20pt,
    smoothing: 100%,
    preserve-smoothing: true,
    fill: aqua,
  ),
)
```

<picture>
  <source
    media="(prefers-color-scheme: dark)"
    srcset="assets/smoothing-comparison-dark.svg"
  />
  <img
    src="assets/smoothing-comparison-light.svg"
    alt="Three squircles of the same size and corner radius. The first and second set the smoothing parameter to 5% and 100%, respectively. The third adds preserve-smoothing, retaining full smoothing and looking visibly compressed at the corners."
  />
</picture>

On the pill-shaped squircle below, the radius consumes the short vertical edges, leaving them no room for smoothing, while the long horizontal edges still have space. By default, each corner's two transition angles stay symmetric, so the horizontal half is clamped to the vertical half's limit and is less smoothed than it could be. Setting `per-edge-smoothing` to `true` lets each half use all the space available on its edge, so the two halves can smooth independently.

```typ
#grid(
  columns: (1fr, 1fr),
  gutter: 14pt,
  squircle(
    width: 160pt,
    height: 50pt,
    radius: 25pt,
    smoothing: 100%,
    fill: aqua,
  ),
  squircle(
    width: 160pt,
    height: 50pt,
    radius: 25pt,
    smoothing: 100%,
    per-edge-smoothing: true,
    fill: aqua,
  ),
)
```

<picture>
  <source
    media="(prefers-color-scheme: dark)"
    srcset="assets/per-edge-smoothing-comparison-dark.svg"
  />
  <img
    src="assets/per-edge-smoothing-comparison-light.svg"
    alt="Two squircles of the same size and corner radius, with radius half the height. The first, with per-edge-smoothing false, has smoothing clamped away on every edge. The second, with per-edge-smoothing true, keeps full smoothing on its long edges while its short, semicircular ends stay unchanged."
  />
</picture>

## Alternative corner curve families

Besides `squircle`, `dorodango` provides two additional functions, `superellipse` and `clothoid`, which round corners using different curve families.

```typ
#grid(
  columns: (1fr, 1fr, 1fr),
  gutter: 14pt,
  row-gutter: 12pt,
  align: center + top,
  squircle(
    width: 85pt,
    height: 55pt,
    radius: 20pt,
    smoothing: 100%,
    fill: aqua,
  ),
  superellipse(
    width: 85pt,
    height: 55pt,
    radius: 20pt,
    exponent: 5,
    fill: aqua,
  ),
  clothoid(
    width: 85pt,
    height: 55pt,
    radius: 20pt,
    smoothing: 100%,
    fill: aqua,
  ),

  [Squircle], [Superellipse], [Clothoid],
)
```

<picture>
  <source
    media="(prefers-color-scheme: dark)"
    srcset="assets/corner-family-comparison-dark.svg"
  />
  <img
    src="assets/corner-family-comparison-light.svg"
    alt="Three rectangles of the same size and corner radius, labeled Squircle, Superellipse, and Clothoid. Their corners differ subtly in how the curves meet the straight edges. The squircle blends through Figma-style cubic shoulders, the superellipse follows a Lamé curve profile, and the clothoid ramps curvature linearly along Euler-spiral transitions."
  />
</picture>
