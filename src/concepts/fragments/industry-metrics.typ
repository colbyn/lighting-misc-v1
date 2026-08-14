// Fragment: industry metrics and implementation targets.
//
// Defines the standardized melanopic quantities used by implementers,
// translates them into practical day / evening / night targets, and then
// shows how spectrum, illuminance, and time interact.
//
// Included directly from circadian-lighting.typ.

// #import "@preview/lilaq:0.6.0" as lq
#import "components.typ": *

// =============================================================================
// Page-local helpers
// =============================================================================

#let flow-chip(title, subtitle, accent: blackish) = block(
  width: 100%,
  inset: (x: 7pt, y: 6pt),
  radius: 4pt,
  fill: faint,
  stroke: accent + 0.55pt,
  breakable: false,
)[
  #text(size: 8.6pt, weight: "semibold", fill: ink)[#title]
  #v(2pt)
  #text(size: 6.3pt, fill: mute)[#subtitle]
]

#let flow-arrow() = align(horizon)[
  #text(size: 13pt, fill: mute)[→]
]

#let target-card(
  kicker,
  target,
  timing,
  body,
  accent: blackish,
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
    size: 19pt,
    weight: "semibold",
    fill: ink,
  )[#target]

  #v(1pt)

  #text(
    size: 7.1pt,
    weight: "semibold",
    fill: accent,
  )[#timing]

  #v(5pt)
  #note(body, size: 6.8pt)
]

#let quantity-row(
  name,
  role,
  unit,
  body,
  accent: blackish,
) = block(
  width: 100%,
  inset: (x: 7pt, y: 5pt),
  radius: 3pt,
  fill: white,
  stroke: hair + 0.55pt,
  breakable: false,
)[
  #grid(
    columns: (0.27fr, 0.13fr, 0.60fr),
    column-gutter: 7pt,
    align: top,

    [
      #label(name, fill: accent)
      #v(2pt)
      #text(
        size: 7.1pt,
        weight: "semibold",
        fill: ink,
      )[#role]
    ],

    [
      #label(unit, fill: mute)
    ],

    [
      #note(body, size: 6.65pt)
    ],
  )
]

#let relation-example(
  der,
  photopic,
  melanopic,
  accent: violet,
) = block(
  width: 100%,
  inset: (x: 7pt, y: 5pt),
  radius: 3pt,
  fill: faint,
  stroke: hair + 0.55pt,
  breakable: false,
)[
  #grid(
    columns: (1fr, auto, 1fr, auto, 1fr),
    column-gutter: 5pt,
    align: horizon,

    [
      #label[photopic]
      #v(2pt)
      #text(size: 9.4pt, weight: "semibold", fill: ink)[#photopic lx]
    ],

    [
      #text(size: 10pt, fill: mute)[×]
    ],

    [
      #label[melanopic DER]
      #v(2pt)
      #text(size: 9.4pt, weight: "semibold", fill: accent)[#der]
    ],

    [
      #text(size: 10pt, fill: mute)[=]
    ],

    [
      #label[melanopic EDI]
      #v(2pt)
      #text(size: 9.4pt, weight: "semibold", fill: accent)[#melanopic lx]
    ],
  )
]

#let target-band(
  kicker,
  value,
  body,
  accent: blackish,
  fill: faint,
) = block(
  width: 100%,
  inset: (x: 7pt, y: 5pt),
  radius: 3pt,
  fill: fill,
  stroke: accent + 0.55pt,
  breakable: false,
)[
  #grid(
    columns: (0.18fr, 0.20fr, 1fr),
    column-gutter: 8pt,
    align: horizon,

    [
      #label(kicker, fill: accent)
    ],

    [
      #text(
        size: 11pt,
        weight: "semibold",
        fill: ink,
      )[#value]
    ],

    [
      #note(body, size: 6.7pt)
    ],
  )
]

#let der-row(
  der,
  daytime-lux,
  evening-lux,
  accent: violet,
) = grid(
  columns: (0.20fr, 0.40fr, 0.40fr),
  column-gutter: 6pt,
  align: horizon,

  [
    #text(
      size: 8pt,
      weight: "semibold",
      fill: accent,
    )[#der]
  ],

  [
    #text(
      size: 7.4pt,
      fill: ink,
    )[#daytime-lux]
  ],

  [
    #text(
      size: 7.4pt,
      fill: ink,
    )[#evening-lux]
  ],
)


// =============================================================================
// PAGE 1 — Implementation targets
// =============================================================================

