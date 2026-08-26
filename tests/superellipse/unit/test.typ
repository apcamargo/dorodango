/// Check the Lame equation, exponent limits, edge endpoints, and radial cuts.

#import "/src/corners.typ": _corner-geom, _superellipse-piece
#import "/tests/_helpers/helpers.typ": (
  assert-len, assert-point, eval-cubic, point-distance, ray-cross,
)

// Check the Lame equation on the top-right corner of a square.
#let w = 240pt
#let r = 72pt
#let pt = (w, 0pt)
#let budget = (cw: 120pt, ccw: 120pt)

#for (n, tol) in (
  // Measured maxima of the current three-cubic midpoint-matched fit at this
  // sampling density, with headroom for float noise. The sweep starts at 3:
  // Exponent 2 uses the circular arc checked below.
  (3, 0.005),
  (4, 0.01),
  (5, 0.015),
  (6, 0.02),
  (8, 0.03),
  (10, 0.045),
  (12, 0.06),
) {
  let piece = _superellipse-piece("top-right", pt, r, r, budget, n)

  for seg in piece.full {
    for step in range(1, 10) {
      let t = step / 10.0
      let (x, y) = eval-cubic(seg, t)
      let u = ((r - (w - x)) / r)
      let v = ((r - y) / r)
      let f = calc.pow(u, n) + calc.pow(v, n)
      assert(
        calc.abs(f - 1.0) <= tol,
        message: "superellipse n="
          + str(n)
          + " Lame error: "
          + str(calc.abs(f - 1.0))
          + " > "
          + str(tol),
      )
    }
  }
}

// Exponents below 2 clamp to 2.
#let p2 = _superellipse-piece("top-right", pt, r, r, budget, 2)
#let p-neg = _superellipse-piece("top-right", pt, r, r, budget, -10)
#let p1 = _superellipse-piece("top-right", pt, r, r, budget, 1)

#assert.eq(p2.full.len(), p-neg.full.len())
#for (s2, sn) in p2.full.zip(p-neg.full) {
  assert-point(s2.from, sn.from)
  assert-point(s2.c1, sn.c1)
  assert-point(s2.c2, sn.c2)
  assert-point(s2.to, sn.to)
}
#for (s2, s1) in p2.full.zip(p1.full) {
  assert-point(s2.from, s1.from)
  assert-point(s2.c1, s1.c1)
  assert-point(s2.c2, s1.c2)
  assert-point(s2.to, s1.to)
}

// The curve endpoints stay on the two edges.
#assert-point(p2.start, (w - r, 0pt))
#assert-point(p2.end, (w, r))

// Radial cuts must return different seams on their requested rays.
#let center = (w - r, r)
#let split-a = (w - 7 * r / 8, r / 8)
#let split-b = (w - r / 8, 7 * r / 8)
#let cut-a = _superellipse-piece(
  "top-right",
  pt,
  r,
  r,
  budget,
  5,
  split: split-a,
)
#let cut-b = _superellipse-piece(
  "top-right",
  pt,
  r,
  r,
  budget,
  5,
  split: split-b,
)

#for (tag, cut, ray) in (("a", cut-a, split-a), ("b", cut-b, split-b)) {
  assert(cut.first.len() > 0, message: "split " + tag + ": empty first half")
  assert(cut.second.len() > 0, message: "split " + tag + ": empty second half")
  assert-point(
    cut.first.first().from,
    cut.start,
    hint: "split " + tag + " first",
  )
  assert-point(
    cut.first.last().to,
    cut.mid,
    hint: "split " + tag + " first mid",
  )
  assert-point(
    cut.second.first().from,
    cut.mid,
    hint: "split " + tag + " second mid",
  )
  assert-point(cut.second.last().to, cut.end, hint: "split " + tag + " second")
  assert(
    calc.abs(ray-cross(center, ray, cut.mid)) < 0.01,
    message: "split " + tag + " must lie on its requested ray",
  )
}
#assert(
  point-distance(cut-a.mid, cut-b.mid) > 1pt,
  message: "different split rays must not share a seam",
)

// Check radial cuts in all four corner orientations.
#let h = 160pt
#let split-corners = (
  ("top-left", (0pt, 0pt)),
  ("top-right", (w, 0pt)),
  ("bottom-right", (w, h)),
  ("bottom-left", (0pt, h)),
)
#let corner-split(at, geom, along-in, along-out) = (
  at.at(0) + geom.edge-in.at(0) * along-in + geom.edge-out.at(0) * along-out,
  at.at(1) + geom.edge-in.at(1) * along-in + geom.edge-out.at(1) * along-out,
)
#for (corner, at) in split-corners {
  let geom = _corner-geom.at(corner)
  let center = corner-split(at, geom, r, r)
  let ray-a = corner-split(at, geom, 7 * r / 8, r / 8)
  let ray-b = corner-split(at, geom, r / 8, 7 * r / 8)
  let cut-a = _superellipse-piece(corner, at, r, r, budget, 5, split: ray-a)
  let cut-b = _superellipse-piece(corner, at, r, r, budget, 5, split: ray-b)
  assert(
    calc.abs(ray-cross(center, ray-a, cut-a.mid)) < 0.01,
    message: corner + ": first seam must lie on its requested ray",
  )
  assert(
    calc.abs(ray-cross(center, ray-b, cut-b.mid)) < 0.01,
    message: corner + ": second seam must lie on its requested ray",
  )
  assert(
    point-distance(cut-a.mid, cut-b.mid) > 1pt,
    message: corner + ": different rays must not share a seam",
  )
}

