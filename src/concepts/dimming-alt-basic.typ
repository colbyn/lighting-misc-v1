// =============================================================================
// Standalone section: Dimming Is Not Just “Less Power”
// =============================================================================

#set page(
  paper: "us-letter",
  flipped: true,
  margin: (x: 0.2in, y: 0.2in),
)

#set text(
  font: "Avenir Next",
  size: 8.6pt,
  fill: rgb("#23242a"),
)

#set par(
  justify: false,
  leading: 0.64em,
  spacing: 6pt,
)

// =============================================================================
// Tokens
// =============================================================================

#let ink = rgb("#23242a")
#let soft = rgb("#50525d")
#let mute = rgb("#777985")
#let hair = rgb("#dddde8")
#let faint = rgb("#f6f7fb")
#let panel = rgb("#fcfcff")
#let white = rgb("#ffffff")

#let amber = rgb("#bd6a00")
#let green = rgb("#3a9a00")
#let violet = rgb("#7a3cff")
#let blue = rgb("#005eff")
#let blackish = rgb("#111111")

#let pwm-fill = rgb("#7a3cff")
#let ccr-fill = rgb("#3a9a00")
#let hybrid-fill = rgb("#005eff")
#let off-fill = luma(234)

// =============================================================================
// Typography / components
// =============================================================================

#let label(body, fill: mute) = text(
  size: 6.5pt,
  weight: "bold",
  tracking: 0.10em,
  fill: fill,
)[#upper(body)]

#let headline(body, size: 28pt) = text(
  size: size,
  weight: "medium",
  fill: ink,
)[#body]

#let lede(body, size: 10.9pt) = block(width: 100%)[
  #set par(leading: 0.72em)
  #text(size: size, fill: soft)[#body]
]

#let note(body, size: 7.35pt, fill: soft) = block(width: 100%)[
  #set par(leading: 0.66em)
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

#let section-intro(kicker, title, body, accent: blackish, title-size: 28pt) = block(width: 100%)[
  #page-kicker(kicker, accent: accent)
  #v(5pt)
  #headline(title, size: title-size)
  #v(5pt)
  #lede(body)
]

#let info-chip(title, body, accent: blackish) = block(
  width: 100%,
  inset: (x: 8pt, y: 7pt),
  radius: 3pt,
  fill: white,
  stroke: hair + 0.55pt,
  breakable: false,
)[
  #label(title, fill: accent)
  #v(3pt)
  #note(body, size: 7.0pt)
]

#let bottom-takeaway(kicker, body, accent: blackish) = block(
  width: 100%,
  inset: (x: 10pt, y: 8pt),
  radius: 3pt,
  fill: faint,
  stroke: hair + 0.6pt,
  breakable: false,
)[
  #grid(
    columns: (0.18fr, 1fr),
    column-gutter: 10pt,
    align: horizon,
    [#label(kicker, fill: accent)],
    [#note(body, size: 8.0pt, fill: ink)],
  )
]

// =============================================================================
// Signal-strip grammar
// =============================================================================

#let signal-strip(
  samples,
  height: 26pt,
  fill: blackish,
  zero-fill: off-fill,
  radius: 0.55pt,
  gutter: 1.4pt,
) = {
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
      zero-fill
    } else {
      fill
    }

    cells.push(
      align(bottom)[
        #rect(
          width: 100%,
          height: bar-height,
          fill: bar-fill,
          radius: radius,
        )
      ]
    )
  }

  grid(
    columns: cols,
    column-gutter: gutter,
    align: bottom,
    ..cells,
  )
}

#let signal-row(
  title,
  subtitle,
  samples,
  fill: blackish,
) = block(width: 100%)[
  #grid(
    columns: (1.55fr, 3.45fr),
    column-gutter: 12pt,
    align: horizon,

    [
      #text(size: 8.25pt, weight: "medium", fill: ink)[#title]
      #v(2pt)
      #text(size: 7.05pt, fill: mute)[#subtitle]
    ],

    [
      #signal-strip(
        samples,
        height: 26pt,
        fill: fill,
      )
    ],
  )
]

#let signal-section(
  kicker,
  title,
  subtitle,
  body,
  rows,
  accent: blackish,
) = block(
  width: 100%,
  inset: (x: 10pt, y: 9pt),
  radius: 4pt,
  fill: panel,
  stroke: hair + 0.55pt,
  breakable: false,
)[
  #grid(
    columns: (1.05fr, 2.95fr),
    column-gutter: 16pt,
    align: top,

    [
      #label(kicker, fill: accent)
      #v(3pt)
      #text(size: 12.8pt, weight: "medium", fill: ink)[#title]
      #v(2pt)
      #text(size: 8.3pt, fill: mute)[#subtitle]
      #v(7pt)
      #note(body, size: 7.2pt)
    ],

    [
      #rows
    ],
  )
]

// =============================================================================
// Section
// =============================================================================

== Dimming Is Not Just “Less Power”

#section-intro(
  [dimming],
  [The visible output may look similar, but the electrical waveform can be completely different.],
  [
    For LEDs, dimming is not one behavior. The driver can reduce current continuously,
    pulse the source in time, or combine both strategies. The visual result may be
    “less light,” but the electrical signal that produces that result can be very
    different.
  ],
  accent: amber,
  title-size: 24pt,
)

