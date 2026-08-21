/// Rendered parity for stroke caps, which are only drawn where a stroke really
/// ends -- that is, where the neighbouring side is unstroked. At small radii
/// the cap degenerates back to a plain butt end.

#import "/tests/_helpers/cases.typ": stroke-caps
#import "/tests/_helpers/helpers.typ": case-grid
#import "/src/lib.typ": squircle

#case-grid(squircle.with(smoothing: 0%), stroke-caps, columns: 3)
