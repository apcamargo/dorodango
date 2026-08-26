/// [max-deviations: 61]
///
/// Rendered public-API comparison for the clothoid family against the pinned
/// @lisse/core 0.7.2 reference implementation. Both integrate the Euler spiral
/// with Simpson's rule over the same equations. Lisse emits native SVG arcs for
/// the central arc while dorodango approximates it with a kappa cubic. The two
/// arc renderings agree to well under a pixel, but antialiased coverage along
/// each arc boundary still differs, so exact equality is unattainable. 61 is
/// the measured baseline of the first comparison run.

#import "/src/lib.typ": clothoid
#import "/tests/_helpers/helpers.typ": case-grid
#import "cases.typ": cases

#case-grid(clothoid, cases.map(case => case.args))