#grid(
  columns: (0.31fr, 0.69fr),
  column-gutter: 13pt,
  align: top,

  [
    #section-intro(
      [implementation targets],
      [Specify the light that reaches the eye.],
      [Circadian lighting is not specified by CCT, fixture wattage, or horizontal lux alone. The practical design quantity is melanopic equivalent daylight illuminance at the observer's eye, evaluated in time as well as space.],
      accent: violet,
      title-size: 27pt,
    )

    #v(8pt)

    #callout-card(
      [the design quantity],
      [Melanopic EDI is the scene target.],
      [CIE S 026 expresses melanopsin-weighted exposure as melanopic equivalent daylight illuminance: the illuminance of standard D65 daylight that would produce the same melanopic stimulus. For implementation, this is the quantity to calculate or measure at the eye.],
      accent: blue,
      fill: faint,
    )

    #v(7pt)

    #callout-card(
      [measurement plane],
      [Measure vertically, where the eye is looking.],
      [Conventional horizontal workplane lux does not describe retinal exposure. Evaluate melanopic EDI on a vertical plane at representative eye position and facing the expected direction of gaze.],
      accent: red,
    )

    #v(7pt)

    #callout-card(
      [important distinction],
      [DER tells you the engine. EDI tells you the delivered signal.],
      [Melanopic DER describes the spectral efficiency of a source relative to daylight. Melanopic EDI combines that spectral property with the actual photopic illuminance reaching the eye.],
      accent: amber,
    )
  ],

  [
    #grid(
      columns: (1fr, 1fr, 1fr),
      column-gutter: 7pt,
      align: top,

      [
        #target-card(
          [daytime],
          [≥ 250 lx],
          [melanopic EDI at the eye],
          [Target throughout the normal waking day for healthy day-active adults. Daylight is the preferred way to reach or exceed the target where practical.],
          accent: blue,
        )
      ],

      [
        #target-card(
          [evening],
          [≤ 10 lx],
          [during the 3 h before bedtime],
          [Reduce retinal melanopic exposure substantially before sleep. This is a scene-level limit, so displays, windows, decorative light, and task lighting all contribute.],
          accent: amber,
        )
      ],

      [
        #target-card(
          [sleep],
          [≤ 1 lx],
          [through the sleep period],
          [Darkness is the design condition during sleep. If nighttime visual activity is necessary, provide only the visibility required while keeping melanopic exposure very low.],
          accent: red,
        )
      ],
    )

    #v(9pt)

    #page-kicker(
      [how the quantities fit together],
      accent: violet,
    )

    #v(5pt)

    #grid(
      columns: (1fr, auto, 1fr, auto, 1fr),
      column-gutter: 6pt,
      align: top,

      [
        #flow-chip(
          [spectral power distribution],
          [what wavelengths the source emits],
          accent: blackish,
        )
      ],

      [#flow-arrow()],

      [
        #flow-chip(
          [melanopic DER],
          [spectral efficiency relative to D65],
          accent: amber,
        )
      ],

      [#flow-arrow()],

      [
        #flow-chip(
          [melanopic EDI],
          [delivered melanopic exposure at the eye],
          accent: blue,
        )
      ],
    )

    #v(8pt)

    #quantity-row(
      [photopic illuminance],
      [visual quantity],
      [lx],
      [Ordinary illuminance weighted by V(λ). It remains the conventional quantity for visibility, tasks, glare assessment, and ordinary lighting design.],
      accent: ref-visual,
    )

    #v(5pt)

    #quantity-row(
      [melanopic DER],
      [source property],
      [ratio],
      [The melanopic daylight efficacy ratio. It indicates how much melanopic stimulus a spectrum produces per unit of photopic illuminance relative to D65. D65 has a DER of 1.],
      accent: amber,
    )

    #v(5pt)

    #quantity-row(
      [melanopic EDI],
      [scene exposure],
      [lx],
      [The primary circadian implementation quantity: the D65-equivalent illuminance producing the same melanopic stimulus as the actual light reaching the observer's eye.],
      accent: blue,
    )

    #v(9pt)

    #callout-card(
      [working relationship],
      [Melanopic EDI ≈ vertical photopic lux × melanopic DER.],
      [
        For a source or scene whose spectrum is appropriately characterized:

        #v(5pt)

        #relation-example(
          [0.55],
          [500],
          [275],
          accent: violet,
        )

        #v(5pt)

        The same spectral engine at only 20 vertical photopic lux produces approximately 11 lx melanopic EDI. Spectrum determines conversion efficiency; intensity determines how much signal is delivered.
      ],
      accent: violet,
      fill: faint,
    )

    #v(8pt)

    #grid(
      columns: (1fr, 1fr),
      column-gutter: 8pt,
      align: top,

      [
        #callout-card(
          [commissioning],
          [Verify the occupied eye position.],
          [Do not sign off a circadian scene from fixture data alone. Measure or model the complete scene at representative eye locations and gaze directions, including daylight and reflected light.],
          accent: blue,
        )
      ],

      [
        #callout-card(
          [control sequence],
          [Targets belong to time states.],
          [A fixture does not have one universally healthy setting. Commission daytime, evening, and nighttime scenes separately and verify melanopic EDI in each state.],
          accent: red,
        )
      ],
    )
  ],
)

