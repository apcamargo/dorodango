/// Rendered parity for scalar `radius` values: an unsmoothed squircle *is* a
/// rounded rectangle, so at `smoothing: 0%` these must be the same pixels
/// `rect` draws.

#import "/tests/_helpers/cases.typ": radius-scalar
#import "/tests/_helpers/helpers.typ": case-grid
#import "/src/lib.typ": squircle

#case-grid(squircle.with(smoothing: 0%), radius-scalar, columns: 4)
