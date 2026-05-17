#let table-label(body) = [
  #text(size: 8pt, weight: "bold", fill: rgb("#66666d"))[
    #body
  ]
]

#let table-body(body, size: 9pt) = [
  #set text(size: size)
  #body
]

#let argument-table(
  columns: (0.34fr, 1fr),
  inset: (x: 8pt, y: 7pt),
  header-rule: rgb("#d8d8e2") + 0.8pt,
  row-rule: rgb("#eeeeF4") + 0.6pt,
  ..cells,
) = table(
  columns: columns,
  inset: inset,
  stroke: none,
  align: top,
  ..cells.pos(),
)

#let table-rule(stroke: rgb("#eeeeF4") + 0.6pt) = table.hline(
  stroke: stroke,
)

#let table-strong-rule() = table.hline(
  stroke: rgb("#d8d8e2") + 0.8pt,
)