#v(7pt)

#bottom-takeaway(
  [implementation rule],
  [Specify melanopic EDI at the eye by time of day: aim for at least 250 lx during the normal daytime, no more than 10 lx during the three hours before sleep, and no more than 1 lx during sleep. Use melanopic DER to understand the spectral engine, but commission the delivered scene using melanopic EDI alongside ordinary visual-lighting requirements.],
  accent: violet,
)




// =============================================================================
// PAGE 2 — From target to control
// =============================================================================

#pagebreak()

#import "@preview/lilaq:0.6.0" as lq

// -----------------------------------------------------------------------------
// Page-local helpers
// -----------------------------------------------------------------------------

#let bar-row(
  der,
  value,
  max-value,
  accent,
  suffix: " lx",
) = {
  let pct = value / max-value * 100%

  grid(
    columns: (0.14fr, 0.66fr, 0.20fr),
    column-gutter: 7pt,
    align: horizon,

    [
      #text(
        size: 7.2pt,
        weight: "semibold",
        fill: accent,
      )[DER #der]
    ],

    [
      #box(
        width: 100%,
        height: 6pt,
        fill: rgb("#ececf4"),
      )[
        #box(
          width: pct,
          height: 6pt,
          fill: accent,
        )[]
      ]
    ],

    [
      #align(right)[
        #text(
          size: 7.2pt,
          weight: "semibold",
          fill: ink,
        )[#value#suffix]
      ]
    ],
  )
}

#let trajectory-node(
  kicker,
  target,
  body,
  accent,
) = block(
  width: 100%,
  inset: (x: 4pt, y: 0pt),
  breakable: false,
)[
  #label(kicker, fill: accent)
  #v(2pt)

  #text(
    size: 15pt,
    weight: "semibold",
    fill: ink,
  )[#target]

  #v(3pt)

  #note(
    body,
    size: 6.75pt,
  )
]

// =============================================================================
// Header
// =============================================================================

#page-kicker(
  [from target to control],
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
      There is no universally circadian-friendly spectrum.
    ]
  ],

  [
    #lede(
      size: 10.4pt,
    )[
      Spectral efficiency becomes useful or undesirable according to the biological job the lighting system is performing. High melanopic efficiency helps build biological day. Low melanopic efficiency creates visual headroom when melanopic exposure must be constrained.
    ]
  ],
)

#v(10pt)

#line(length: 100%, stroke: hair + 0.65pt)

#v(9pt)

// =============================================================================
// Mirrored comparison
// =============================================================================

#grid(
  columns: (1fr, 1fr),
  column-gutter: 18pt,
  align: top,

  [
    #label(
      [biological day],
      fill: blue,
    )

    #v(3pt)

    #text(
      size: 16pt,
      weight: "semibold",
      fill: ink,
    )[
      How much visual light is required?
    ]

    #v(3pt)

    #note(
      size: 7.2pt,
      fill: soft,
    )[
      Vertical photopic illuminance required to reach the daytime target of 250 lx melanopic EDI.
    ]

    #v(9pt)

    #bar-row(
      [1.0],
      250,
      1250,
      blue,
    )

    #v(6pt)

    #bar-row(
      [0.8],
      312.5,
      1250,
      cyan,
    )

    #v(6pt)

    #bar-row(
      [0.6],
      416.7,
      1250,
      green,
    )

    #v(6pt)

    #bar-row(
      [0.4],
      625,
      1250,
      amber,
    )

    #v(6pt)

    #bar-row(
      [0.2],
      1250,
      1250,
      red,
    )

    #v(8pt)

    #grid(
      columns: (1fr, auto),
      column-gutter: 7pt,
      align: horizon,

      [
        #line(
          length: 100%,
          stroke: blue + 0.8pt,
        )
      ],

      [
        #text(
          size: 7.2pt,
          weight: "bold",
          fill: blue,
        )[
          HIGH DER HELPS
        ]
      ],
    )

    #v(5pt)

    #note(
      size: 6.9pt,
    )[
      A melanopically efficient spectrum reaches the daytime biological target with less visual illuminance. Lower DER makes the same daytime target progressively harder to achieve.
    ]
  ],

  [
    #label(
      [biological evening],
      fill: amber,
    )

    #v(3pt)

    #text(
      size: 16pt,
      weight: "semibold",
      fill: ink,
    )[
      How much visual light can we retain?
    ]

    #v(3pt)

    #note(
      size: 7.2pt,
      fill: soft,
    )[
      Vertical photopic illuminance available while remaining within the evening ceiling of 10 lx melanopic EDI.
    ]

    #v(9pt)

    #bar-row(
      [1.0],
      10,
      50,
      blue,
    )

    #v(6pt)

    #bar-row(
      [0.8],
      12.5,
      50,
      cyan,
    )

    #v(6pt)

    #bar-row(
      [0.6],
      16.7,
      50,
      green,
    )

    #v(6pt)

    #bar-row(
      [0.4],
      25,
      50,
      amber,
    )

    #v(6pt)

    #bar-row(
      [0.2],
      50,
      50,
      red,
    )

    #v(8pt)

    #grid(
      columns: (auto, 1fr),
      column-gutter: 7pt,
      align: horizon,

      [
        #text(
          size: 7.2pt,
          weight: "bold",
          fill: red,
        )[
          LOW DER HELPS
        ]
      ],

      [
        #line(
          length: 100%,
          stroke: red + 0.8pt,
        )
      ],
    )

    #v(5pt)

    #note(
      size: 6.9pt,
    )[
      A low-DER spectrum produces less melanopic stimulus per unit of visual illumination, leaving more usable visual light inside the same evening biological budget.
    ]
  ],
)