// Tight budgets move the fitted footprint, and radial cuts must follow it.
#let tight-budget = (cw: 30pt, ccw: 30pt)
#let tight-len = tight-budget.cw
#for (corner, at) in split-corners {
  let geom = _corner-geom.at(corner)
  let fit-center = corner-split(at, geom, tight-len, tight-len)
  let expected-end = (
    at.at(0) + geom.edge-out.at(0) * tight-len,
    at.at(1) + geom.edge-out.at(1) * tight-len,
  )
  let ray-a = corner-split(at, geom, 7 * tight-len / 8, tight-len / 8)
  let ray-b = corner-split(at, geom, tight-len / 8, 7 * tight-len / 8)
  let cut-a = _superellipse-piece(
    corner,
    at,
    r,
    r,
    tight-budget,
    5,
    split: ray-a,
  )
  let cut-b = _superellipse-piece(
    corner,
    at,
    r,
    r,
    tight-budget,
    5,
    split: ray-b,
  )
  for (tag, cut, ray) in (("a", cut-a, ray-a), ("b", cut-b, ray-b)) {
    // The fitted endpoints sit at the budget limit.
    assert-point(
      cut.start,
      corner-split(at, geom, tight-len, 0pt),
      hint: corner + " tight " + tag + " start",
    )
    assert-point(
      cut.end,
      expected-end,
      hint: corner + " tight " + tag + " footprint saturates to the budget",
    )
    // The splitter keeps the requested direction and moves the whole ray
    // rigidly with the fitted origin: the seam must lie on the line through
    // the fitted origin and the translated split.
    let shift = tight-len - r
    let ray-fit = (
      ray.at(0) + (geom.edge-in.at(0) + geom.edge-out.at(0)) * shift,
      ray.at(1) + (geom.edge-in.at(1) + geom.edge-out.at(1)) * shift,
    )
    assert(
      calc.abs(ray-cross(fit-center, ray-fit, cut.mid)) < 0.01,
      message: corner
        + " tight "
        + tag
        + ": seam must lie on its requested ray",
    )
  }
  assert(
    point-distance(cut-a.mid, cut-b.mid) > 1pt,
    message: corner + " tight: different rays must not share a seam",
  )
}

// With no edge budget, a positive radius collapses to the corner.
#let collapsed = _superellipse-piece(
  "top-right",
  pt,
  r,
  r,
  (cw: 0pt, ccw: 0pt),
  5,
)
#assert.eq(collapsed.arc, false)
#assert-point(collapsed.start, pt)
#assert-point(collapsed.mid, pt)
#assert-point(collapsed.end, pt)

// Exponents above 12 clamp to 12.

#let p-cap = _superellipse-piece("top-right", pt, r, r, budget, 12)
#for n in (12.6, 13, 40, 1000) {
  let p-over = _superellipse-piece("top-right", pt, r, r, budget, n)
  assert.eq(p-over.full.len(), p-cap.full.len())
  for (expected, actual) in p-cap.full.zip(p-over.full) {
    assert-point(expected.from, actual.from, eps: 0pt)
    assert-point(expected.c1, actual.c1, eps: 0pt)
    assert-point(expected.c2, actual.c2, eps: 0pt)
    assert-point(expected.to, actual.to, eps: 0pt)
  }
}

// At exponent 2, check the standard cubic approximation of a quarter circle.
#let kappa = 4.0 / 3.0 * calc.tan(22.5deg)
#let circle-corner = _superellipse-piece("top-right", pt, r, r, budget, 2)
#let drawn = circle-corner.full.filter(seg => (
  point-distance(seg.from, seg.to) > 0.001pt
))
#assert.eq(drawn.len(), 1)
#let arc = drawn.first()
#assert-point(arc.from, (w - r, 0pt), hint: "n=2 arc start")
#assert-point(arc.c1, (w - r + kappa * r, 0pt), hint: "n=2 arc c1")
#assert-point(arc.c2, (w, r - kappa * r), hint: "n=2 arc c2")
#assert-point(arc.to, (w, r), hint: "n=2 arc end")

// Control points must stay inside the fitted footprint.
#for n in (2, 3, 4, 5, 6, 8, 10, 11, 12, 13, 40) {
  let piece = _superellipse-piece("top-right", pt, r, r, budget, n)
  for seg in piece.full {
    for cp in (seg.from, seg.c1, seg.c2, seg.to) {
      assert(
        cp.at(0) >= w - r - 0.0001pt and cp.at(0) <= w + 0.0001pt,
        message: "n=" + str(n) + ": control point leaves the box in x",
      )
      assert(
        cp.at(1) >= -0.0001pt and cp.at(1) <= r + 0.0001pt,
        message: "n=" + str(n) + ": control point leaves the box in y",
      )
    }
  }
}

