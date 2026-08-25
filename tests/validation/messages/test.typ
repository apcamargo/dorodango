/// The wording of a rejection is part of the API: it is what a user sees when
/// they misspell a corner. These are asserted in full rather than by substring
/// so that a diagnostic cannot quietly degrade into something less specific.
///
/// `catch` prefixes panics with "panicked with: ", and every `squircle`
/// diagnostic then names the package and the offending parameter.

#import "/src/lib.typ": squircle

#let message-of(fn) = catch(fn)
#let expect(fn, text) = assert.eq(catch(fn), "panicked with: squircle: " + text)

// -- Wrong types -----------------------------------------------------------

#expect(
  () => squircle(radius: auto),
  "radius: expected relative length, found auto",
)
#expect(
  () => squircle(radius: 3),
  "radius: expected relative length, found integer",
)
#expect(
  () => squircle(width: 1fr),
  "width: expected auto or relative length, found fraction",
)
// `height` does take a fraction, so its "expected" list is the longer one.
#expect(
  () => squircle(height: "x"),
  "height: expected auto or relative length or fraction, found string",
)
#expect(() => squircle(fill: 3), "fill: expected paint or none, found integer")
#expect(
  () => squircle(preserve-smoothing: 3),
  "preserve-smoothing: expected boolean, found integer",
)
#expect(
  () => squircle(per-edge-smoothing: 3),
  "per-edge-smoothing: expected boolean, found integer",
)

// The key of the offending entry is named, not just the parameter.
#expect(
  () => squircle(radius: (top: "x")),
  "radius.top: expected relative length, found string",
)
#expect(
  () => squircle(inset: (x: 1fr)),
  "inset.x: expected relative length, found fraction",
)

// -- Unknown keys ----------------------------------------------------------

// A misspelled corner lists every key that would have worked.
#expect(
  () => squircle(radius: (topleft: 5pt)),
  "radius: unexpected key \"topleft\", valid keys are \"top-left\", "
    + "\"top-right\", \"bottom-right\", \"bottom-left\", \"left\", \"top\", "
    + "\"right\", \"bottom\", and \"rest\"",
)

// Corner parameters take no axis keys, and say so with the same list.
#expect(
  () => squircle(smoothing: (x: 3pt)),
  "smoothing: unexpected key \"x\", valid keys are \"top-left\", "
    + "\"top-right\", \"bottom-right\", \"bottom-left\", \"left\", \"top\", "
    + "\"right\", \"bottom\", and \"rest\"",
)

// Side parameters have their own, different set.
#expect(
  () => squircle(inset: (foo: 5pt)),
  "inset: unexpected key \"foo\", valid keys are \"left\", \"top\", "
    + "\"right\", \"bottom\", \"x\", \"y\", and \"rest\"",
)
#expect(
  () => squircle(outset: (bar: 1pt)),
  "outset: unexpected key \"bar\", valid keys are \"left\", \"top\", "
    + "\"right\", \"bottom\", \"x\", \"y\", and \"rest\"",
)

// Several bad keys are listed together, and the noun agrees in number.
#expect(
  () => squircle(radius: (foo: 1pt, bar: 2pt)),
  "radius: unexpected keys \"foo\" and \"bar\", valid keys are \"top-left\", "
    + "\"top-right\", \"bottom-right\", \"bottom-left\", \"left\", \"top\", "
    + "\"right\", \"bottom\", and \"rest\"",
)
#expect(
  () => squircle(inset: (foo: 1pt, bar: 2pt, baz: 3pt)),
  "inset: unexpected keys \"foo\", \"bar\", and \"baz\", valid keys are "
    + "\"left\", \"top\", \"right\", \"bottom\", \"x\", \"y\", and \"rest\"",
)

// -- Strokes ---------------------------------------------------------------

// A dictionary that is neither a side dictionary nor a property dictionary is
// reported as the mix-up it is, rather than as an unknown key.
#expect(
  () => squircle(stroke: (top: red, paint: blue)),
  "stroke: cannot mix side keys with stroke-property keys",
)

// `auto` means "the default stroke" for the whole parameter, but there is no
// such thing for one side, so the per-side message leaves it out of the list.
#expect(
  () => squircle(stroke: (top: auto)),
  "stroke.top: expected length, color, gradient, tiling, dictionary, stroke, "
    + "or none, found auto",
)

// An unknown key could have been meant as either kind, so both sets are
// offered rather than guessing which dictionary the user was aiming for.
#expect(
  () => squircle(stroke: (paint: red, bogus: 2pt)),
  "stroke: unexpected key \"bogus\", valid keys are \"left\", \"top\", "
    + "\"right\", \"bottom\", \"x\", \"y\", \"rest\", \"paint\", "
    + "\"thickness\", \"cap\", \"join\", \"dash\", and \"miter-limit\"",
)

// -- Body ------------------------------------------------------------------

#expect(
  () => squircle(body: [a]),
  "unexpected named argument \"body\"; the body must be specified positionally",
)
#expect(
  () => squircle([a], [b]),
  "expected at most one positional body, found 2",
)
#expect(
  () => squircle(3),
  "body: expected content, string, symbol, or none, found integer",
)

// -- Unknown parameters ----------------------------------------------------

// The body sink swallows every named argument, so a misspelt parameter has to
// be reported as the typo it is rather than as a misplaced body. The wording
// is `rect`'s: `#rect(radiuss: 5pt)` says `unexpected argument: radiuss`.
#expect(() => squircle(radiuss: 5pt), "unexpected argument: radiuss")

// `body:` is checked before any other name, so its own message is what a
// caller sees whichever order the arguments came in.
#expect(
  () => squircle(foo: 1pt, body: [a]),
  "unexpected named argument \"body\"; the body must be specified positionally",
)

// -- Nothing is raised for valid input -------------------------------------

// Proves the harness can tell the two apart, rather than reporting a panic for
// everything it is handed.
#assert.eq(message-of(() => squircle(radius: 5pt)), none)
#assert.eq(message-of(() => squircle(radius: (top-left: 5pt))), none)
#assert.eq(message-of(() => squircle(stroke: (top: red))), none)
#assert.eq(message-of(() => squircle[body]), none)

// -- Smoothing-specific contract ------------------------------------------

// `smoothing` accepts the same relative spellings as `radius`, including a
// per-corner dictionary. Values outside the visual range are accepted here;
// `smoothing/clamping` proves their rendered result is clamped.
#for value in (
  0%,
  60%,
  100%,
  200%,
  -50%,
  0.5pt,
  50% + 0pt,
  (:),
  (rest: 50%),
  (top-left: 100%, rest: 0%),
  (top: 100%, bottom: 0%),
) {
  assert.eq(catch(() => squircle(smoothing: value)), none)
}

// Values and dictionary keys outside that contract are rejected rather than
// silently coerced or ignored.
#for value in (
  "x",
  3,
  1fr,
  auto,
  none,
  true,
  (x: 50%),
  (y: 50%),
  (topleft: 50%),
  (top-left: "x"),
) {
  assert-panic(() => squircle(smoothing: value))
}

#assert.eq(catch(() => squircle(preserve-smoothing: true)), none)
#assert.eq(catch(() => squircle(preserve-smoothing: false)), none)
#for value in (0, none, auto, "true", (top-left: true)) {
  assert-panic(() => squircle(preserve-smoothing: value))
}

#assert.eq(catch(() => squircle(per-edge-smoothing: true)), none)
#assert.eq(catch(() => squircle(per-edge-smoothing: false)), none)
#for value in (0, none, auto, "true", (top-left: true)) {
  assert-panic(() => squircle(per-edge-smoothing: value))
}
