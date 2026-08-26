/// [max-deviations: 27]
///
/// Rendered public-API comparison for the superellipse family against the
/// pinned @lisse/core 0.7.2 reference implementation, whose `generatePath`
/// emits the same midpoint-matched three-cubic construction dorodango ports.
/// Cases stay inside their corner budgets with preserve-smoothing off, so both
/// implementations take identical code paths. Exponent 2 is deliberately absent:
/// there the Lamé curve is a circle and dorodango draws `rect`'s own arc, which
/// `parity/superellipse-scalar` pins exactly, so Lisse is the oracle for the
/// three-cubic fit at exponents above 2 only. Both sides trace the same
/// curves. Only Lisse's four-decimal path coordinate rounding shifts
/// antialiased coverage along boundaries, so exact equality is unattainable.
/// 27 is the measured baseline of the first comparison run.

#import "/src/lib.typ": superellipse
#import "/tests/_helpers/helpers.typ": case-grid
#import "cases.typ": cases

#case-grid(superellipse, cases.map(case => case.args))
