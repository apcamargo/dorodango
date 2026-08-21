/// [ppi: 720]
///
/// Adjacent solid sides with the same paint form one continuous filled ring,
/// even when their thicknesses differ. The elevated resolution makes a bare
/// paint's 1pt default-thickness regression and a false seam observable.

#import "/src/lib.typ": squircle
#import "/tests/_helpers/helpers.typ": case-grid
#import "/tests/_helpers/cases.typ": stroke-joins

#case-grid(squircle.with(smoothing: 0%), stroke-joins, columns: 3)
