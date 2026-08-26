#import "/src/lib.typ": squircle
#import "/tests/_helpers/helpers.typ": case-grid
#import "cases.typ": cases

#case-grid(
  squircle.with(per-edge-smoothing: false),
  cases.map(case => case.args),
)
