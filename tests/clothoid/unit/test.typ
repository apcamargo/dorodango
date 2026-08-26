/// Clothoid unit tests:
/// 1. Integrator correctness against Fresnel properties:
///    - L = 0 yields (0, 0)
///    - Points are finite and displacement grows monotonically with L
/// 2. Smoothing 0% matches quarter-circle arc endpoints and tangencies
/// 3. Seam continuity between clothoid fillets and central arc
/// 4. Split contract for cut outlines: `first` runs start -> mid, `second`
///    runs mid -> end, and the cut follows the requested radial split
/// 5. The two halves trace the same curve as `full`, not merely its endpoints

#import "/src/corners.typ": (
  _clothoid-piece, _corner-geom, _cubic, _integrate-clothoid,
  _split-segs-on-ray,
)
#import "/tests/_helpers/helpers.typ": (
  assert-len, assert-point, eval-cubic, point-distance, ray-cross,
)

// 1. Test integrator
#let r = 48.0
#let big-L = (calc.pi / 2.0) * r
#let a = 1.0 / (r * big-L)

#let zero = _integrate-clothoid(a, 0.0)
#assert.eq(zero.x, 0.0)
#assert.eq(zero.y, 0.0)

#let q = _integrate-clothoid(a, big-L / 4.0)
#let h = _integrate-clothoid(a, big-L / 2.0)
#let f = _integrate-clothoid(a, big-L)

#let mag(p) = calc.sqrt(p.x * p.x + p.y * p.y)
#assert(mag(q) < mag(h), message: "quarter length should be less than half")
#assert(mag(h) < mag(f), message: "half length should be less than full")

// 2. Smoothing 0% on corner (w, 0)
#let w = 200pt
#let rad = 40pt
#let pt = (w, 0pt)
#let h = 160pt
#let budget = (cw: 100pt, ccw: 100pt)
// Tighter than the corner's natural footprint at any smoothing above zero.
#let tight-budget = (cw: 30pt, ccw: 30pt)
// Compression pins the fitted footprint to this value.
#let tight-len = tight-budget.cw
#let p0 = _clothoid-piece("top-right", pt, rad, rad, budget, 0.0)

#assert-point(p0.start, (w - rad, 0pt))
#assert-point(p0.end, (w, rad))

// The outline is a quarter circle: it runs unbroken from `start` to `end` and
// every seam between its cubics sits `rad` from the corner's center. How many
// cubics it takes to get there is the construction's business.
#let center = (w - rad, rad)
#assert-point(p0.full.first().from, p0.start, hint: "full.from")
#assert-point(p0.full.last().to, p0.end, hint: "full.to")
#for (a, b) in p0.full.zip(p0.full.slice(1)) {
  assert-point(a.to, b.from, hint: "full seam")
  assert-len(point-distance(a.to, center), rad, hint: "seam on circle")
}

// 3. Smoothing 60% produces 3 segments: head cubic, arc, tail cubic
#let p60 = _clothoid-piece("top-right", pt, rad, rad, budget, 0.6)
#assert.eq(p60.full.len(), 3)
#let head = p60.full.at(0)
#let arc = p60.full.at(1)
#let tail = p60.full.at(2)

// Seams: head.to == arc.from, arc.to == tail.from
#assert-point(head.to, arc.from)
#assert-point(arc.to, tail.from)
#assert-point(head.from, p60.start)
#assert-point(tail.to, p60.end)

// 4. Smoothing 100% produces 2 segments: head cubic, tail cubic (no central arc)
#let p100 = _clothoid-piece("top-right", pt, rad, rad, budget, 1.0)
#assert.eq(p100.full.len(), 2)
#assert-point(p100.full.at(0).to, p100.full.at(1).from)

