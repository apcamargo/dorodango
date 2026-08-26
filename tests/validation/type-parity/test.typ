/// `squircle` must accept and reject exactly what `rect` accepts and rejects.
///
/// Each case is written *once* and applied to both functions, so the two sides
/// cannot drift apart. `catch` picks up Typst's own argument errors as well as
/// `squircle`'s panics, which makes `rect` itself the oracle here -- there is
/// no hand-maintained list of "things that should fail" to go stale.

#import "/src/lib.typ": clothoid, squircle, superellipse

#let cases = (
  // -- radius --------------------------------------------------------------
  ("radius: 0pt", f => f(radius: 0pt)),
  ("radius: 10pt", f => f(radius: 10pt)),
  ("radius: -5pt", f => f(radius: -5pt)),
  ("radius: 30%", f => f(radius: 30%)),
  ("radius: 30% + 5pt", f => f(radius: 30% + 5pt)),
  ("radius: auto", f => f(radius: auto)),
  ("radius: none", f => f(radius: none)),
  ("radius: \"x\"", f => f(radius: "x")),
  ("radius: 3", f => f(radius: 3)),
  ("radius: 1fr", f => f(radius: 1fr)),
  ("radius: (:)", f => f(radius: (:))),
  ("radius: (rest: 5pt)", f => f(radius: (rest: 5pt))),
  ("radius: (top-left: 5pt)", f => f(radius: (top-left: 5pt))),
  ("radius: (top: 20pt, left: 5pt)", f => f(radius: (top: 20pt, left: 5pt))),
  // Corner dictionaries take no axis keys, and a misspelled corner is an error
  // rather than a silently ignored key.
  ("radius: (x: 3pt)", f => f(radius: (x: 3pt))),
  ("radius: (y: 3pt)", f => f(radius: (y: 3pt))),
  ("radius: (topleft: 5pt)", f => f(radius: (topleft: 5pt))),
  ("radius: (top: \"x\")", f => f(radius: (top: "x"))),
  ("radius: (top: auto)", f => f(radius: (top: auto))),

  // -- inset / outset ------------------------------------------------------
  ("inset: 3", f => f(inset: 3)),
  ("inset: auto", f => f(inset: auto)),
  ("inset: none", f => f(inset: none)),
  ("inset: (:)", f => f(inset: (:))),
  ("inset: (foo: 5pt)", f => f(inset: (foo: 5pt))),
  ("inset: (x: \"x\")", f => f(inset: (x: "x"))),
  ("inset: (x: 20pt, y: 2pt)", f => f(inset: (x: 20pt, y: 2pt))),
  ("inset: 25% + 5pt", f => f(inset: 25% + 5pt)),
  ("outset: auto", f => f(outset: auto)),
  ("outset: none", f => f(outset: none)),
  ("outset: (:)", f => f(outset: (:))),
  ("outset: (bar: 1pt)", f => f(outset: (bar: 1pt))),
  ("outset: (top: 1fr)", f => f(outset: (top: 1fr))),
  ("outset: -5pt", f => f(outset: -5pt)),

  // -- width / height ------------------------------------------------------
  ("width: 80pt", f => f(width: 80pt)),
  ("width: -20pt", f => f(width: -20pt)),
  ("width: 50% + 10pt", f => f(width: 50% + 10pt)),
  ("width: auto", f => f(width: auto)),
  ("width: \"x\"", f => f(width: "x")),
  ("width: none", f => f(width: none)),
  // A fraction is a valid height but not a valid width.
  ("width: 1fr", f => f(width: 1fr)),
  ("height: 1fr", f => f(height: 1fr)),
  ("height: 3fr", f => f(height: 3fr)),
  ("height: none", f => f(height: none)),
  ("height: 50% + 10pt", f => f(height: 50% + 10pt)),

  // -- fill ----------------------------------------------------------------
  ("fill: none", f => f(fill: none)),
  ("fill: red", f => f(fill: red)),
  ("fill: gradient", f => f(fill: gradient.linear(red, blue))),
  ("fill: 3", f => f(fill: 3)),
  ("fill: auto", f => f(fill: auto)),

  // -- stroke --------------------------------------------------------------
  ("stroke: auto", f => f(stroke: auto)),
  ("stroke: none", f => f(stroke: none)),
  ("stroke: 3", f => f(stroke: 3)),
  ("stroke: 3pt", f => f(stroke: 3pt)),
  ("stroke: red", f => f(stroke: red)),
  ("stroke: 2pt + red", f => f(stroke: 2pt + red)),
  ("stroke: (:)", f => f(stroke: (:))),
  ("stroke: (top: red)", f => f(stroke: (top: red))),
  ("stroke: (x: red, y: blue)", f => f(stroke: (x: red, y: blue))),
  ("stroke: (top: none)", f => f(stroke: (top: none))),
  (
    "stroke: (paint: red, thickness: 2pt)",
    f => f(
      stroke: (paint: red, thickness: 2pt),
    ),
  ),
  (
    "stroke: (paint: red, bogus: 2pt)",
    f => f(stroke: (paint: red, bogus: 2pt)),
  ),
  // Side keys and stroke-property keys cannot be mixed in one dictionary.
  ("stroke: (top: red, paint: blue)", f => f(stroke: (top: red, paint: blue))),
  // `auto` is meaningful for the whole stroke but not for a single side.
  ("stroke: (top: auto)", f => f(stroke: (top: auto))),

  // -- body ----------------------------------------------------------------
  ("body: content", f => f[hello]),
  ("body: none", f => f(none)),
  ("body: str", f => f("hello")),
  ("body: 3", f => f(3)),
  ("body: two positional", f => f([a], [b])),
  ("body: named", f => f(body: [a])),

  // -- unknown parameters --------------------------------------------------
  ("bogus: 1pt", f => f(bogus: 1pt)),
)

#for shape in (squircle, superellipse, clothoid) {
  for (label, apply) in cases {
    let rect-err = catch(() => apply(rect))
    let shape-err = catch(() => apply(shape))
    assert.eq(
      rect-err == none,
      shape-err == none,
      message: (
        label
          + ": rect "
          + (
            if rect-err == none { "accepted" } else {
              "rejected (" + rect-err + ")"
            }
          )
          + ", "
          + repr(shape)
          + " "
          + (
            if shape-err == none { "accepted" } else {
              "rejected (" + shape-err + ")"
            }
          )
      ),
    )
  }
}

