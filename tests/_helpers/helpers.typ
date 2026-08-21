// Shared test helpers.
//
// This directory is named with a leading underscore, which Tytanic skips when
// collecting tests, so it is importable but never run on its own.

#import "/src/lib.typ": squircle

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

// Asserts that `squircle` and `rect` report the same size through `measure()`.
//
// `cases` is a list of `(label, arguments(..), arguments(..))`: the shape
// arguments, then the region to measure in. Smoothing is deliberately left at
// its default -- it must not influence layout at all.
#let measure-parity(cases, eps: 0.02pt) = {
  set page(width: 600pt, height: 600pt, margin: 0pt)
  context {
    for (label, args, region) in cases {
      let a = measure(rect(..args), ..region)
      let b = measure(squircle(..args), ..region)
      assert(
        calc.abs(a.width - b.width) <= eps
          and calc.abs(a.height - b.height) <= eps,
        message: (
          label
            + ": rect measured "
            + repr(a.width)
            + " x "
            + repr(a.height)
            + ", squircle measured "
            + repr(b.width)
            + " x "
            + repr(b.height)
        ),
      )
    }
  }
}
