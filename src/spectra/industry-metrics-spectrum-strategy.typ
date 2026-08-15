// Standalone spectrum-strategy page.
//
// Intended location:
//   src/spectra/industry-metrics-spectrum-strategy.typ
//
// Purpose:
//   Move from understanding DER mathematically to understanding how spectrum,
//   intensity, and time work together across biological day, evening, and night.

#import "components.typ": *
#import "spectrum.typ": *

// =============================================================================
// Page-local helpers
// =============================================================================

#let strategy-state(
  kicker,
  title,
  subtitle,
  values,
  stroke,
  accent,
  der,
  body,
) = block(
  width: 100%,
  inset: (x: 8pt, y: 7pt),
  radius: 4pt,
  fill: white,
  stroke: accent + 0.65pt,
  breakable: false,
)[
  #label(kicker, fill: accent)

  #v(3pt)

  #text(
    size: 14pt,
    weight: "semibold",
    fill: ink,
  )[
    #title
  ]

  #v(2pt)

  #text(
    size: 6.6pt,
    weight: "semibold",
    fill: accent,
  )[
    #subtitle
  ]

  #v(6pt)

  #spectrum-plot(
    wl,
    height: 2.65cm,
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

  #v(5pt)

  #grid(
    columns: (auto, 1fr),
    column-gutter: 7pt,
    align: horizon,

    [
      #text(
        size: 11pt,
        weight: "semibold",
        fill: accent,
      )[
        DER #der
      ]
    ],

    [
      #note(
        body,
        size: 6.7pt,
      )
    ],
  )
]


#let lever-card(
  kicker,
  title,
  body,
  accent: blackish,
) = block(
  width: 100%,
  inset: (x: 8pt, y: 6pt),
  radius: 4pt,
  fill: faint,
  stroke: hair + 0.55pt,
  breakable: false,
)[
  #label(kicker, fill: accent)

  #v(3pt)

  #text(
    size: 12pt,
    weight: "semibold",
    fill: ink,
  )[
    #title
  ]

  #v(4pt)

  #note(
    body,
    size: 6.8pt,
  )
]


#let equation-example(
  photopic,
  der,
  edi,
  accent: violet,
) = block(
  width: 100%,
  inset: (x: 7pt, y: 6pt),
  radius: 3pt,
  fill: faint,
  stroke: accent + 0.55pt,
  breakable: false,
)[
  #grid(
    columns: (1fr, auto, 1fr, auto, 1fr),
    column-gutter: 6pt,
    align: horizon,

    [
      #align(center)[
        #text(
          size: 10pt,
          weight: "semibold",
          fill: ink,
        )[
          #photopic lx
        ]
      ]
    ],

    [
      #text(
        size: 10pt,
        fill: mute,
      )[
        ×
      ]
    ],

    [
      #align(center)[
        #text(
          size: 10pt,
          weight: "semibold",
          fill: accent,
        )[
          DER #der
        ]
      ]
    ],

    [
      #text(
        size: 10pt,
        fill: mute,
      )[
        =
      ]
    ],

    [
      #align(center)[
        #text(
          size: 10pt,
          weight: "semibold",
          fill: ink,
        )[
          #edi lx EDI
        ]
      ]
    ],
  )
]


// =============================================================================
// Page
// =============================================================================

#page-kicker(
  [spectrum strategy],
  accent: violet,
)

#v(5pt)

#grid(
  columns: (0.41fr, 0.59fr),
  column-gutter: 14pt,
  align: top,

  [
    #headline(
      size: 27pt,
    )[
      The target is not one perfect spectrum.
    ]
  ],

  [
    #lede(
      size: 10.4pt,
    )[
      A circadian lighting system should change its spectral engine as the
      biological objective changes. Day calls for a strong melanopic signal;
      evening calls for withdrawal; biological night calls for protection.
    ]
  ],
)

#v(10pt)

#line(
  length: 100%,
  stroke: hair + 0.65pt,
)

#v(9pt)


// =============================================================================
// Three-state strategy
// =============================================================================

#page-kicker(
  [three spectral states],
  accent: blackish,
)

#v(6pt)

