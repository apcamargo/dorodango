/// Error messages are part of the public API. Assert the complete message.

#import "/src/lib.typ": clothoid, squircle, superellipse

#let message-of(fn) = catch(fn)
#let expect(fn, text) = assert.eq(catch(fn), "panicked with: squircle: " + text)


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

// Name the offending dictionary key.
#expect(
  () => squircle(radius: (top: "x")),
  "radius.top: expected relative length, found string",
)
#expect(
  () => squircle(inset: (x: 1fr)),
  "inset.x: expected relative length, found fraction",
)


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

// List multiple bad keys with the correct plural form.
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


// Distinguish mixed stroke dictionaries from unknown keys.
#expect(
  () => squircle(stroke: (top: red, paint: blue)),
  "stroke: cannot mix side keys with stroke-property keys",
)

// A side cannot use the whole-stroke `auto` value.
#expect(
  () => squircle(stroke: (top: auto)),
  "stroke.top: expected length, color, gradient, tiling, dictionary, stroke, "
    + "or none, found auto",
)

// Show both key sets when the dictionary kind is unclear.
#expect(
  () => squircle(stroke: (paint: red, bogus: 2pt)),
  "stroke: unexpected key \"bogus\", valid keys are \"left\", \"top\", "
    + "\"right\", \"bottom\", \"x\", \"y\", \"rest\", \"paint\", "
    + "\"thickness\", \"cap\", \"join\", \"dash\", and \"miter-limit\"",
)


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


// Report unknown names as argument errors, matching `rect`.
#expect(() => squircle(radiuss: 5pt), "unexpected argument: radiuss")

// Check `body:` before other unexpected names.
#expect(
  () => squircle(foo: 1pt, body: [a]),
  "unexpected named argument \"body\"; the body must be specified positionally",
)


// Check that valid calls do not panic.
#assert.eq(message-of(() => squircle(radius: 5pt)), none)
#assert.eq(message-of(() => squircle(radius: (top-left: 5pt))), none)
#assert.eq(message-of(() => squircle(stroke: (top: red))), none)
#assert.eq(message-of(() => squircle[body]), none)


// Smoothing accepts relative values and corner dictionaries. Clamping is
// checked by the rendered smoothing tests.
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

// Reject invalid values and dictionary keys.
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


#expect(
  () => superellipse(exponent: "x"),
  "exponent: expected number, found string",
)
#expect(
  () => superellipse(exponent: auto),
  "exponent: expected number, found auto",
)
#expect(
  () => superellipse(exponent: 1fr),
  "exponent: expected number, found fraction",
)
#expect(
  () => superellipse(smoothing: 50%),
  "unexpected argument: smoothing",
)
#expect(
  () => superellipse(exponent: float.nan),
  "exponent: expected finite number, found NaN",
)
#expect(
  () => superellipse(exponent: float.inf),
  "exponent: expected finite number, found positive infinity",
)
#expect(
  () => superellipse(exponent: -float.inf),
  "exponent: expected finite number, found negative infinity",
)
#for value in (2, 5, 8.5, -3, 0, 100) {
  assert.eq(catch(() => superellipse(exponent: value)), none)
}


#expect(
  () => clothoid(smoothing: "x"),
  "smoothing: expected relative length, found string",
)
#expect(
  () => clothoid(exponent: 4),
  "unexpected argument: exponent",
)
#for value in (0%, 50%, 100%, 200%, -50%, (top-left: 80%)) {
  assert.eq(catch(() => clothoid(smoothing: value)), none)
}
