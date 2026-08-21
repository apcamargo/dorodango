/// `squircle` must occupy exactly the space `rect` would.
///
/// This is checked through `measure()` rather than by rendering, so a
/// disagreement is reported as two numbers instead of as a pile of differing
/// pixels. Both shapes are measured in the same document and the same region,
/// so fonts and layout context cancel out.
///
/// `smoothing` is deliberately left at its default: it changes the drawing, and
/// must never change the box.

#import "/tests/_helpers/helpers.typ": measure-parity

#let body = [Hello squircle world]
#let long = [Padded text wrapped in a squircle whose size is driven by this body.]
#let unbounded = arguments()
#let wide = arguments(width: 300pt)

#measure-parity((
  // -- Empty shapes ---------------------------------------------------------
  // With no body and no size, both fall back to 45pt x 30pt, capped by the
  // region.
  ("empty, unbounded", arguments(), unbounded),
  ("empty, region 20x15", arguments(), arguments(width: 20pt, height: 15pt)),
  ("empty, region 100x15", arguments(), arguments(width: 100pt, height: 15pt)),
  ("empty, region 20x100", arguments(), arguments(width: 20pt, height: 100pt)),

  // -- Auto size driven by the body ----------------------------------------
  ("body, default inset", arguments(body), wide),
  ("body, inset 0pt", arguments(inset: 0pt, body), wide),
  ("body, inset 10pt", arguments(inset: 10pt, body), wide),
  // A ratio inset resolves against the box's own final size, so the box is the
  // solution of a fixed point rather than body + padding.
  ("body, inset 25%", arguments(inset: 25%, body), wide),
  ("body, inset 25% + 5pt", arguments(inset: 25% + 5pt, body), wide),
  ("body, inset 40%", arguments(inset: 40%, body), wide),
  (
    "body, inset (x: 20pt, y: 2pt)",
    arguments(inset: (x: 20pt, y: 2pt), body),
    wide,
  ),
  (
    "body, inset (left: 2pt, right: 24pt)",
    arguments(inset: (left: 2pt, right: 24pt), body),
    wide,
  ),
  // A side dictionary leaves the other sides at `rect`'s own 5pt default.
  ("body, inset (top: 20pt)", arguments(inset: (top: 20pt), body), wide),
  ("body, inset (:)", arguments(inset: (:), body), wide),
  ("body, inset (rest: 2pt)", arguments(inset: (rest: 2pt), body), wide),
  ("body, unbounded", arguments(body), unbounded),
  ("body, inset 25%, unbounded", arguments(inset: 25%, body), unbounded),

  // -- Line breaking --------------------------------------------------------
  // These are what exercise the fixed-point width iteration: the width fed to
  // the line breaker depends on the box width, which depends on the resulting
  // layout.
  (
    "long, inset 25%, 200pt",
    arguments(inset: 25%, long),
    arguments(width: 200pt),
  ),
  ("long, default inset, 200pt", arguments(long), arguments(width: 200pt)),
  (
    "long, inset 10%, 120pt",
    arguments(inset: 10%, long),
    arguments(width: 120pt),
  ),
  ("long, overflowing 60pt", arguments(long), arguments(width: 60pt)),

  // -- Explicit sizes -------------------------------------------------------
  (
    "width 70%, height 70%",
    arguments(width: 70%, height: 70%),
    arguments(width: 200pt, height: 100pt),
  ),
  (
    "width 50% + 10pt",
    arguments(width: 50% + 10pt, height: 40pt),
    arguments(width: 200pt),
  ),
  (
    "height 50% + 10pt",
    arguments(width: 40pt, height: 50% + 10pt),
    arguments(width: 200pt, height: 100pt),
  ),
  // In an unbounded region a ratio resolves to zero, and a `relative` keeps
  // only its absolute part.
  ("width 50%, unbounded", arguments(width: 50%, height: 20pt), unbounded),
  ("height 50%, unbounded", arguments(width: 20pt, height: 50%), unbounded),
  (
    "width 50% + 10pt, unbounded",
    arguments(width: 50% + 10pt, height: 20pt),
    unbounded,
  ),
  (
    "width 120pt, height 80pt",
    arguments(width: 120pt, height: 80pt),
    unbounded,
  ),
  ("width 120pt + long body", arguments(width: 120pt, long), wide),
  ("height 80pt + body", arguments(height: 80pt, body), wide),

  // -- Outset ---------------------------------------------------------------
  // `outset` expands the drawing only; the layout box is unchanged.
  (
    "outset 10pt",
    arguments(width: 80pt, height: 60pt, outset: 10pt),
    wide,
  ),
  ("outset 10% + body", arguments(outset: 10%, body), wide),

  // -- Other bodies ---------------------------------------------------------
  ("body = block(100%)", arguments(block(width: 100%, height: 20pt)), wide),
  ("body = list", arguments(list([a], [b])), wide),
  ("body = three lines", arguments([a\ b\ c]), wide),
  ("body = empty content", arguments([]), wide),
  ("body = str", arguments("hello"), wide),

  // -- Fractions ------------------------------------------------------------
  // A fraction is resolved by the layout engine after `measure()` has already
  // answered, so both report a zero height here.
  (
    "height 1fr",
    arguments(width: 40pt, height: 1fr),
    arguments(width: 300pt, height: 200pt),
  ),
  ("height 1fr + body", arguments(width: 40pt, height: 1fr, body), wide),
))
