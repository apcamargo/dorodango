/// [max-deviations: 45]
///
/// Rendered public-API comparisons for per-edge smoothing. The reference SVGs
/// come from pinned external packages where their semantics match Dorodango,
/// and otherwise from the independent specification renderer.
///
/// The pill's surviving 90-degree SVG arcs differ from Typst's cubic arc
/// approximation by 45 antialiased pixels at 144 ppi; the allowance is the
/// measured exact-comparison baseline for this page.

#import "/src/lib.typ": squircle
#import "/tests/_helpers/helpers.typ": case-grid
#import "cases.typ": cases

#case-grid(squircle, cases.map(case => case.args))
