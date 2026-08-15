// Fragment: lower end / night products.
//
// Defines the biological-night lighting layer: spectrally constrained,
// low-blue sources for orientation and minimal nighttime tasks.

#import "components.typ": *
#import "spectrum.typ": *

#let night-source-feature(src, value) = block(
  width: 100%,
  inset: (x: 8pt, y: 7pt),
  radius: 4pt,
  fill: white,
  stroke: hair + 0.55pt,
  breakable: false,
)[
  #grid(
    columns: (0.26fr, 0.74fr),
    column-gutter: 10pt,
    align: top,
    [
      #label(src.name, fill: src.accent)
      #v(3pt)
      #note(src.note, size: 6.8pt, fill: mute)
      #v(6pt)
      #label[melanopic DER, fill: violet]
      #v(4pt)
      #metric-pill(value, melanopic-der-max, fill: violet)
      #v(5pt)
      #note(src.detail, size: 6.85pt)
    ],
    [
      #spectrum-plot(
        wl,
        height: 4.15cm,
        legend-position: "none",
        xlabel: text(size: 5.2pt)[Wavelength / nm],
        ylabel: text(size: 5.2pt)[Relative power],
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
]


// =============================================================================
// Lower end / night products
// =============================================================================

#grid(
  columns: (0.38fr, 0.62fr),
  column-gutter: 13pt,
  align: top,

  [
    #section-intro(
      [night products],
      [Low-blue lamps are a night layer, not a mood.],
      [The night layer should not depend on ordinary warm-white lamps dimmed low. It needs fixtures whose emitted light is spectrally constrained before it enters the room.],
      accent: red,
      title-size: 27pt,
    )
  ],

  [
    #callout-card(
      [lower end],
      [The lower end matters more at night.],
      [The argument is not that every nighttime interior should become red. It is that nighttime scenes need sources whose emitted light avoids the blue-cyan band most strongly read by the circadian system.],
      accent: violet,
      fill: faint,
      inset-y: 8pt,
    )
  ],
)

#v(8pt)

#grid(
  columns: (1fr, 1fr),
  column-gutter: 9pt,
  align: top,

  [
    #night-source-feature(
      source-defs.at(9),
      melanopic-der-values.at(9),
    )
  ],

  [
    #night-source-feature(
      source-defs.at(10),
      melanopic-der-values.at(10),
    )
  ],
)

#v(8pt)

#grid(
  columns: (1fr, 1fr, 1fr, 1fr),
  column-gutter: 7pt,
  align: top,

  [
    #spec-panel(
      [blue-blocking lamp],
      [The source does the filtering.],
      [A blue-blocking lamp is not eyewear, software, or a habit correction. It is a fixture, bulb, tape channel, or path light whose emitted spectrum removes the blue-cyan band that overlaps the melanopic reader.],
      accent: amber,
    )
  ],

  [
    #spec-panel(
      [not warm-white],
      [Warm appearance is not enough.],
      [A 2200–2700 K lamp can still be a phosphor LED with a blue pump hidden under an amber-looking output. “Warm,” “cozy,” and “soft white” are visual descriptions; low-blue is a spectral requirement.],
      accent: blue,
    )
  ],

  [
    #spec-panel(
      [where it belongs],
      [Use it in the late-night circulation layer.],
      [The best applications are bedrooms, bathrooms, nurseries, corridors, stair paths, toe-kick lighting, bedside lamps, closet edges, and kitchen night paths: small-area, low-output orientation light.],
      accent: red,
    )
  ],

  [
    #spec-panel(
      [product warning],
      [Low-blue does not authorize high output.],
      [A blue-blocking lamp reduces melanopic efficiency; it does not make unlimited light harmless. The target is enough light to move safely without restarting the day signal.],
      accent: violet,
    )
  ],
)

#v(7pt)

#bottom-takeaway(
  [product translation],
  [For interior lighting, blue blocking means source-side spectral control: lamps and luminaires that avoid the blue-cyan band during biological night. Treat them as a layer below ordinary warm-white lighting — not as daytime white, not as decorative amber ambience, and not as permission to brighten the night.],
  accent: violet,
)