#v(11pt)

#line(length: 100%, stroke: hair + 0.65pt)

#v(9pt)

// =============================================================================
// Central interpretation
// =============================================================================

#align(center)[
  #block(
    width: 78%,
  )[
    #align(center)[
      #label(
        [the reversal],
        fill: violet,
      )
    ]

    #v(4pt)

    #align(center)[
      #text(
        size: 14.5pt,
        weight: "semibold",
        fill: ink,
      )[
        The same spectral property changes meaning with time.
      ]
    ]

    #v(4pt)

    #align(center)[
      #note(
        size: 7.6pt,
        fill: soft,
      )[
        During biological day, melanopic efficiency is useful because the system is trying to build a strong clock signal. During biological evening, melanopic inefficiency becomes useful because it preserves visual illumination while withdrawing that same signal.
      ]
    ]
  ]
]

#v(10pt)

// =============================================================================
// Time trajectory
// =============================================================================

#page-kicker(
  [the specification is temporal],
  accent: red,
)

#v(6pt)

#grid(
  columns: (1fr, auto, 1fr, auto, 1fr),
  column-gutter: 10pt,
  align: top,

  [
    #trajectory-node(
      [normal waking day],
      [≥ 250 lx],
      [Build the melanopic signal. Broad, melanopically efficient light is useful when the body needs a strong daytime anchor.],
      blue,
    )
  ],

  [
    #align(horizon)[
      #text(
        size: 17pt,
        fill: mute,
      )[→]
    ]
  ],

  [
    #trajectory-node(
      [3 h before bed],
      [≤ 10 lx],
      [Withdraw the signal while preserving enough visual illumination for ordinary evening activity.],
      amber,
    )
  ],

  [
    #align(horizon)[
      #text(
        size: 17pt,
        fill: mute,
      )[→]
    ]
  ],

  [
    #trajectory-node(
      [sleep period],
      [≤ 1 lx],
      [Protect biological darkness. Any necessary nighttime light should be tightly constrained in spectrum, quantity, duration, and field of view.],
      red,
    )
  ],
)

#v(7pt)

#grid(
  columns: (1fr, 1fr, 1fr),
  column-gutter: 10pt,
  align: horizon,

  [
    #line(
      length: 100%,
      stroke: blue + 2pt,
    )
  ],

  [
    #line(
      length: 100%,
      stroke: amber + 2pt,
    )
  ],

  [
    #line(
      length: 100%,
      stroke: red + 2pt,
    )
  ],
)

#v(6pt)

#grid(
  columns: (1fr, 1fr, 1fr),
  column-gutter: 10pt,
  align: top,

  [
    #align(center)[
      #label(
        [broad / melanopically efficient],
        fill: blue,
      )
    ]
  ],

  [
    #align(center)[
      #label(
        [reduced melanopic efficiency],
        fill: amber,
      )
    ]
  ],

  [
    #align(center)[
      #label(
        [strongly constrained],
        fill: red,
      )
    ]
  ],
)

#v(10pt)

#bottom-takeaway(
  [design rule],
  [The specification is not a preferred lamp spectrum. It is a controlled trajectory through biological day, evening, and night. Spectrum determines how efficiently visual light becomes melanopic stimulus; intensity determines how much stimulus is delivered; time determines whether that stimulus is useful.],
  accent: violet,
)

