// Standalone page: reading a light source.
//
// Intended location:
//   src/spectra/industry-metrics-source-reading.typ
//
// Purpose:
//   Give the reader a compact method for evaluating a lamp or luminaire:
//   spectrum → DER → illuminance → EDI → timing.

#import "components.typ": *
#import "spectrum.typ": *

// =============================================================================
// Page-local helpers
// =============================================================================

#let reading-step(
  number,
  kicker,
  title,
  body,
  accent: blackish,
) = block(
  width: 100%,
  inset: (x: 7pt, y: 5.5pt),
  radius: 3pt,
  fill: white,
  stroke: hair + 0.55pt,
  breakable: false,
)[
  #grid(
    columns: (20pt, 1fr),
    column-gutter: 7pt,
    align: top,

    [
      #box(
        width: 19pt,
        height: 19pt,
        radius: 50%,
        fill: faint,
        stroke: accent + 0.65pt,
      )[
        #align(center + horizon)[
          #text(
            size: 7.4pt,
            weight: "bold",
            fill: accent,
          )[
            #number
          ]
        ]
      ]
    ],

    [
      #label(kicker, fill: accent)

      #v(1.5pt)

      #text(
        size: 10.4pt,
        weight: "semibold",
        fill: ink,
      )[
        #title
      ]

      #v(2pt)

      #note(
        body,
        size: 6.45pt,
      )
    ],
  )
]


#let shortcut-card(
  title,
  verdict,
  body,
  accent: amber,
) = block(
  width: 100%,
  inset: (x: 6pt, y: 5pt),
  radius: 3pt,
  fill: faint,
  stroke: hair + 0.5pt,
  breakable: false,
)[
  #grid(
    columns: (0.30fr, 0.70fr),
    column-gutter: 6pt,
    align: top,

    [
      #text(
        size: 9pt,
        weight: "semibold",
        fill: accent,
      )[
        #title
      ]

      #v(2pt)

      #label(
        verdict,
        fill: mute,
      )
    ],

    [
      #note(
        body,
        size: 6.35pt,
      )
    ],
  )
]


#let metric-chain(
  kicker,
  value,
  body,
  accent: blackish,
) = block(
  width: 100%,
  inset: (x: 6pt, y: 5pt),
  radius: 3pt,
  fill: white,
  stroke: accent + 0.55pt,
  breakable: false,
)[
  #label(kicker, fill: accent)

  #v(2pt)

  #text(
    size: 11pt,
    weight: "semibold",
    fill: ink,
  )[
    #value
  ]

  #v(2pt)

  #note(
    body,
    size: 6.25pt,
  )
]


// =============================================================================
// Header
// =============================================================================

#page-kicker(
  [reading a light source],
  accent: violet,
)

#v(5pt)

#grid(
  columns: (0.42fr, 0.58fr),
  column-gutter: 14pt,
  align: top,

  [
    #headline(
      size: 27pt,
    )[
      Read the spectrum, not just the label.
    ]
  ],

  [
    #lede(
      size: 10.2pt,
    )[
      A lamp can look warm, score well on color rendering, and still deliver
      substantial melanopic stimulus. Read a source in sequence: spectrum,
      melanopic DER, illuminance at the eye, then time of use.
    ]
  ],
)

#v(8pt)

#line(
  length: 100%,
  stroke: hair + 0.65pt,
)

#v(7pt)


// =============================================================================
// Main visual + reading sequence
// =============================================================================

#grid(
  columns: (0.46fr, 0.54fr),
  column-gutter: 11pt,
  align: top,

  [
    #label(
      [start with the spectrum],
      fill: violet,
    )

    #v(3pt)

    #text(
      size: 14pt,
      weight: "semibold",
      fill: ink,
    )[
      The shape contains information the package cannot.
    ]

    #v(4pt)

    #spectrum-plot(
      wl,
      height: 4.1cm,
      legend-position: "none",
      xlabel: text(size: 5.1pt)[Wavelength / nm],
      ylabel: text(size: 5.1pt)[Relative power],
      series: with-reference-overlays(((
        label: [],
        values: cheap-blue-led,
        stroke: 1.0pt + blue,
        draw-area: true,
        z: 2,
      ),)),
    )

    #v(4pt)

    #note(
      size: 6.55pt,
      fill: soft,
    )[
      Example: a conventional blue-pump white LED. The visible appearance
      collapses this spectrum into a single impression of “white,” while the
      spectral plot exposes the short-wavelength pump and broad phosphor output.
    ]
  ],

  [
    #grid(
      columns: (1fr, 1fr),
      column-gutter: 6pt,
      row-gutter: 6pt,
      align: top,

      [
        #reading-step(
          [1],
          [spectrum],
          [What wavelengths are emitted?],
          [
            Look for the spectral power distribution. Similar-looking whites
            can distribute their energy very differently across the visible range.
          ],
          accent: violet,
        )
      ],

      [
        #reading-step(
          [2],
          [melanopic DER],
          [How efficient is the spectrum?],
          [
            DER expresses melanopic response per unit of photopic illumination
            relative to D65 daylight, whose DER is 1.
          ],
          accent: amber,
        )
      ],

      [
        #reading-step(
          [3],
          [illuminance],
          [How much reaches the eye?],
          [
            Measure or model vertical photopic illuminance at the observer.
            Spectrum alone does not determine delivered exposure.
          ],
          accent: blue,
        )
      ],

      [
        #reading-step(
          [4],
          [time],
          [When is the signal delivered?],
          [
            High melanopic exposure may support biological day while the same
            exposure near bedtime may oppose the intended transition to night.
          ],
          accent: red,
        )
      ],
    )

    #v(6pt)

    #callout-card(
      [working sequence],
      [Spectrum → DER → illuminance → EDI → time],
      [
        DER converts the spectral question into a useful ratio.
        Photopic illuminance determines how much of that spectral engine reaches
        the eye. Their combination gives melanopic EDI; timing determines how
        that exposure should be interpreted.
      ],
      accent: violet,
      fill: faint,
      inset-y: 6pt,
    )
  ],
)

