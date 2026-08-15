// Fragment: source comparison matrix.
//
// Compares common white-light engines at equal visual output and shows
// how their melanopic-weighted output differs despite similar apparent
// brightness.

#import "components.typ": *
#import "spectrum.typ": *

#let compact-source(src, value) = block(
  width: 100%,
  inset: (x: 5pt, y: 4.5pt),
  radius: 3pt,
  fill: white,
  stroke: hair + 0.55pt,
  breakable: false,
)[
  #label(src.name, fill: src.accent)
  #v(2pt)
  #spectrum-plot(
    wl,
    height: 1.85cm,
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
  #v(3pt)
  #metric-pill(value, melanopic-der-max, fill: violet)
  #v(2pt)
  #note(src.note, size: 5.9pt, fill: mute)
]

// =============================================================================
// Source comparison matrix
// =============================================================================

#grid(
  columns: (0.28fr, 0.72fr),
  column-gutter: 12pt,
  align: top,

  [
    #section-intro(
      [source comparison],
      [White light has different engines.],
      [Common sources that all appear white do not feed the visual and melanopic readers the same way.],
      accent: violet,
      title-size: 25pt,
    )

    #v(7pt)

    #callout-card(
      [reading the number],
      [Melanopic efficiency relative to daylight.],
      [Each modeled source is evaluated by melanopic DER: melanopic response per unit of photopic illumination, referenced to D65 daylight, which has a DER of 1.0. The values are illustrative because the source spectra are representative models rather than measured product spectra.],
      accent: violet,
      fill: faint,
    )

    #v(7pt)

    #reference-overlay-key()

    #v(8pt)

    #callout-card(
      [design consequence],
      [The same visual target can be reached by different spectral engines.],
      [Future interior lighting should specify which engine is active in each scene: broad alerting white by day, warm reduced-blue white in the evening, and narrow long-wavelength light only when biological night must be protected.],
      accent: red,
    )
  ],

  [
    #grid(
      columns: (1fr, 1fr, 1fr),
      column-gutter: 6pt,
      row-gutter: 6pt,
      align: top,

      [
        #compact-source(
          source-defs.at(0),
          melanopic-der-values.at(0),
        )
      ],

      [
        #compact-source(
          source-defs.at(1),
          melanopic-der-values.at(1),
        )
      ],

      [
        #compact-source(
          source-defs.at(2),
          melanopic-der-values.at(2),
        )
      ],

      [
        #compact-source(
          source-defs.at(3),
          melanopic-der-values.at(3),
        )
      ],

      [
        #compact-source(
          source-defs.at(4),
          melanopic-der-values.at(4),
        )
      ],

      [
        #compact-source(
          source-defs.at(5),
          melanopic-der-values.at(5),
        )
      ],

      [
        #compact-source(
          source-defs.at(6),
          melanopic-der-values.at(6),
        )
      ],

      [
        #compact-source(
          source-defs.at(7),
          melanopic-der-values.at(7),
        )
      ],

      [
        #compact-source(
          source-defs.at(8),
          melanopic-der-values.at(8),
        )
      ],

      [
        #compact-source(
          source-defs.at(9),
          melanopic-der-values.at(9),
        )
      ],

      [
        #compact-source(
          source-defs.at(10),
          melanopic-der-values.at(10),
        )
      ]
    )
  ],
)
