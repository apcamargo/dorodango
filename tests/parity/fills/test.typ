/// Rendered parity for paints: gradients, tilings and transparency all follow
/// the middle outline, which is also where a plain stroke runs.

#import "/tests/_helpers/cases.typ": fills
#import "/tests/_helpers/helpers.typ": case-grid
#import "/src/lib.typ": squircle

#case-grid(squircle.with(smoothing: 0%), fills, columns: 3)
