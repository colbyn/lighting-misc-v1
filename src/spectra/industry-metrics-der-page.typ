#import "../lib/common.typ": page-margin
#import "components.typ": *

#set page(
  paper: "a4",
  flipped: true,
  margin: page-margin,
  fill: rgb("#222222"),
)

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
  inset: (x: 9pt, y: 8pt),
  radius: 4pt,
  fill: faint,
  stroke: accent + 0.6pt,
  breakable: false,
)[
  #label(kicker, fill: accent)
  #v(4pt)

  #grid(
    columns: (1fr, auto, 1fr, auto, 1fr),
    column-gutter: 8pt,
    align: horizon,

    [
      #align(center)[
        #text(
          size: 13.5pt,
          weight: "semibold",
          fill: ink,
        )[
          #lhs
        ]
      ]
    ],

    [
      #text(
        size: 12pt,
        fill: mute,
      )[
        #operator
      ]
    ],

    [
      #align(center)[
        #text(
          size: 13.5pt,
          weight: "semibold",
          fill: accent,
        )[
          #rhs
        ]
      ]
    ],

    [
      #text(
        size: 12pt,
        fill: mute,
      )[
        =
      ]
    ],

    [
      #align(center)[
        #text(
          size: 13.5pt,
          weight: "semibold",
          fill: ink,
        )[
          #result
        ]
      ]
    ],
  )

  #v(5pt)

  #note(
    body,
    size: 6.9pt,
  )
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

  #v(3pt)

  #note(
    question,
    size: 6.9pt,
    fill: soft,
  )

  #v(6pt)

  #block(
    width: 100%,
    inset: (x: 7pt, y: 6pt),
    radius: 3pt,
    fill: faint,
  )[
    #align(center)[
      #text(
        size: 12.5pt,
        weight: "semibold",
        fill: accent,
      )[
        #equation
      ]
    ]
  ]

  #v(5pt)

  #note(
    interpretation,
    size: 6.65pt,
  )
]

// =============================================================================
// DER — from ratio to design decision
// =============================================================================

