/// Rendered parity for superellipse with exponent: 2 against rect.
///
/// At exponent 2 the Lamé curve is a circle, so the corner is the one `rect`
/// itself draws, segment for segment. The comparison is exact: no tolerance
/// annotation, as with the clothoid parity suites at smoothing 0%.

#import "/tests/_helpers/cases.typ": radius-scalar
#import "/tests/_helpers/helpers.typ": case-grid
#import "/src/lib.typ": superellipse

#case-grid(superellipse.with(exponent: 2), radius-scalar, columns: 4)
