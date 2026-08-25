/// [max-deviations: 4]
///
/// Rendered public-API comparisons for per-edge smoothing on uniform, split,
/// and thick-ring stroke contours.
///
/// SVG arcs and Typst's cubic arc approximation differ by four antialiased
/// pixels at 144 ppi; the allowance is the measured exact-comparison baseline.

#import "/src/lib.typ": squircle
#import "/tests/_helpers/helpers.typ": case-grid
#import "cases.typ": cases

#case-grid(squircle, cases.map(case => case.args))
