/// Rendered parity for clothoid with smoothing: 0% against rect.
/// At smoothing: 0%, clothoid corners are circular arcs, matching rounded rect.

#import "/tests/_helpers/cases.typ": radius-scalar
#import "/tests/_helpers/helpers.typ": case-grid
#import "/src/lib.typ": clothoid

#case-grid(clothoid.with(smoothing: 0%), radius-scalar, columns: 4)
