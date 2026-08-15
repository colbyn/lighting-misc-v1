// Shared layout components and color tokens, used by circadian-lighting.typ
// and its fragments.
//
// Fragments import from here rather than from the parent file, since the
// parent #includes its fragments — importing back from the parent would be
// a circular import.

// =============================================================================
// Color tokens
// =============================================================================

#let ink      = rgb("#e8e9ef")
#let soft     = rgb("#b6b8c2")
#let mute     = rgb("#8b8e9a")
#let hair     = rgb("#3a3c47")
#let faint    = rgb("#1b1c22")
#let white    = rgb("#111217")


#let blue     = rgb("#5b91ff")
#let cyan     = rgb("#43c6d3")
#let green    = rgb("#79c957")
#let violet   = rgb("#a77aff")
#let amber    = rgb("#e7a54b")
#let red      = rgb("#e06b6b")
#let blackish = rgb("#f2f2f4")


// Reference curve accent colors — kept distinct from the source palette.
// These are shared because fragments use the same reference-curve vocabulary.

#let ref-day    = rgb("#91c47b")
#let ref-visual = rgb("#a4a7b1")
#let ref-clock  = rgb("#ad86ea")

// // =============================================================================
// // Color tokens
// // =============================================================================

// #let ink     = rgb("#23242a")
// #let soft    = rgb("#50525d")
// #let mute    = rgb("#777985")
// #let hair    = rgb("#ddddE8")
// #let faint   = rgb("#f6f7fb")
// #let white   = rgb("#ffffff")

// #let blue    = rgb("#005eff")
// #let cyan    = rgb("#0097a7")
// #let green   = rgb("#3a9a00")
// #let violet  = rgb("#7a3cff")
// #let amber   = rgb("#bd6a00")
// #let red     = rgb("#b03a3a")
// #let blackish = rgb("#111111")

// // Reference curve accent colors — kept distinct from the source palette.
// // These are shared because fragments use the same reference-curve vocabulary.
// #let ref-day    = rgb("#75a85f")
// #let ref-visual = rgb("#70727c")
// #let ref-clock  = rgb("#8d62d5")

// =============================================================================
// Typography
// =============================================================================

#let label(body, fill: mute) = text(
  size: 6.5pt,
  weight: "bold",
  tracking: 0.10em,
  fill: fill,
)[#upper(body)]

#let headline(body, size: 29pt) = text(
  size: size,
  weight: "medium",
  fill: ink,
)[#body]

#let lede(body, size: 13pt) = block(width: 100%)[
  #set par(leading: 0.74em)
  #text(size: size, fill: soft)[#body]
]

#let note(body, size: 8.2pt, fill: soft) = block(width: 100%)[
  #set par(leading: 0.68em)
  #text(size: size, fill: fill)[#body]
]

#let page-kicker(body, accent: mute) = block(width: 100%)[
  #grid(
    columns: (auto, 1fr),
    column-gutter: 8pt,
    align: horizon,
    [#label(body, fill: accent)],
    [#line(length: 100%, stroke: hair + 0.55pt)],
  )
]

#let section-intro(
  kicker,
  title,
  body,
  accent: blackish,
  title-size: 25pt,
) = block(width: 100%)[
  #page-kicker(kicker, accent: accent)
  #v(5pt)
  #headline(size: title-size)[#title]
  #v(5pt)
  #lede(size: 10.2pt)[#body]
]

// =============================================================================
// Basic layout
// =============================================================================

#let rule(stroke: hair + 0.6pt) = line(
  length: 100%,
  stroke: stroke,
)

#let small-rule-note(kicker, body, accent: blackish) = block(width: 100%)[
  #label(kicker, fill: accent)
  #v(3pt)
  #note(body, size: 7.2pt)
]

// =============================================================================
// Cards and callouts
// =============================================================================

