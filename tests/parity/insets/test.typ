/// Rendered parity for `inset`, including the ratio insets that make the box
/// size a fixed point, and bodies that wrap.

#import "/tests/_helpers/cases.typ": insets
#import "/tests/_helpers/helpers.typ": case-grid
#import "/src/lib.typ": squircle

#case-grid(squircle.with(smoothing: 0%), insets, columns: 3)
