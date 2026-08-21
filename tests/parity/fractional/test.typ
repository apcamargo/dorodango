/// Rendered parity off the pixel grid.
///
/// Every other parity test uses whole-point sizes, which at 144 ppi land on
/// exact pixel boundaries -- so an exact match there could in principle be the
/// grid hiding a sub-pixel disagreement. These sizes, radii and stroke widths
/// fall between pixels, and still have to match exactly.

#import "/tests/_helpers/cases.typ": fractional
#import "/tests/_helpers/helpers.typ": case-grid
#import "/src/lib.typ": squircle

#case-grid(squircle.with(smoothing: 0%), fractional, columns: 4)