#v(10pt)

#grid(
  columns: (1fr, 1fr, 1fr),
  column-gutter: 8pt,
  align: top,

  [
    #info-chip(
      [read the strip],
      [Left to right is time. Bar height represents current.],
      accent: blackish,
    )
  ],

  [
    #info-chip(
      [CCR],
      [Same time on. Lower output comes from lower current level.],
      accent: green,
    )
  ],

  [
    #info-chip(
      [PWM],
      [Same peak current. Lower output comes from shorter on-time.],
      accent: violet,
    )
  ],
)

#v(10pt)

#signal-section(
  [pulsed LED dimming],
  [PWM],
  [same current, less time on],
  [
    Pulse-width modulation keeps the LED near the same peak operating current,
    but changes how long it stays on. Output falls because duty cycle falls.
  ],
  [
    #signal-row(
      [High output],
      [Long on-time. The source is on for most of the cycle.],
      (1, 1, 1, 1, 0, 1, 1, 1, 1, 0, 1, 1),
      fill: pwm-fill,
    )

    #v(7pt)

    #signal-row(
      [Medium output],
      [Balanced on/off time. Same peak current, less total on-time.],
      (1, 1, 0, 0, 1, 1, 0, 0, 1, 1, 0, 0),
      fill: pwm-fill,
    )

    #v(7pt)

    #signal-row(
      [Low output],
      [Short pulses. The LED is on only briefly in each cycle.],
      (1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1, 0),
      fill: pwm-fill,
    )
  ],
  accent: violet,
)

#v(8pt)

#signal-section(
  [analog LED dimming],
  [CCR],
  [same time on, less current],
  [
    Constant-current reduction keeps the source continuously driven, but lowers the
    operating current. Output falls because the current level falls.
  ],
  [
    #signal-row(
      [High output],
      [Higher continuous current. The signal stays steady over time.],
      (0.85, 0.85, 0.85, 0.85, 0.85, 0.85, 0.85, 0.85, 0.85, 0.85, 0.85, 0.85),
      fill: ccr-fill,
    )

    #v(7pt)

    #signal-row(
      [Medium output],
      [Reduced continuous current. Same time profile, lower level.],
      (0.55, 0.55, 0.55, 0.55, 0.55, 0.55, 0.55, 0.55, 0.55, 0.55, 0.55, 0.55),
      fill: ccr-fill,
    )

    #v(7pt)

    #signal-row(
      [Low output],
      [Low continuous current. Still steady, just lower.],
      (0.25, 0.25, 0.25, 0.25, 0.25, 0.25, 0.25, 0.25, 0.25, 0.25, 0.25, 0.25),
      fill: ccr-fill,
    )
  ],
  accent: green,
)

#v(8pt)

#signal-section(
  [combined strategy],
  [Hybrid],
  [current reduction first, PWM only after the analog floor],
  [
    Many real LED drivers use a hybrid strategy. They reduce current through much
    of the dimming range, then switch to PWM when deeper low-end dimming is needed.
  ],
  [
    #signal-row(
      [High output],
      [Continuous current in the upper range.],
      (0.85, 0.85, 0.85, 0.85, 0.85, 0.85, 0.85, 0.85, 0.85, 0.85, 0.85, 0.85),
      fill: hybrid-fill,
    )

    #v(7pt)

    #signal-row(
      [Medium output],
      [Reduced current, still analog.],
      (0.55, 0.55, 0.55, 0.55, 0.55, 0.55, 0.55, 0.55, 0.55, 0.55, 0.55, 0.55),
      fill: hybrid-fill,
    )

    #v(7pt)

    #signal-row(
      [Low output],
      [Analog floor: the lowest continuous-current range.],
      (0.25, 0.25, 0.25, 0.25, 0.25, 0.25, 0.25, 0.25, 0.25, 0.25, 0.25, 0.25),
      fill: hybrid-fill,
    )

    #v(7pt)

    #signal-row(
      [Very low output],
      [Below the analog floor, the driver switches to PWM.],
      (0.25, 0, 0, 0, 0, 0.25, 0, 0, 0, 0, 0.25, 0),
      fill: hybrid-fill,
    )
  ],
  accent: blue,
)

#v(10pt)

#grid(
  columns: (1fr, 1fr, 1fr),
  column-gutter: 8pt,
  align: top,

  [
    #info-chip(
      [what changes in CCR],
      [The bars stay full-width. What changes is their height.],
      accent: green,
    )
  ],

  [
    #info-chip(
      [what changes in PWM],
      [The bars keep the same peak height. What changes is the on-time.],
      accent: violet,
    )
  ],

  [
    #info-chip(
      [what changes in hybrid],
      [First the bars get shorter. Then the continuous strip breaks into pulses.],
      accent: blue,
    )
  ],
)

#v(10pt)

#bottom-takeaway(
  [dimming rule],
  [
    “Dimmed” is not a complete specification for an LED source. The same visible
    output can come from lower continuous current, pulsed output, or a hybrid handoff
    between the two. Less light does not tell you what the driver is doing.
  ],
  accent: violet,
)
