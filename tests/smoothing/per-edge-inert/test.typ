// When neither edge needs per-edge clamping, enabling the public option must
// not alter the rendered shape.

#import "/src/lib.typ": squircle
#import "/tests/_helpers/helpers.typ": case-grid
#import "cases.typ": cases

#case-grid(
  squircle.with(per-edge-smoothing: true),
  cases.map(case => case.args),
)
