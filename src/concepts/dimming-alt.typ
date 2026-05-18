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

#let off-fill = luma(235)

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

#let note(body, size: 7.2pt, fill: soft) = block(width: 100%)[
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

#let section-intro(kicker, title, body, accent: blackish, title-size: 27pt) = block(width: 100%)[
  #page-kicker(kicker, accent: accent)
  #v(5pt)
  #headline(title, size: title-size)
  #v(5pt)
  #lede(body)
]

#let rule-card(kicker, body, accent: blackish) = block(
  width: 100%,
  inset: (x: 8pt, y: 7pt),
  radius: 3pt,
  fill: white,
  stroke: hair + 0.55pt,
  breakable: false,
)[
  #label(kicker, fill: accent)
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
  height: 31pt,
  fill: blackish,
  zero-fill: off-fill,
  radius: 0.55pt,
  gutter: 1.25pt,
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

#let signal-cell(samples, caption, fill: blackish) = block(
  width: 100%,
  inset: (x: 5.5pt, y: 5pt),
  radius: 3pt,
  fill: white,
  stroke: hair + 0.45pt,
  breakable: false,
)[
  #signal-strip(samples, fill: fill)
  #v(4pt)
  #text(size: 6.4pt, fill: mute)[#caption]
]

#let method-label(kicker, title, subtitle, accent: blackish) = block(width: 100%)[
  #label(kicker, fill: accent)
  #v(3pt)
  #text(size: 12.2pt, weight: "medium", fill: ink)[#title]
  #v(2pt)
  #text(size: 7.3pt, fill: mute)[#subtitle]
]

#let column-head(title, subtitle) = block(width: 100%)[
  #text(size: 7.6pt, weight: "bold", fill: ink)[#title]
  #v(1.5pt)
  #text(size: 6.2pt, fill: mute)[#subtitle]
]

// =============================================================================
// Samples
// =============================================================================

#let full-current = (0.85, 0.85, 0.85, 0.85, 0.85, 0.85, 0.85, 0.85, 0.85, 0.85, 0.85, 0.85)
#let mid-current = (0.55, 0.55, 0.55, 0.55, 0.55, 0.55, 0.55, 0.55, 0.55, 0.55, 0.55, 0.55)
#let low-current = (0.25, 0.25, 0.25, 0.25, 0.25, 0.25, 0.25, 0.25, 0.25, 0.25, 0.25, 0.25)

#let pwm-high = (1, 1, 1, 1, 0, 1, 1, 1, 1, 0, 1, 1)
#let pwm-mid = (1, 1, 0, 0, 1, 1, 0, 0, 1, 1, 0, 0)
#let pwm-low = (1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1, 0)

#let hybrid-lowest = (0.25, 0, 0, 0, 0, 0.25, 0, 0, 0, 0, 0.25, 0)

#let blank-signal = (0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0)

// =============================================================================
// Matrix
// =============================================================================

#let signal-atlas() = block(
  width: 100%,
  inset: (x: 10pt, y: 9pt),
  radius: 4pt,
  fill: panel,
  stroke: hair + 0.6pt,
  breakable: false,
)[
  #grid(
    columns: (1.05fr, 1fr, 1fr, 1fr, 1fr),
    column-gutter: 7pt,
    row-gutter: 8pt,
    align: top,

    // Header row
    [],
    [#column-head([High output], [large delivered average])],
    [#column-head([Medium output], [lower delivered average])],
    [#column-head([Low output], [near lower range])],
    [#column-head([Very low output], [deep dimming behavior])],

    // CCR row
    [
      #method-label(
        [analog LED dimming],
        [CCR],
        [height changes],
        accent: green,
      )
    ],
    [
      #signal-cell(
        full-current,
        [continuous high current],
        fill: green,
      )
    ],
    [
      #signal-cell(
        mid-current,
        [continuous reduced current],
        fill: green,
      )
    ],
    [
      #signal-cell(
        low-current,
        [continuous low current],
        fill: green,
      )
    ],
    [
      #signal-cell(
        low-current,
        [still analog if driver supports it],
        fill: green,
      )
    ],

    // PWM row
    [
      #method-label(
        [pulsed LED dimming],
        [PWM],
        [width changes],
        accent: violet,
      )
    ],
    [
      #signal-cell(
        pwm-high,
        [long on-time],
        fill: violet,
      )
    ],
    [
      #signal-cell(
        pwm-mid,
        [balanced on/off],
        fill: violet,
      )
    ],
    [
      #signal-cell(
        pwm-low,
        [short on-time],
        fill: violet,
      )
    ],
    [
      #signal-cell(
        pwm-low,
        [same peak, very low duty],
        fill: violet,
      )
    ],

    // Hybrid row
    [
      #method-label(
        [combined strategy],
        [Hybrid],
        [height first, then width],
        accent: blue,
      )
    ],
    [
      #signal-cell(
        full-current,
        [upper range: CCR],
        fill: blue,
      )
    ],
    [
      #signal-cell(
        mid-current,
        [middle range: CCR],
        fill: blue,
      )
    ],
    [
      #signal-cell(
        low-current,
        [analog floor],
        fill: blue,
      )
    ],
    [
      #signal-cell(
        hybrid-lowest,
        [PWM below the floor],
        fill: blue,
      )
    ],
  )
]

// =============================================================================
// Section
// =============================================================================

== Dimming Is Not Just “Less Power”

#section-intro(
  [dimming],
  [The same visible level can come from different electrical signals.],
  [
    For LEDs, “less light” does not identify the mechanism. One driver lowers
    current. Another keeps peak current high and shortens on-time. A hybrid driver
    may reduce current first, then switch to pulses at the bottom of the range.
  ],
  accent: amber,
  title-size: 27pt,
)

#v(9pt)

#grid(
  columns: (1fr, 1fr, 1fr),
  column-gutter: 8pt,
  align: top,

  [
    #rule-card(
      [read left to right],
      [Each strip is current over time. Bar height is current. Pale bars are off-time.],
      accent: blackish,
    )
  ],

  [
    #rule-card(
      [CCR],
      [Dimming changes height: same time profile, lower current level.],
      accent: green,
    )
  ],

  [
    #rule-card(
      [PWM],
      [Dimming changes width: same peak current, shorter on-time.],
      accent: violet,
    )
  ],
)

#v(10pt)

#signal-atlas()

#v(10pt)

#grid(
  columns: (1fr, 1fr, 1fr),
  column-gutter: 8pt,
  align: top,

  [
    #rule-card(
      [constant-current reduction],
      [The signal stays continuous. Lower output is created by lowering the current level.],
      accent: green,
    )
  ],

  [
    #rule-card(
      [pulse-width modulation],
      [The signal breaks into time slices. Lower output is created by reducing duty cycle.],
      accent: violet,
    )
  ],

  [
    #rule-card(
      [hybrid handoff],
      [The driver behaves like CCR through much of the range, then like PWM below the analog floor.],
      accent: blue,
    )
  ],
)

#v(10pt)

#bottom-takeaway(
  [dimming rule],
  [
    “Dimmed” is not a complete specification for an LED source. The visual result
    may be similar, but the current waveform can be continuous, pulsed, or hybrid.
    Less light does not tell you what the driver is doing.
  ],
  accent: violet,
)