// At 100% smoothing the two clothoid cubics meet on the corner bisector. This
// is the inner top-left contour from the asymmetric public cap case. The ray
// reaches that shared join exactly, so it must not fall back to the start.
#let boundary-pt = (8pt, 8pt)
#let boundary-r = 14pt
#let nominal-center = (22pt, 22pt)
#let outer-pt = (-8pt, -8pt)
#let boundary-dir = (
  outer-pt.at(0) - nominal-center.at(0),
  outer-pt.at(1) - nominal-center.at(1),
)
#let boundary-dir-len = (
  calc.sqrt(
    (boundary-dir.at(0) / 1pt) * (boundary-dir.at(0) / 1pt)
      + (boundary-dir.at(1) / 1pt) * (boundary-dir.at(1) / 1pt),
  )
    * 1pt
)
#let boundary-split = (
  nominal-center.at(0) + boundary-dir.at(0) * (boundary-r / boundary-dir-len),
  nominal-center.at(1) + boundary-dir.at(1) * (boundary-r / boundary-dir-len),
)
#let boundary-cut = _clothoid-piece(
  "top-left",
  boundary-pt,
  boundary-r,
  boundary-r,
  (cw: 29.4pt, ccw: 29.4pt),
  1.0,
  split: boundary-split,
)
#assert(
  point-distance(boundary-cut.mid, boundary-cut.start) > 0.001pt,
  message: "a cubic-boundary ray hit must not clamp to start",
)

// 5. Split contract. `src/shape.typ` cuts an outline at a corner where the two
//    pens differ: it moves the pen to `mid` before emitting `second`, and draws
//    `first` after a line to `start`. So both halves must be non-empty, meet
//    exactly at `mid`, and reach the piece's own endpoints.
#let split-pt = (w - rad / 2, rad / 2)
#let smoothings = (0.0, 0.6, 1.0)

#for s in smoothings {
  let p = _clothoid-piece("top-right", pt, rad, rad, budget, s, split: split-pt)
  let tag = "smoothing " + repr(s)

  assert(p.first.len() > 0, message: tag + ": empty first half")
  assert(p.second.len() > 0, message: tag + ": empty second half")

  // The halves span the piece.
  assert-point(p.first.first().from, p.start, hint: tag + " first.from")
  assert-point(p.second.last().to, p.end, hint: tag + " second.to")

  // And they meet at `mid`, with no gap inside either half.
  assert-point(p.first.last().to, p.mid, hint: tag + " first->mid")
  assert-point(p.second.first().from, p.mid, hint: tag + " mid<-second")
  for (a, b) in p.first.zip(p.first.slice(1)) {
    assert-point(a.to, b.from, hint: tag + " first seam")
  }
  for (a, b) in p.second.zip(p.second.slice(1)) {
    assert-point(a.to, b.from, hint: tag + " second seam")
  }
}

// 6. With different adjacent pens, `shape.typ` requests different radial cuts
// for the outer, middle, and inner contours. Positive smoothing must keep each
// requested seam strictly inside the piece rather than snapping it to an
// endpoint or sharing one seam across rays. The exact on-ray check lives in
// the tight-budget branch further down: only there does compression pin the
// footprint to a known value, which makes the ray origin computable from the
// documented budget contract alone.
#let split-a = (w - 7 * rad / 8, rad / 8)
#let split-b = (w - rad / 8, 7 * rad / 8)
#for s in (0.3, 0.6, 1.0) {
  let cut-a = _clothoid-piece(
    "top-right",
    pt,
    rad,
    rad,
    budget,
    s,
    split: split-a,
  )
  let cut-b = _clothoid-piece(
    "top-right",
    pt,
    rad,
    rad,
    budget,
    s,
    split: split-b,
  )
  for (label, cut) in (("a", cut-a), ("b", cut-b)) {
    assert(
      point-distance(cut.mid, cut.start) > 0.001pt,
      message: "split " + label + " at " + repr(s) + ": seam clamped to start",
    )
    assert(
      point-distance(cut.mid, cut.end) > 0.001pt,
      message: "split " + label + " at " + repr(s) + ": seam clamped to end",
    )
  }
  assert(
    point-distance(cut-a.mid, cut-b.mid) > 1pt,
    message: "different rays must not share a seam at " + repr(s),
  )
}

// 7. Cutting a corner may not move it. `first ++ second` and `full` are two
//    ways of drawing one outline, so every point of either has to lie on the
//    other. Sharing endpoints is not enough: halves that bulge off the curve
//    between them would still chain correctly through `mid`.
#let sample(segs, steps) = {
  let pts = ()
  for seg in segs {
    for k in range(0, steps + 1) {
      pts.push(eval-cubic(seg, k / steps))
    }
  }
  pts
}

