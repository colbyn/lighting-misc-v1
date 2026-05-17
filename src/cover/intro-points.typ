#import "@preview/octique:0.1.1": octique

// -----------------------------------------------------------------------------
// Lighting notes points block.
// Icon + label + detail grid.
// -----------------------------------------------------------------------------


// ---- Colors ----

#let primary-color-text = rgb("#444446")
#let primary-color-text-lighter = rgb("#68686f")
#let primary-color-border = rgb("#acacb5")
// #let primary-color-soft = rgb("#f7f7f8")

// ---- Theme ------------------------------------------------------------------

#let font-label = "Avenir Next"
#let font-title = "Bodoni 72 Smallcaps"
#let font-title-normal = "Bodoni 72"
#let font-heading = "Hoefler Text"
#let font-subtitle = "Avenir Next"
#let font-body = "Avenir Next"
#let font-meta = "Avenir Next"

#let points-primary = rgb("#ff009d")
#let points-muted = rgb("#66666d")

// ---- Components -------------------------------------------------------------

#let point-item(entry) = {
  let color = entry.at("color", default: points-primary)
  let icon = entry.at("icon", default: "light-bulb")
  let title = entry.at("title", default: [])
  let detail = entry.at("detail", default: none)

  let icon-col-width = 18pt
  let icon-size = 14pt
  let text-pad-y = 10pt
  let title-row-height = 23pt

  let gutter-spacing = 5pt
  let stroke-width = 0.25pt

  box(
    width: 100%,
    stroke: stroke-width + color,
    inset: (
      left: gutter-spacing,
      right: 0pt,
      top: 0pt,
      bottom: 0pt,
    ),
  )[
    #set par(justify: true)

    #grid(
      columns: (icon-col-width, 1fr),
      column-gutter: gutter-spacing,
      align: top,

      // Icon column.
      box(
        width: icon-col-width,
        inset: (top: text-pad-y),
      )[
        #box(
          width: icon-col-width,
          height: title-row-height,
        )[
          #align(center + horizon)[
            #octique(
              icon,
              color: color,
              width: icon-size,
              height: icon-size,
            )
          ]
        ]
      ],

      // Text group.
      box(
        width: 100%,
        stroke: (left: stroke-width + color),
        inset: (
          left: gutter-spacing,
          right: text-pad-y,
          top: text-pad-y,
          bottom: text-pad-y,
        ),
      )[
        #stack(
          spacing: 4pt,

          box(height: title-row-height)[
            #align(left + horizon)[
              #text(
                size: 16pt,
                font: font-label,
                weight: 300,
                fill: color,
              )[#title]
            ]
          ],

          if detail != none [
            #text(
              size: 11pt,
              weight: 300,
              font: font-label,
              fill: points-muted,
            )[#detail]
          ],
        )
      ],
    )
  ]
}

#let points-grid(
  columns: 2,
  column-gutter: 18pt,
  row-gutter: 14pt,
  ..items,
) = {
  let entries = items.pos()
  let cols = ()

  for _ in range(columns) {
    cols.push(1fr)
  }

  let cells = ()

  for entry in entries {
    cells.push(point-item(entry))
  }

  block(width: 100%)[
    #grid(
      columns: cols,
      column-gutter: column-gutter,
      row-gutter: row-gutter,
      ..cells,
    )
  ]
}

// ---- Content ----------------------------------------------------------------

#let intro-lighting-points() = block(width: 100%)[
  #text(
    size: 18pt,
    weight: 400,
    font: font-title-normal,
    fill: primary-color-text,
  )[Topics Include]
  #points-grid(
    columns: 2,

    (
      icon: "zap",
      title: [DC-Native Power],
      detail: [Distribute 48 V DC instead of making every luminaire pretend to be an AC lamp.],
      color: rgb("#00a6a6"),
    ),

    (
      icon: "shield-check",
      title: [Limited Energy Domain],
      detail: [Keep downstream wiring in a practical Class 2/3-style low-voltage domain.],
      color: rgb("#7a5cff"),
    ),

    (
      icon: "pulse",
      title: [Low-Flicker Control],
      detail: [Favor measured constant-current dimming over vague driver claims.],
      color: rgb("#ff009d"),
    ),

    (
      icon: "sun",
      title: [Circadian Metrics],
      detail: [Use melanopic EDI, eye-level light, and measured SPD—not CCT alone.],
      color: rgb("#d88700"),
    ),

    (
      icon: "broadcast",
      title: [Addressable Control],
      detail: [Coordinate scenes, schedules, groups, feedback, and overrides digitally.],
      color: rgb("#0077cc"),
    ),

    (
      icon: "stack",
      title: [Modular Luminaires],
      detail: [Separate source, driver, optics, heat, controls, and wiring layers.],
      color: rgb("#4f8f00"),
    ),

    (
      icon: "telescope",
      title: [Measured Design],
      detail: [Verify SPD, flicker, illuminance, and thermal behavior—not just labels.],
      color: rgb("#c44500"),
    ),

    (
      icon: "tools",
      title: [Serviceable System],
      detail: [Make drivers, controls, wiring, and emitters easy to maintain and upgrade.],
      color: rgb("#5f6f7a"),
    ),
  )
]

