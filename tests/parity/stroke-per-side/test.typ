/// Rendered parity for per-side strokes. Where two sides differ, `rect` cuts
/// the outline open and fills each run rather than stroking it, so these
/// exercise a different drawing path from the uniform case.

#import "/tests/_helpers/cases.typ": stroke-per-side
#import "/tests/_helpers/helpers.typ": case-grid
#import "/src/lib.typ": squircle

#case-grid(squircle.with(smoothing: 0%), stroke-per-side, columns: 4)
