/// [max-deviations: 61]
///
/// Compare clothoid output with pinned Lisse fixtures.
///
/// The allowance covers the measured pixel differences between SVG arcs and
/// Typst cubic arcs at 144 ppi.

#import "/src/lib.typ": clothoid
#import "/tests/_helpers/helpers.typ": case-grid
#import "cases.typ": cases

#case-grid(clothoid, cases.map(case => case.args))