// Distance from `q` to the segment `a`-`b`, so a sampled curve is measured
// against the chords between its samples rather than against the samples
// themselves. Nearest-sample would report half the sampling step as a gap.
#let seg-dist(q, a, b) = {
  let ax = (b.at(0) - a.at(0)) / 1pt
  let ay = (b.at(1) - a.at(1)) / 1pt
  let qx = (q.at(0) - a.at(0)) / 1pt
  let qy = (q.at(1) - a.at(1)) / 1pt
  let len2 = ax * ax + ay * ay
  let t = if len2 == 0 { 0.0 } else {
    calc.max(0.0, calc.min(1.0, (qx * ax + qy * ay) / len2))
  }
  let dx = qx - t * ax
  let dy = qy - t * ay
  calc.sqrt(dx * dx + dy * dy) * 1pt
}

// Farthest any point of `a` sits from the polyline through `b`.
#let max-gap(a, b) = {
  let worst = 0pt
  for q in a {
    let best = none
    for i in range(b.len() - 1) {
      let d = seg-dist(q, b.at(i), b.at(i + 1))
      if best == none or d < best { best = d }
    }
    if best > worst { worst = best }
  }
  worst
}

// What is left is the two constructions' own error against the true curve: a
// 90-degree arc as one cubic is off by about 0.011pt at this radius, its
// halves by far less, and the chords between samples by under 0.01pt again.
#let coarse-steps = 12
#let dense-steps = 32

#let same-outline(p, tag) = {
  let halves = p.first + p.second
  assert-len(
    max-gap(sample(halves, coarse-steps), sample(p.full, dense-steps)),
    0pt,
    eps: 0.05pt,
    hint: tag + ": halves stray off `full`",
  )
  assert-len(
    max-gap(sample(p.full, coarse-steps), sample(halves, dense-steps)),
    0pt,
    eps: 0.05pt,
    hint: tag + ": `full` strays off the halves",
  )
}

// Every corner, since canonical coordinates run backwards along `edge-in` and
// a tangent carried across that mirror with the wrong sign would bend the
// halves off the curve at some corners while leaving others intact.
#let corners = (
  ("top-left", (0pt, 0pt)),
  ("top-right", (w, 0pt)),
  ("bottom-right", (w, h)),
  ("bottom-left", (0pt, h)),
)

// Each orientation's diagonal ray remains a useful same-outline regression.
#let bisector(corner, at) = {
  let g = _corner-geom.at(corner)
  (
    at.at(0) + (g.edge-in.at(0) + g.edge-out.at(0)) * rad / 2,
    at.at(1) + (g.edge-in.at(1) + g.edge-out.at(1)) * rad / 2,
  )
}
#let ray-at(at, geom, along-in, along-out) = (
  at.at(0) + geom.edge-in.at(0) * along-in + geom.edge-out.at(0) * along-out,
  at.at(1) + geom.edge-in.at(1) * along-in + geom.edge-out.at(1) * along-out,
)