#let callout-card(
  kicker,
  title,
  body,
  accent: blackish,
  fill: white,
  inset-x: 7pt,
  inset-y: 6pt,
) = block(
  width: 100%,
  inset: (x: inset-x, y: inset-y),
  radius: 3pt,
  fill: fill,
  stroke: hair + 0.55pt,
  breakable: false,
)[
  #label(kicker, fill: accent)
  #v(3pt)
  #text(size: 10.4pt, weight: "semibold", fill: ink)[#title]
  #v(3pt)
  #note(body, size: 7.15pt)
]

#let spec-panel(
  kicker,
  title,
  body,
  accent: blackish,
) = callout-card(
  kicker,
  title,
  body,
  accent: accent,
)

#let bottom-takeaway(kicker, body, accent: blackish) = block(width: 100%)[
  #v(4pt)
  #line(length: 100%, stroke: hair + 0.55pt)
  #v(5pt)
  #grid(
    columns: (0.16fr, 1fr),
    column-gutter: 8pt,
    align: top,
    [#label(kicker, fill: accent)],
    [#note(body, size: 7.45pt)],
  )
]

// =============================================================================
// Metric display
// =============================================================================

// `metric-bar` depends only on generic layout/math primitives.
// `clamp` remains in spectrum.typ because it belongs to the computational
// layer rather than the editorial component layer.

#let metric-bar(value, max-value, fill: violet) = {
  let pct = if max-value == 0 {
    0%
  } else {
    // Keep the actual normalization in the spectrum layer.
    // This component expects a normalized value in [0, 1].
    value / max-value * 100%
  }

  box(width: 100%, height: 4pt, fill: rgb("#ececf4"))[
    #box(width: pct, height: 4pt, fill: fill)[]
  ]
}

#let metric-pill(value, max-value, fill: violet) = block(width: 100%)[
  #metric-bar(value, max-value, fill: fill)
  #v(2pt)
  #grid(
    columns: (auto, 1fr),
    column-gutter: 5pt,
    align: horizon,
    [#text(
      size: 10.6pt,
      weight: "semibold",
      fill: ink,
    )[
      #("≈ " + str(calc.round(value * 100.0) / 100.0))]
    ],
    [
      #text(size: 5.8pt, fill: mute)[melanopic DER]
    ],
  )
]

// =============================================================================
// Sequence / state components
// =============================================================================

#let sequence-chip(kicker, title, body, accent: blackish) = block(
  width: 100%,
  inset: (x: 7pt, y: 6pt),
  radius: 4pt,
  fill: faint,
  stroke: accent + 0.55pt,
  breakable: false,
)[
  #label(kicker, fill: accent)
  #v(3pt)
  #text(size: 10.8pt, weight: "semibold", fill: ink)[#title]
  #v(3pt)
  #note(body, size: 6.85pt)
]

#let state-wide-card(
  kicker,
  title,
  values,
  stroke,
  accent,
  principle,
  visual-body,
  clock-body,
) = block(
  width: 100%,
  inset: (x: 7pt, y: 6pt),
  radius: 4pt,
  fill: white,
  stroke: hair + 0.55pt,
  breakable: false,
)[
  #grid(
    columns: (0.32fr, 0.68fr),
    column-gutter: 8pt,
    align: top,
    [
      #label(kicker, fill: accent)
      #v(3pt)
      #text(size: 13.5pt, weight: "semibold", fill: ink)[#title]
      #v(4pt)
      #note(principle, size: 7.0pt)
    ],
    [
      // spectrum-plot supplied by spectrum.typ
      #spectrum-plot(
        wl,
        height: 2.55cm,
        legend-position: "none",
        xlabel: text(size: 0pt)[],
        ylabel: text(size: 0pt)[],
        series: with-reference-overlays(((
          label: [],
          values: values,
          stroke: stroke,
          draw-area: true,
          z: 2,
        ),)),
      )
    ],
  )
  #v(4pt)
  #grid(
    columns: (1fr, 1fr),
    column-gutter: 7pt,
    align: top,
    [#small-rule-note([visual], visual-body, accent: ref-visual)],
    [#small-rule-note([clock], clock-body, accent: violet)],
  )
]

