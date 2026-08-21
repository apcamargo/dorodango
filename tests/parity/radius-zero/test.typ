/// Rendered parity with no rounding anywhere.
///
/// With every radius at zero `rect` keeps a plain rectangle primitive, which
/// Typst rasterises through a pixel-snapped fast path, while `squircle` always
/// emits a curve and so goes through analytic antialiasing. On whole-point
/// geometry -- which at 144 ppi lands on exact pixel boundaries -- the two
/// still agree pixel for pixel, so this test runs at the same zero tolerance
/// as the rest of the suite.
///
/// Off the pixel grid they do not, and no threshold would fix that: an
/// 80.37pt x 50.13pt rectangle differs from its `rect` counterpart in 524
/// pixels purely from the snapping, while giving that same shape a genuine 1pt
/// radius changes only 516. Any tolerance wide enough to admit the first would
/// swallow the second, so fractional zero-radius geometry is deliberately not
/// compared by pixels. `tests/parity/fractional` covers off-grid behaviour for
/// rounded shapes, where the comparison is exact, and
/// `tests/layout/measure-parity` covers the layout of these shapes directly.

#import "/tests/_helpers/cases.typ": radius-zero
#import "/tests/_helpers/helpers.typ": case-grid
#import "/src/lib.typ": squircle

#case-grid(squircle.with(smoothing: 0%), radius-zero, columns: 3)
