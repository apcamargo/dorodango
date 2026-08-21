/// Rendered parity for `height: 1fr`.
///
/// A fraction is resolved by the layout engine after `layout()` has already
/// reported the region, so `squircle` recovers the drawn height through a
/// nested `100%` block. Each case resolves the fraction in a different kind of
/// container, and the shape has to land exactly where `rect` does in all of
/// them.

#import "/tests/_helpers/cases.typ": fraction-layouts
#import "/tests/_helpers/helpers.typ": layout-grid
#import "/src/lib.typ": squircle

#layout-grid(squircle.with(smoothing: 0%), fraction-layouts, columns: 4)
