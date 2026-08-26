// Shared test helpers.
//
// This directory is named with a leading underscore, which Tytanic skips when
// collecting tests, so it is importable but never run on its own.

#import "/src/lib.typ": clothoid, squircle, superellipse

// Every geometry value in `src/` comes out of trigonometry, so an exact `==`
// would compare accumulated float error. Values that are merely passed through
// (dictionary resolution, for instance) are compared with `assert.eq` instead,
// since those must match exactly.
#let assert-len(got, expected, eps: 0.001pt, hint: "") = assert(
  calc.abs(got - expected) <= eps,
  message: (
    hint
      + ": expected "
      + repr(expected)
      + ", got "
      + repr(got)
      + " (off by "
      + repr(got - expected)
      + ")"
  ),
)

#let assert-angle(got, expected, eps: 0.001deg, hint: "") = assert(
  calc.abs(got - expected) <= eps,
  message: (
    hint + ": expected " + repr(expected) + ", got " + repr(got)
  ),
)

#let assert-point(got, expected, eps: 0.001pt, hint: "") = {
  assert-len(got.at(0), expected.at(0), eps: eps, hint: hint + ".x")
  assert-len(got.at(1), expected.at(1), eps: eps, hint: hint + ".y")
}

// Independent cubic evaluator for test oracles. Deliberately not imported
// from `src/corners.typ`, so the tests cannot inherit a production bug.
#let eval-cubic(c, t) = {
  let u = 1.0 - t
  let u3 = u * u * u
  let u2t = 3.0 * u * u * t
  let ut2 = 3.0 * u * t * t
  let t3 = t * t * t
  let x = (
    u3 * c.from.at(0) + u2t * c.c1.at(0) + ut2 * c.c2.at(0) + t3 * c.to.at(0)
  )
  let y = (
    u3 * c.from.at(1) + u2t * c.c1.at(1) + ut2 * c.c2.at(1) + t3 * c.to.at(1)
  )
  (x, y)
}

// Signed cross product against the ray from `center` through `ray`, scaled to
// dimensionless values like production's own splitter uses.
#let ray-cross(center, ray, point) = {
  let dx = (ray.at(0) - center.at(0)) / 1pt
  let dy = (ray.at(1) - center.at(1)) / 1pt
  let px = (point.at(0) - center.at(0)) / 1pt
  let py = (point.at(1) - center.at(1)) / 1pt
  px * dy - py * dx
}

// Distance between two points, kept in lengths.
#let point-distance(a, b) = {
  let dx = (a.at(0) - b.at(0)) / 1pt
  let dy = (a.at(1) - b.at(1)) / 1pt
  calc.sqrt(dx * dx + dy * dy) * 1pt
}

// Compares a dictionary of lengths key by key, so a failure names the key.
#let assert-lens(got, expected, eps: 0.001pt, hint: "") = {
  assert.eq(
    got.keys().sorted(),
    expected.keys().sorted(),
    message: hint + ": key sets differ",
  )
  for (key, value) in expected {
    assert-len(got.at(key), value, eps: eps, hint: hint + "." + key)
  }
}

// Lays cases out into a fixed grid of fixed-size cells.
//
// The parity tests call this from `test.typ` with `squircle.with(smoothing:
// 0%)` and from `ref.typ` with `rect`. Both documents are otherwise identical,
// including this call, so there is nowhere for a case to be quietly rendered
// differently on one side.
#let case-grid(shape, cases, cell: (150pt, 110pt), columns: 3) = {
  set page(width: auto, height: auto, margin: 10pt, fill: white)
  grid(
    columns: columns,
    ..cases.map(args => box(
      width: cell.at(0),
      height: cell.at(1),
      align(center + horizon, shape(..args)),
    )),
  )
}

// Like `case-grid`, but each entry is a whole layout that takes the shape
// function and places it in a container of its own. Needed wherever the point
// of the case is the container rather than the arguments -- fractional heights,
// mainly.
#let layout-grid(shape, layouts, cell: (150pt, 150pt), columns: 3) = {
  set page(width: auto, height: auto, margin: 10pt, fill: white)
  grid(
    columns: columns,
    ..layouts.map(build => box(
      width: cell.at(0),
      height: cell.at(1),
      align(center + horizon, build(shape)),
    )),
  )
}

// Asserts that a shape function and `rect` report the same size through `measure()`.
#let measure-parity(cases, shape: squircle, eps: 0.02pt) = {
  set page(width: 600pt, height: 600pt, margin: 0pt)
  context {
    for (label, args, region) in cases {
      let a = measure(rect(..args), ..region)
      let b = measure(shape(..args), ..region)
      assert(
        calc.abs(a.width - b.width) <= eps
          and calc.abs(a.height - b.height) <= eps,
        message: (
          label
            + ": rect measured "
            + repr(a.width)
            + " x "
            + repr(a.height)
            + ", "
            + repr(shape)
            + " measured "
            + repr(b.width)
            + " x "
            + repr(b.height)
        ),
      )
    }
  }
}
