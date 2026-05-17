#import "./lib/tables.typ": argument-table, table-label, table-body, table-rule, table-strong-rule

== Dimming Is Not Just “Less Power”

#v(8pt)

With LEDs, dimming is not a single electrical behavior.

#v(6pt)

The same visible result — less light — can come from pulsing the LED, lowering the LED current, or combining both methods. That choice affects flicker, color stability, camera behavior, low-end smoothness, and perceived quality.

#v(14pt)

#argument-table(
  columns: (0.28fr, 1fr),

  [#table-label[THE QUESTION]],
  [
    #table-body[
      A product being “dimmable” is not enough. The real question is how it dims.
    ]
  ],
)

#v(18pt)

#line(length: 100%, stroke: rgb("#d8d8e2"))

#v(14pt)

#argument-table(
  columns: (0.72fr, 1.22fr, 1.38fr),

  table.header(
    [#table-label[METHOD]],
    [#table-label[ELECTRICAL BEHAVIOR]],
    [#table-label[QUALITY RISK]],
  ),

  table-strong-rule(),

  [#table-body[PWM dimming]],
  [
    #table-body[
      The LED turns on and off rapidly. Brightness is controlled by changing the duty cycle.
    ]
  ],
  [
    #table-body[
      Poor implementations can create visible flicker, camera banding, eyestrain, or cheap low-end behavior.
    ]
  ],

  table-rule(),

  [#table-body[current reduction]],
  [
    #table-body[
      The driver lowers the actual LED current while keeping output continuous.
    ]
  ],
  [
    #table-body[
      Can produce very low-flicker dimming, but may introduce color shift, reduced driver accuracy, or limited low-end range.
    ]
  ],

  table-rule(),

  [#table-body[hybrid dimming]],
  [
    #table-body[
      The driver uses current reduction through most of the range, then reserves PWM for levels below the analog floor.
    ]
  ],
  [
    #table-body[
      Often the best practical compromise when implemented at high frequency and with clean transitions.
    ]
  ],
)

#v(18pt)

#text(size: 12pt, weight: "medium")[
  What “less light” looks like electrically
]

#v(7pt)

The visible output may look similar, but the electrical waveform can be completely different.

#v(12pt)

#let signal-strip(samples, height: 24pt) = {
  let cols = ()
  let cells = ()

  for s in samples {
    cols.push(1fr)

    let bar-height = if s == 0 {
      2pt
    } else {
      height * s
    }

    let bar-fill = if s == 0 {
      luma(230)
    } else {
      black
    }

    cells.push(
      align(bottom)[
        #rect(
          width: 100%,
          height: bar-height,
          fill: bar-fill,
          radius: 0.5pt,
        )
      ]
    )
  }

  grid(
    columns: cols,
    column-gutter: 1.5pt,
    align: bottom,
    ..cells,
  )
}

#let signal-row(label, samples) = grid(
  columns: (1.25fr, 3fr),
  column-gutter: 10pt,
  align: horizon,

  [
    #text(size: 8.5pt, fill: luma(90), weight: "medium")[#label]
  ],

  [
    #signal-strip(samples)
  ],
)

#let signal-section(title, subtitle, body) = block(
  width: 100%,
  inset: 10pt,
  stroke: 0.5pt + luma(220),
  radius: 4pt,
  breakable: false,
)[
  #grid(
    columns: (1.1fr, 2.9fr),
    column-gutter: 16pt,
    align: top,

    [
      #text(weight: "bold", size: 12pt)[#title]

      #v(3pt)

      #text(size: 8.5pt, fill: luma(90))[#subtitle]
    ],

    [
      #body
    ],
  )
]

#signal-section(
  [PWM Dimming],
  [same current, less time on],
  [
    #signal-row(
      [High output — long on-time],
      (1, 1, 1, 1, 0, 1, 1, 1, 1, 0, 1, 1),
    )
    #signal-row(
      [Medium output — balanced on/off],
      (1, 1, 0, 0, 1, 1, 0, 0, 1, 1, 0, 0),
    )
    #signal-row(
      [Low output — short on-time],
      (1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1, 0),
    )
  ],
)

#signal-section(
  [Current Reduction],
  [same time on, less current],
  [
    #signal-row(
      [High output — higher current],
      (0.85, 0.85, 0.85, 0.85, 0.85, 0.85, 0.85, 0.85, 0.85, 0.85, 0.85, 0.85),
    )

    #v(7pt)

    #signal-row(
      [Medium output — reduced current],
      (0.55, 0.55, 0.55, 0.55, 0.55, 0.55, 0.55, 0.55, 0.55, 0.55, 0.55, 0.55),
    )

    #v(7pt)

    #signal-row(
      [Low output — low current],
      (0.25, 0.25, 0.25, 0.25, 0.25, 0.25, 0.25, 0.25, 0.25, 0.25, 0.25, 0.25),
    )
  ],
)

#signal-section(
  [Hybrid Dimming],
  [current reduction first, PWM only after the analog floor],
  [
    #signal-row(
      [High output — continuous current],
      (0.85, 0.85, 0.85, 0.85, 0.85, 0.85, 0.85, 0.85, 0.85, 0.85, 0.85, 0.85),
    )

    #v(7pt)

    #signal-row(
      [Medium output — reduced current],
      (0.55, 0.55, 0.55, 0.55, 0.55, 0.55, 0.55, 0.55, 0.55, 0.55, 0.55, 0.55),
    )

    #v(7pt)

    #signal-row(
      [Low output — analog floor],
      (0.25, 0.25, 0.25, 0.25, 0.25, 0.25, 0.25, 0.25, 0.25, 0.25, 0.25, 0.25),
    )

    #v(7pt)

    #signal-row(
      [Very low output — PWM below the floor],
      (0.25, 0, 0, 0, 0, 0.25, 0, 0, 0, 0, 0.25, 0),
    )
  ],
)

