/// Rendered parity across the point where a stroke becomes too thick to be
/// stroked: once the pen is wider than twice the radius, `rect` switches to
/// filling a ring. 11.5pt / 12pt / 16pt against a 6pt radius straddle it.

#import "/tests/_helpers/cases.typ": stroke-thick
#import "/tests/_helpers/helpers.typ": case-grid
#import "/src/lib.typ": squircle

#case-grid(squircle.with(smoothing: 0%), stroke-thick, columns: 4)
