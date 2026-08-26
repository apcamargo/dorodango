// Checked-in source-level oracles rendered in the same grid as test.typ.

#import "/tests/_helpers/helpers.typ": case-grid
#import "cases.typ": cases

#let fixture(id: "", width: 0pt, height: 0pt) = image(
  "fixtures/" + id + ".svg",
  width: width,
  height: height,
)

#case-grid(fixture, cases.map(case => case.reference))
