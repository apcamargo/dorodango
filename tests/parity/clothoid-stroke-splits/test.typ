/// Rendered parity for clothoid with smoothing: 0% against rect where the
/// outline is cut open: adjacent sides carrying different pens split each run
/// at the pen-change corner, so the corner is drawn from its two halves rather
/// than whole.
///
/// `stroke-per-side` drives the stroked runs, `stroke-thick` the filled-ring
/// path, and `stroke-caps` the butt lines a cut draws across the stroke, which
/// read the halves on the outer and inner outlines alike.

#import "/tests/_helpers/cases.typ": stroke-caps, stroke-per-side, stroke-thick
#import "/tests/_helpers/helpers.typ": case-grid
#import "/src/lib.typ": clothoid

#case-grid(clothoid.with(smoothing: 0%), stroke-per-side, columns: 4)
#case-grid(clothoid.with(smoothing: 0%), stroke-thick, columns: 4)
#case-grid(clothoid.with(smoothing: 0%), stroke-caps, columns: 4)
