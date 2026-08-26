/// [max-deviations: 27]
///
/// Compare superellipse output with pinned Lisse fixtures.
///
/// The allowance covers rounded fixture coordinates and the resulting pixel
/// differences at 144 ppi. Exponent 2 is covered by rect parity.

#import "/src/lib.typ": superellipse
#import "/tests/_helpers/helpers.typ": case-grid
#import "cases.typ": cases

#case-grid(superellipse, cases.map(case => case.args))
