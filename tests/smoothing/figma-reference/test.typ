/// [max-deviations: 2]
///
/// Rendered exported-API parity with the independent figma-squircle reference
/// implementation. These cases cover both ordinary smoothing and the
/// constrained `preserve-smoothing` branch that has no `rect` equivalent.
///
/// The SVG arc renderer differs from Typst's cubic arc approximation by two
/// antialiased pixels at 144 ppi; the allowance is the measured baseline.

#import "/src/lib.typ": squircle
#import "/tests/_helpers/helpers.typ": case-grid
#import "cases.typ": cases

#case-grid(squircle, cases.map(case => case.args))