#v(8pt)

#line(
  length: 100%,
  stroke: hair + 0.65pt,
)

#v(7pt)


// =============================================================================
// The metric chain
// =============================================================================

#grid(
  columns: (0.25fr, 0.75fr),
  column-gutter: 11pt,
  align: top,

  [
    #label(
      [from source to exposure],
      fill: blue,
    )

    #v(3pt)

    #text(
      size: 14pt,
      weight: "semibold",
      fill: ink,
    )[
      Keep the quantities separate.
    ]

    #v(3pt)

    #note(
      size: 6.75pt,
      fill: soft,
    )[
      Each quantity answers a different question. Confusion starts when one
      is used as a substitute for another.
    ]
  ],

  [
    #grid(
      columns: (1fr, auto, 1fr, auto, 1fr),
      column-gutter: 5pt,
      align: horizon,

      [
        #metric-chain(
          [spectrum],
          [SPD],
          [Which wavelengths does the source emit?],
          accent: violet,
        )
      ],

      [
        #text(
          size: 13pt,
          fill: mute,
        )[→]
      ],

      [
        #metric-chain(
          [efficiency],
          [DER],
          [How strongly does that spectrum drive melanopic response per visual lux?],
          accent: amber,
        )
      ],

      [
        #text(
          size: 13pt,
          fill: mute,
        )[→]
      ],

      [
        #metric-chain(
          [exposure],
          [EDI],
          [How much melanopic signal actually reaches the observer?],
          accent: blue,
        )
      ],
    )
  ],
)

#v(8pt)


// =============================================================================
// Conventional specifications
// =============================================================================

#grid(
  columns: (0.25fr, 0.75fr),
  column-gutter: 11pt,
  align: top,

  [
    #label(
      [common shortcuts],
      fill: amber,
    )

    #v(3pt)

    #text(
      size: 14pt,
      weight: "semibold",
      fill: ink,
    )[
      Useful specifications, different questions.
    ]

    #v(3pt)

    #note(
      size: 6.7pt,
      fill: soft,
    )[
      These values matter. They simply do not replace spectral or melanopic
      measurements.
    ]
  ],

  [
    #grid(
      columns: (1fr, 1fr),
      column-gutter: 6pt,
      row-gutter: 6pt,
      align: top,

      [
        #shortcut-card(
          [CCT],
          [appearance],
          [
            Describes chromaticity and the warm–cool appearance of white light.
            It does not uniquely determine the spectral power distribution.
          ],
          accent: amber,
        )
      ],

      [
        #shortcut-card(
          [CRI],
          [color],
          [
            Describes aspects of color rendering. A high CRI value does not by
            itself establish high or low melanopic efficiency.
          ],
          accent: violet,
        )
      ],

      [
        #shortcut-card(
          [lumens],
          [visual output],
          [
            Describe photopically weighted luminous output, not the melanopic
            composition of that output.
          ],
          accent: blue,
        )
      ],

      [
        #shortcut-card(
          [wattage],
          [electrical input],
          [
            Describes power consumption. It says little about either spectral
            distribution or retinal exposure.
          ],
          accent: blackish,
        )
      ],
    )
  ],
)

#v(8pt)

#line(
  length: 100%,
  stroke: hair + 0.65pt,
)

#v(7pt)


// =============================================================================
// Final interpretation
// =============================================================================

#grid(
  columns: (0.34fr, 0.66fr),
  column-gutter: 12pt,
  align: horizon,

  [
    #label(
      [the useful question],
      fill: violet,
    )

    #v(3pt)

    #text(
      size: 14pt,
      weight: "semibold",
      fill: ink,
    )[
      What signal reaches the eye, and when?
    ]
  ],

  [
    #note(
      size: 7.15pt,
      fill: soft,
    )[
      Do not reduce a source to “warm,” “cool,” “healthy,” or “circadian.”
      Read its spectrum, use melanopic DER to understand its spectral efficiency,
      combine that with illuminance to determine melanopic EDI, and interpret
      the result within the biological schedule.
    ]
  ],
)

// #v(7pt)

// #bottom-takeaway(
//   [selection rule],
//   [
//     Conventional specifications describe the visual and electrical qualities
//     of a source. Melanopic DER describes its spectral biological efficiency.
//     Melanopic EDI describes the signal delivered at the eye. Good lighting
//     design needs all three layers rather than a single preferred lamp label.
//   ],
//   accent: violet,
// )