#for (corner, at) in corners {
  let cut = bisector(corner, at)
  for s in (0.0, 0.3, 0.6, 1.0) {
    same-outline(
      _clothoid-piece(corner, at, rad, rad, budget, s, split: cut),
      corner + " at " + repr(s),
    )
  }

  // Over budget, so the corner is scaled down and the arc's radius with it.
  // Zero smoothing is left out: `_budgets` never hands a corner less room than
  // its radius, and the zero-smoothing path takes `budget` at face value.
  for s in (0.3, 0.6, 1.0) {
    same-outline(
      _clothoid-piece(corner, at, rad, rad, tight-budget, s, split: cut),
      corner + " over budget at " + repr(s),
    )
  }

  // A contour-specific ray can be off the symmetry diagonal when the adjacent
  // strokes have different widths. Test every reflected corner, including the
  // additional positive-smoothing compression path. Under a tight budget the
  // compression pins the footprint to the budget itself, so the fitted ray
  // origin is known from the documented contract alone and every seam must
  // lie exactly on its requested ray rather than falling back to an endpoint.
  let geom = _corner-geom.at(corner)
  let ray-a = ray-at(at, geom, 7 * rad / 8, rad / 8)
  let ray-b = ray-at(at, geom, rad / 8, 7 * rad / 8)
  let fit-center = ray-at(at, geom, tight-len, tight-len)
  let expected-end = (
    at.at(0) + geom.edge-out.at(0) * tight-len,
    at.at(1) + geom.edge-out.at(1) * tight-len,
  )
  for (budget-tag, corner-budget) in (
    ("normal", budget),
    ("tight", tight-budget),
  ) {
    for s in (0.3, 0.6, 1.0) {
      let cut-a = _clothoid-piece(
        corner,
        at,
        rad,
        rad,
        corner-budget,
        s,
        split: ray-a,
      )
      let cut-b = _clothoid-piece(
        corner,
        at,
        rad,
        rad,
        corner-budget,
        s,
        split: ray-b,
      )
      let tag = corner + " " + budget-tag + " at " + repr(s)
      for (label, cut) in (("a", cut-a), ("b", cut-b)) {
        assert(cut.first.len() > 0, message: tag + ": empty first half")
        assert(cut.second.len() > 0, message: tag + ": empty second half")
        assert(
          point-distance(cut.mid, cut.start) > 0.001pt,
          message: tag + ": seam clamped to start",
        )
        assert(
          point-distance(cut.mid, cut.end) > 0.001pt,
          message: tag + ": seam clamped to end",
        )
      }
      assert(
        point-distance(cut-a.mid, cut-b.mid) > 1pt,
        message: tag + ": different rays must not share a seam",
      )
      if budget-tag == "tight" {
        assert-point(
          cut-a.end,
          expected-end,
          hint: tag + " footprint saturates to the budget",
        )
        // The splitter keeps the requested direction and moves the whole ray
        // rigidly with the fitted origin: the seam must lie on the line
        // through the fitted origin and the translated split.
        let shift = tight-len - rad
        let ray-a-fit = (
          ray-a.at(0) + (geom.edge-in.at(0) + geom.edge-out.at(0)) * shift,
          ray-a.at(1) + (geom.edge-in.at(1) + geom.edge-out.at(1)) * shift,
        )
        let ray-b-fit = (
          ray-b.at(0) + (geom.edge-in.at(0) + geom.edge-out.at(0)) * shift,
          ray-b.at(1) + (geom.edge-in.at(1) + geom.edge-out.at(1)) * shift,
        )
        assert(
          calc.abs(ray-cross(fit-center, ray-a-fit, cut-a.mid)) < 0.01,
          message: tag + ": seam must lie on its requested ray",
        )
        assert(
          calc.abs(ray-cross(fit-center, ray-b-fit, cut-b.mid)) < 0.01,
          message: tag + ": seam must lie on its requested ray",
        )
      }
    }
  }
}

// 9. A positive radius that loses all straight-edge budget collapses onto the
//    corner point instead of producing a chamfered sharp record whose
//    endpoints are pulled `r` along both edges.
#let collapsed = _clothoid-piece(
  "top-right",
  (w, 0pt),
  rad,
  rad,
  (cw: 0pt, ccw: 0pt),
  0.6,
)
#assert.eq(collapsed.arc, false)
#assert-point(collapsed.start, (w, 0pt))
#assert-point(collapsed.mid, (w, 0pt))
#assert-point(collapsed.end, (w, 0pt))

// 10. An exact root at a bisection midpoint must stop bisection there instead
//     of drifting to the sampled interval boundary. The cubic below crosses
//     the ray exactly at t = 1/64: its y-controls (1, 0, 0, -63^3) put the
//     sign change at (1-t)/t = 63, and every Bernstein weight at t = 1/64 is
//     an exact dyadic rational, so the first midpoint's cross product is
//     exactly zero. The expected cut point is independent of any production
//     helper: a uniform x-control spacing traces x = 30t exactly.
#let exact-cubic = _cubic(
  (0pt, 1pt),
  (10pt, 0pt),
  (20pt, 0pt),
  (30pt, -250047pt),
)
#let exact-cut = _split-segs-on-ray((exact-cubic,), (0pt, 0pt), (30pt, 0pt))
#assert-len(exact-cut.mid.at(0), 30pt / 64, hint: "exact root kept")
#assert(
  exact-cut.mid.at(1) == 0pt,
  message: "exact root lies on the ray",
)
