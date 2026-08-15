// ————————————————————————————————————————————————————————————————————————————
// LAYOUT
// ————————————————————————————————————————————————————————————————————————————

#let page-margin = (
  x: 10mm,
  y: 8mm,
)

#let bleed-x(
  fill: none,
  inset: 0pt,
  body,
) = {
  move(
    dx: -page-margin.x,
    block(
      width: 100% + page-margin.x * 2,
      fill: fill,
      inset: inset,
      body,
    )
  )
}

#let bleed-top(
  height,
  fill: none,
  inset: 0pt,
  body,
) = {
  move(
    dx: -page-margin.x,
    dy: -page-margin.y,
    block(
      width: 100% + page-margin.x * 2,
      height: height + page-margin.y,
      fill: fill,
      inset: inset,
      body,
    )
  )
}

// ————————————————————————————————————————————————————————————————————————————
// COLORS
// ————————————————————————————————————————————————————————————————————————————

// #let electric = rgb("#2563eb")
#let ink = rgb("#10131a")
// #let line-soft = rgb("#dbe3ef")

// ————————————————————————————————————————————————————————————————————————————
// TYPE
// ————————————————————————————————————————————————————————————————————————————

#let label-font = "Avenir Next"

#set text(
  font: "Avenir Next",
  size: 8.7pt,
  fill: ink,
)

// ————————————————————————————————————————————————————————————————————————————
// SMALL DESIGN COMPONENTS
// ————————————————————————————————————————————————————————————————————————————
