/// Rendered parity for corner dictionaries. These cases check the `Corners`
/// precedence rules all the way to the drawn shape, including the clamping
/// that happens when neighbouring corners fight over one side.

#import "/tests/_helpers/cases.typ": radius-dict
#import "/tests/_helpers/helpers.typ": case-grid
#import "/src/lib.typ": squircle

#case-grid(squircle.with(smoothing: 0%), radius-dict, columns: 4)