#grid(
  columns: (1fr, auto, 1fr, auto, 1fr),
  column-gutter: 8pt,
  align: top,

  [
    #strategy-state(
      [biological day],
      [Broad white],
      [build the daytime signal],
      day-state,
      1.0pt + blue,
      blue,
      [high],
      [
        Use melanopically efficient light when the clock needs a strong
        daytime anchor.
      ],
    )
  ],

  [
    #align(horizon)[
      #text(
        size: 18pt,
        fill: mute,
      )[
        →
      ]
    ]
  ],

  [
    #strategy-state(
      [biological evening],
      [Reduced-blue white],
      [taper the signal],
      evening-state,
      1.0pt + amber,
      amber,
      [moderate],
      [
        Shift visual work toward longer wavelengths while reducing
        melanopic efficiency.
      ],
    )
  ],

  [
    #align(horizon)[
      #text(
        size: 18pt,
        fill: mute,
      )[
        →
      ]
    ]
  ],

  [
    #strategy-state(
      [biological night],
      [Low-blue layer],
      [protect biological darkness],
      night-state,
      1.0pt + red,
      red,
      [low],
      [
        Keep both melanopic efficiency and total output tightly constrained.
      ],
    )
  ],
)

#v(8pt)

#note(
  size: 6.8pt,
  fill: mute,
)[
  The spectra above are illustrative control states rather than product
  specifications. Actual DER depends on the emitted spectral power distribution.
]

#v(10pt)

#line(
  length: 100%,
  stroke: hair + 0.65pt,
)

#v(9pt)


// =============================================================================
// Spectrum is not intensity
// =============================================================================

#grid(
  columns: (0.35fr, 0.65fr),
  column-gutter: 14pt,
  align: top,

  [
    #label(
      [important distinction],
      fill: violet,
    )

    #v(3pt)

    #text(
      size: 16pt,
      weight: "semibold",
      fill: ink,
    )[
      Low DER is not the same as low exposure.
    ]

    #v(4pt)

    #note(
      size: 7.1pt,
      fill: soft,
    )[
      DER changes the conversion between visible light and melanopic signal.
      Illuminance still determines how much light is actually delivered.
    ]
  ],

  [
    #grid(
      columns: (1fr, 1fr),
      column-gutter: 8pt,
      align: top,

      [
        #equation-example(
          [20],
          [1.0],
          [20],
          accent: blue,
        )

        #v(4pt)

        #note(
          size: 6.6pt,
          fill: mute,
        )[
          High-DER light can still produce modest melanopic exposure
          when the illuminance is low.
        ]
      ],

      [
        #equation-example(
          [50],
          [0.2],
          [10],
          accent: amber,
        )

        #v(4pt)

        #note(
          size: 6.6pt,
          fill: mute,
        )[
          Lower DER permits more visible light for the same melanopic
          budget, but it does not make high output biologically irrelevant.
        ]
      ],
    )
  ],
)

#v(10pt)

#line(
  length: 100%,
  stroke: hair + 0.65pt,
)

#v(9pt)


// =============================================================================
// Three control levers
// =============================================================================

#page-kicker(
  [three control levers],
  accent: red,
)

#v(6pt)

#grid(
  columns: (1fr, 1fr, 1fr),
  column-gutter: 8pt,
  align: top,

  [
    #lever-card(
      [spectrum],
      [DER],
      [
        Which wavelengths are present, and how efficiently does the spectrum
        generate melanopic stimulus per unit of visual light?
      ],
      accent: violet,
    )
  ],

  [
    #lever-card(
      [intensity],
      [Photopic illuminance],
      [
        How much visible light reaches the eye? DER only becomes exposure
        when it is multiplied by actual illuminance.
      ],
      accent: blue,
    )
  ],

  [
    #lever-card(
      [time],
      [Schedule],
      [
        When is the signal delivered? The same melanopic exposure can be
        appropriate during biological day and disruptive near sleep.
      ],
      accent: red,
    )
  ],
)

// #v(9pt)

// #align(center)[
//   #block(
//     width: 76%,
//   )[
//     #align(center)[
//       #label(
//         [the design problem],
//         fill: violet,
//       )
//     ]

//     #v(4pt)

//     #align(center)[
//       #text(
//         size: 14pt,
//         weight: "semibold",
//         fill: ink,
//       )[
//         Spectrum × intensity × time
//       ]
//     ]

//     #v(4pt)

//     #align(center)[
//       #note(
//         size: 7.4pt,
//         fill: soft,
//       )[
//         Circadian lighting is not a search for the healthiest bulb.
//         It is coordinated control of spectral efficiency, delivered
//         illuminance, and timing.
//       ]
//     ]
//   ]
// ]

// #v(9pt)

// #bottom-takeaway(
//   [design rule],
//   [
//     Use higher-DER broad light to build biological day, progressively reduce
//     melanopic efficiency toward evening, and reserve very low-DER sources for
//     the biological-night layer. In every state, control intensity as carefully
//     as spectrum.
//   ],
//   accent: violet,
// )