// #let state-row(
//   kicker,
//   title,
//   values,
//   stroke,
//   accent,
//   principle,
//   visual-body,
//   clock-body,
// ) = block(
//   width: 100%,
//   inset: (x: 8pt, y: 6pt),
//   radius: 4pt,
//   fill: white,
//   stroke: hair + 0.55pt,
//   breakable: false,
// )[
//   #grid(
//     columns: (0.20fr, 0.49fr, 0.155fr, 0.155fr),
//     column-gutter: 9pt,
//     align: top,
//     [
//       #label(kicker, fill: accent)
//       #v(3pt)
//       #text(size: 15pt, weight: "semibold", fill: ink)[#title]
//       #v(5pt)
//       #note(principle, size: 7.1pt)
//     ],
//     [
//       #spectrum-plot(
//         wl,
//         height: 3.15cm,
//         legend-position: "none",
//         xlabel: text(size: 5.2pt)[Wavelength / nm],
//         ylabel: text(size: 5.2pt)[Relative power],
//         series: with-reference-overlays(((
//           label: [],
//           values: values,
//           stroke: stroke,
//           draw-area: true,
//           z: 2,
//         ),)),
//       )
//     ],
//     [#small-rule-note([visual], visual-body, accent: ref-visual)],
//     [#small-rule-note([clock], clock-body, accent: violet)],
//   )
// ]

#let hierarchy-ribbon() = block(
  width: 100%,
  inset: (x: 8pt, y: 7pt),
  radius: 4pt,
  fill: faint,
  stroke: hair + 0.55pt,
)[
  #grid(
    columns: (1fr, auto, 1fr, auto, 1fr),
    column-gutter: 8pt,
    align: horizon,
    [
      #sequence-chip(
        [day],
        [broad white],
        [Feed the clock when the body needs a daytime anchor.],
        accent: blue,
      )
    ],
    [#text(size: 15pt, fill: mute)[→]],
    [
      #sequence-chip(
        [evening],
        [reduced-blue white],
        [Taper the signal while preserving social and task visibility.],
        accent: amber,
      )
    ],
    [#text(size: 15pt, fill: mute)[→]],
    [
      #sequence-chip(
        [night],
        [low-blue layer],
        [Use constrained long-wavelength light for safe movement only.],
        accent: red,
      )
    ],
  )
]

// =============================================================================
// Source components
// =============================================================================

// These components consume the spectral API supplied by spectrum.typ:
//   wl
//   spectrum-plot
//   with-reference-overlays
//
// They therefore belong here as layout components, while their actual
// spectral calculations remain in spectrum.typ.

#let source-card(
  src,
  value,
  plot-height: 3.2cm,
  detail-size: 6.7pt,
) = block(
  width: 100%,
  inset: (x: 6pt, y: 5pt),
  radius: 3pt,
  fill: white,
  stroke: hair + 0.55pt,
  breakable: false,
)[
  #grid(
    columns: (1fr, 0.52fr),
    column-gutter: 7pt,
    align: top,
    [
      #label(src.name, fill: src.accent)
      #v(2pt)
      #note(src.note, size: 6.2pt, fill: mute)
      #v(4pt)
      #metric-pill(value, melanopic-der-max, fill: violet)
    ],
    [
      #spectrum-plot(
        wl,
        height: plot-height,
        legend-position: "none",
        xlabel: text(size: 0pt)[],
        ylabel: text(size: 0pt)[],
        series: with-reference-overlays(((
          label: [],
          values: src.values,
          stroke: src.stroke,
          draw-area: true,
          z: 2,
        ),)),
      )
    ],
  )
  #v(3pt)
  #note(src.detail, size: detail-size)
]

