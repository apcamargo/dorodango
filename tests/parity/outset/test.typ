/// Rendered parity for `outset`. The outset changes the box the radius is
/// clamped against, so it is not simply a translation of the same shape.

#import "/tests/_helpers/cases.typ": outset-cases
#import "/tests/_helpers/helpers.typ": case-grid
#import "/src/lib.typ": squircle

#case-grid(squircle.with(smoothing: 0%), outset-cases, columns: 4)
