#import "components.typ": *

// =============================================================================
// Page-local helpers
// =============================================================================

#let equation-card(
  kicker,
  lhs,
  operator,
  rhs,
  result,
  body,
  accent: violet,
) = block(
  width: 100%,
  inset: (x: 8pt, y: 7pt),
  radius: 4pt,
  fill: faint,
  stroke: accent + 0.6pt,
  breakable: false,
)[
  #label(kicker, fill: accent)
  #v(4pt)

  #grid(
    columns: (1fr, auto, 1fr, auto, 1fr),
    column-gutter: 7pt,
    align: horizon,

    [
      #align(center)[
        #text(
          size: 13pt,
          weight: "semibold",
          fill: ink,
        )[#lhs]
      ]
    ],

    [
      #text(size: 12pt, fill: mute)[#operator]
    ],

    [
      #align(center)[
        #text(
          size: 13pt,
          weight: "semibold",
          fill: accent,
        )[#rhs]
      ]
    ],

    [
      #text(size: 12pt, fill: mute)[=]
    ],

    [
      #align(center)[
        #text(
          size: 13pt,
          weight: "semibold",
          fill: ink,
        )[#result]
      ]
    ],
  )

  #v(5pt)
  #note(body, size: 6.9pt)
]

#let scenario-card(
  kicker,
  title,
  question,
  equation,
  interpretation,
  accent: blackish,
) = block(
  width: 100%,
  inset: (x: 9pt, y: 8pt),
  radius: 4pt,
  fill: white,
  stroke: accent + 0.7pt,
  breakable: false,
)[
  #label(kicker, fill: accent)
  #v(3pt)

  #text(
    size: 15pt,
    weight: "semibold",
    fill: ink,
  )[#title]

  #v(4pt)
  #note(question, size: 7.1pt, fill: soft)

  #v(7pt)

  #block(
    width: 100%,
    inset: (x: 7pt, y: 6pt),
    radius: 3pt,
    fill: faint,
  )[
    #align(center)[
      #text(
        size: 13pt,
        weight: "semibold",
        fill: accent,
      )[#equation]
    ]
  ]

  #v(6pt)
  #note(interpretation, size: 6.9pt)
]

#let der-chip(
  der,
  meaning,
  accent: violet,
) = block(
  width: 100%,
  inset: (x: 7pt, y: 5pt),
  radius: 3pt,
  fill: white,
  stroke: hair + 0.55pt,
  breakable: false,
)[
  #grid(
    columns: (0.25fr, 0.75fr),
    column-gutter: 8pt,
    align: horizon,

    [
      #text(
        size: 11pt,
        weight: "semibold",
        fill: accent,
      )[DER #der]
    ],

    [
      #note(meaning, size: 6.8pt)
    ],
  )
]

// =============================================================================
// Page
// =============================================================================

#page-kicker(
  [from spectrum to biological signal],
  accent: violet,
)

#v(5pt)

#grid(
  columns: (0.40fr, 0.60fr),
  column-gutter: 14pt,
  align: top,

  [
    #headline(
      size: 27pt,
    )[
      DER is the conversion factor.
    ]
  ],

  [
    #lede(
      size: 10.4pt,
    )[
      Melanopic DER tells us how efficiently visible light becomes melanopic stimulus. Once DER is known, the same relationship explains both daytime lighting and evening light reduction.
    ]
  ],
)

#v(10pt)

#line(length: 100%, stroke: hair + 0.65pt)

#v(9pt)

// -----------------------------------------------------------------------------
// 1. Anchor the concept
// -----------------------------------------------------------------------------

#grid(
  columns: (0.35fr, 0.65fr),
  column-gutter: 14pt,
  align: top,

  [
    #label(
      [one equation],
      fill: violet,
    )

    #v(3pt)

    #text(
      size: 16pt,
      weight: "semibold",
      fill: ink,
    )[
      Start with the relationship.
    ]

    #v(4pt)

    #note(
      size: 7.2pt,
      fill: soft,
    )[
      Photopic illuminance describes the visible-light level. DER describes the spectrum. Their product gives melanopic EDI.
    ]
  ],

  [
    #equation-card(
      [working relationship],
      [photopic lx],
      [×],
      [melanopic DER],
      [melanopic EDI],
      [The spectrum does not replace illuminance; it changes how much melanopic signal a given illuminance produces.],
      accent: violet,
    )
  ],
)

