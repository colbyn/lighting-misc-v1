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
  #metric-pill(value, overlap-max, fill: violet)
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
      [Equal visual output first.],
      [Each source is normalized to equal photopic visual output, then weighted against melanopic sensitivity — the same logic as the industry's melanopic ratio (MDER), from CIE S 026/E:2018. Here it's an illustrative approximation on an arbitrary scale, not a certified measurement.],
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
          overlap-values.at(0),
        )
      ],

      [
        #compact-source(
          source-defs.at(1),
          overlap-values.at(1),
        )
      ],

      [
        #compact-source(
          source-defs.at(2),
          overlap-values.at(2),
        )
      ],

      [
        #compact-source(
          source-defs.at(3),
          overlap-values.at(3),
        )
      ],

      [
        #compact-source(
          source-defs.at(4),
          overlap-values.at(4),
        )
      ],

      [
        #compact-source(
          source-defs.at(5),
          overlap-values.at(5),
        )
      ],

      [
        #compact-source(
          source-defs.at(6),
          overlap-values.at(6),
        )
      ],

      [
        #compact-source(
          source-defs.at(7),
          overlap-values.at(7),
        )
      ],

      [
        #compact-source(
          source-defs.at(8),
          overlap-values.at(8),
        )
      ],

      [
        #compact-source(
          source-defs.at(9),
          overlap-values.at(9),
        )
      ],

      [
        #compact-source(
          source-defs.at(10),
          overlap-values.at(10),
        )
      ],

      [
        #callout-card(
          [matrix reading],
          [Lower is not automatically better. Later is different.],
          [Daytime needs alerting light. Evening needs a taper. Biological night needs protection. The matrix is not a universal ranking; it is a schedule argument.],
          accent: blue,
          fill: faint,
        )
      ],
    )
  ],
)
