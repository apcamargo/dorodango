// The disabled public option is the oracle for cases where per-edge smoothing
// is specified to be inert.

#import "/src/lib.typ": squircle
#import "/tests/_helpers/helpers.typ": case-grid
#import "cases.typ": cases

#case-grid(
  squircle.with(per-edge-smoothing: false),
  cases.map(case => case.args),
)