#v(10pt)

#grid(
  columns: (1fr, 1fr, 1fr),
  column-gutter: 7pt,
  align: top,

  [
    #der-chip(
      [1.0],
      [Daylight-like melanopic efficiency. 100 photopic lx produces about 100 lx melanopic EDI.],
      accent: blue,
    )
  ],

  [
    #der-chip(
      [0.5],
      [Half the melanopic efficiency of D65. 100 photopic lx produces about 50 lx melanopic EDI.],
      accent: amber,
    )
  ],

  [
    #der-chip(
      [0.2],
      [Low melanopic efficiency. 100 photopic lx produces about 20 lx melanopic EDI.],
      accent: red,
    )
  ],
)

#v(11pt)

#line(length: 100%, stroke: hair + 0.65pt)

#v(9pt)

// -----------------------------------------------------------------------------
// 2. Apply the same relationship to day and evening
// -----------------------------------------------------------------------------

#page-kicker(
  [same equation, different goal],
  accent: blackish,
)

#v(6pt)

#grid(
  columns: (1fr, 1fr),
  column-gutter: 12pt,
  align: top,

  [
    #scenario-card(
      [biological day],
      [Reach the daytime target.],
      [If the target is 250 lx melanopic EDI, how much visible light is needed?],
      [250 ÷ DER = required photopic lx],
      [
        A higher DER lowers the amount of photopic illuminance required.
        At DER 1.0, the target needs 250 photopic lx.
        At DER 0.5, it needs 500 photopic lx.
      ],
      accent: blue,
    )
  ],

  [
    #scenario-card(
      [biological evening],
      [Stay below the evening ceiling.],
      [If the limit is 10 lx melanopic EDI, how much visible light can remain?],
      [10 ÷ DER = maximum photopic lx],
      [
        A lower DER raises the amount of photopic illuminance that can remain.
        At DER 1.0, the ceiling is reached at 10 photopic lx.
        At DER 0.5, it is reached at 20 photopic lx.
      ],
      accent: amber,
    )
  ],
)

#v(9pt)

#grid(
  columns: (1fr, auto, 1fr),
  column-gutter: 9pt,
  align: horizon,

  [
    #align(right)[
      #text(
        size: 8pt,
        weight: "bold",
        fill: blue,
      )[
        HIGHER DER HELPS
      ]
    ]
  ],

  [
    #text(
      size: 15pt,
      fill: mute,
    )[
      ↔
    ]
  ],

  [
    #text(
      size: 8pt,
      weight: "bold",
      fill: amber,
    )[
      LOWER DER HELPS
    ]
  ],
)

#v(10pt)

#line(length: 100%, stroke: hair + 0.65pt)

#v(9pt)

// -----------------------------------------------------------------------------
// 3. Interpretation
// -----------------------------------------------------------------------------

#align(center)[
  #block(
    width: 82%,
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
        DER is not good or bad by itself.
      ]
    ]

    #v(4pt)

    #align(center)[
      #note(
        size: 7.6pt,
        fill: soft,
      )[
        During biological day, higher melanopic efficiency helps build a strong clock signal with less visible light. During biological evening, lower melanopic efficiency preserves more useful visible light while keeping melanopic exposure constrained.
      ]
    ]
  ]
]

#v(10pt)

// -----------------------------------------------------------------------------
// 4. Time trajectory
// -----------------------------------------------------------------------------

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
    #callout-card(
      [normal waking day],
      [≥ 250 lx melanopic EDI],
      [Build a strong daytime signal. Broad, melanopically efficient light is useful here.],
      accent: blue,
      fill: faint,
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
    #callout-card(
      [3 h before bed],
      [≤ 10 lx melanopic EDI],
      [Withdraw the melanopic signal while preserving enough visible light for ordinary activity.],
      accent: amber,
      fill: faint,
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
    #callout-card(
      [sleep period],
      [≤ 1 lx melanopic EDI],
      [Protect biological darkness. Necessary nighttime light should be tightly constrained in spectrum and quantity.],
      accent: red,
      fill: faint,
    )
  ],
)

// #v(8pt)

// #bottom-takeaway(
//   [design rule],
//   [Think of DER as the spectral conversion factor and EDI as the delivered biological signal. High DER is useful when building biological day; low DER is useful when preserving visible light while withdrawing that signal in the evening and at night.],
//   accent: violet,
// )