#grid(
  columns: (0.36fr, 0.64fr),
  column-gutter: 13pt,
  align: top,

  // ---------------------------------------------------------------------------
  // LEFT — what the relationship means
  // ---------------------------------------------------------------------------

  [
    #section-intro(
      [from spectrum to biological signal],
      [DER connects photopic illuminance to melanopic exposure.],
      [
        Once the spectrum's DER is known, the same relationship can answer two
        opposite design questions: how much light is required by day, and how
        much can remain in the evening.
      ],
      accent: violet,
      title-size: 24pt,
    )

    #v(10pt)

    #callout-card(
      [one equation, two questions],
      [The arithmetic stays the same. The unknown changes.],
      [
        For daytime, start with a melanopic target and solve for the photopic
        illuminance required to reach it. For evening, start with a melanopic
        ceiling and solve for the photopic illuminance that can remain beneath it.
      ],
      accent: violet,
      fill: faint,
      inset-x: 9pt,
      inset-y: 8pt,
    )

    #v(9pt)

    #page-kicker(
      [same 100 lx, different spectrum],
      accent: blackish,
    )

    #v(5pt)

    #sequence-chip(
      [DER 1.0],
      [100 lx → 100 lx melanopic EDI],
      [
        A daylight-like ratio: melanopic EDI tracks photopic illuminance
        one-for-one.
      ],
      accent: blue,
    )

    #v(5pt)

    #sequence-chip(
      [DER 0.5],
      [100 lx → 50 lx melanopic EDI],
      [
        The same visual-light level carries half as much melanopic exposure.
      ],
      accent: amber,
    )

    #v(5pt)

    #sequence-chip(
      [DER 0.2],
      [100 lx → 20 lx melanopic EDI],
      [
        Much less melanopic exposure remains for the same photopic illuminance.
      ],
      accent: red,
    )

    #v(9pt)

    #callout-card(
      [the reversal],
      [The desirable direction depends on time.],
      [
        Higher DER is useful when the goal is to build melanopic exposure
        efficiently. Lower DER is useful when the goal is to preserve visual
        light while constraining melanopic exposure.
      ],
      accent: violet,
      fill: faint,
      inset-y: 8pt,
    )
  ],

  // ---------------------------------------------------------------------------
  // RIGHT — use the relationship
  // ---------------------------------------------------------------------------

  [
    #page-kicker(
      [the working relationship],
      accent: violet,
    )

    #v(5pt)

    #equation-card(
      [from visual light to melanopic exposure],
      [photopic lx],
      [×],
      [melanopic DER],
      [melanopic EDI],
      [
        Change the photopic level and the total exposure changes.
        Change DER and the melanopic content of each photopic lux changes.
      ],
      accent: violet,
    )

    #v(9pt)

    #page-kicker(
      [solve for the unknown],
      accent: blackish,
    )

    #v(6pt)

    #grid(
      columns: (1fr, 1fr),
      column-gutter: 9pt,
      align: top,

      [
        #scenario-card(
          [biological day],
          [How much light is required?],
          [
            Suppose the daytime target is 250 lx melanopic EDI.
          ],
          [250 ÷ DER = required photopic lx],
          [
            At DER 1.0, the target requires 250 photopic lx.

            At DER 0.5, it requires 500 photopic lx.

            Higher DER therefore reaches the same melanopic target with less
            photopic illuminance.
          ],
          accent: blue,
        )
      ],

      [
        #scenario-card(
          [biological evening],
          [How much light can remain?],
          [
            Suppose melanopic EDI must stay at or below 10 lx.
          ],
          [10 ÷ DER = maximum photopic lx],
          [
            At DER 1.0, only 10 photopic lx can remain.

            At DER 0.5, 20 photopic lx can remain.

            Lower DER therefore preserves more visual light beneath the same
            melanopic ceiling.
          ],
          accent: amber,
        )
      ],
    )

    #v(8pt)

    #grid(
      columns: (1fr, auto, 1fr),
      column-gutter: 10pt,
      align: horizon,

      [
        #align(right)[
          #text(
            size: 8pt,
            weight: "bold",
            fill: blue,
          )[
            HIGHER DER → MORE EDI PER LX
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
          LOWER DER → LESS EDI PER LX
        ]
      ],
    )

    #v(9pt)

    #page-kicker(
      [the target changes with time],
      accent: red,
    )

    #v(6pt)

    #grid(
      columns: (1fr, auto, 1fr, auto, 1fr),
      column-gutter: 7pt,
      align: horizon,

      [
        #sequence-chip(
          [normal waking day],
          [≥ 250 lx melanopic EDI],
          [
            Establish a strong daytime signal.
          ],
          accent: blue,
        )
      ],

      [
        #text(
          size: 14pt,
          fill: mute,
        )[
          →
        ]
      ],

      [
        #sequence-chip(
          [3 h before bed],
          [≤ 10 lx melanopic EDI],
          [
            Reduce melanopic exposure while retaining useful light.
          ],
          accent: amber,
        )
      ],

      [
        #text(
          size: 14pt,
          fill: mute,
        )[
          →
        ]
      ],

      [
        #sequence-chip(
          [sleep period],
          [≤ 1 lx melanopic EDI],
          [
            Keep necessary nighttime exposure tightly constrained.
          ],
          accent: red,
        )
      ],
    )

    #v(8pt)

    #note(
      size: 7.2pt,
      fill: mute,
    )[
      The equation does not reverse between day and evening. The design
      objective does: first use the spectrum to build melanopic exposure,
      then use it to limit that exposure without discarding more visual light
      than necessary.
    ]

    #v(8pt)

    #bottom-takeaway(
      [design rule],
      [
        Set the biological target first. Then choose illuminance and spectrum
        together to reach it.
      ],
      accent: violet,
    )
  ],
)
