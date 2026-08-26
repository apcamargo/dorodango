/// [max-deviations: 2]
///
/// Compare smoothing with the pinned figma-squircle fixtures.
///
/// The allowance covers the measured two-pixel difference between SVG arcs and
/// Typst cubic arcs at 144 ppi.

#import "/src/lib.typ": squircle
#import "/tests/_helpers/helpers.typ": case-grid
#import "cases.typ": cases

#case-grid(squircle, cases.map(case => case.args))
