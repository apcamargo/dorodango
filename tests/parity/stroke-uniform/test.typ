/// Rendered parity for a single pen around the whole outline, including the
/// `auto` default, dashes, joins, and ratio radii resolved against a stroked
/// box.

#import "/tests/_helpers/cases.typ": stroke-uniform
#import "/tests/_helpers/helpers.typ": case-grid
#import "/src/lib.typ": squircle

#case-grid(squircle.with(smoothing: 0%), stroke-uniform, columns: 4)
