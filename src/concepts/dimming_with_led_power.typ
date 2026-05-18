// =============================================================================
// Standalone section: Dimming Is Not Just “Less Power”
// =============================================================================

#import "lib/spd-plot.typ": spectrum-plot

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
#let off-fill = luma(235)

#let amber = rgb("#bd6a00")
#let green = rgb("#3a9a00")
#let violet = rgb("#7a3cff")
#let blue = rgb("#005eff")
#let blackish = rgb("#111111")

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

#let big-signal-strip(
  samples,
  fill: blackish,
  height: 50pt,
  zero-fill: off-fill,
) = signal-strip(
  samples,
  height: height,
  fill: fill,
  zero-fill: zero-fill,
  radius: 0.7pt,
  gutter: 1.6pt,
)

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

// Longer samples for expanded teaching plates.
#let full-current-long = (
  0.85, 0.85, 0.85, 0.85, 0.85, 0.85, 0.85, 0.85,
  0.85, 0.85, 0.85, 0.85, 0.85, 0.85, 0.85, 0.85,
)

#let mid-current-long = (
  0.55, 0.55, 0.55, 0.55, 0.55, 0.55, 0.55, 0.55,
  0.55, 0.55, 0.55, 0.55, 0.55, 0.55, 0.55, 0.55,
)

#let low-current-long = (
  0.25, 0.25, 0.25, 0.25, 0.25, 0.25, 0.25, 0.25,
  0.25, 0.25, 0.25, 0.25, 0.25, 0.25, 0.25, 0.25,
)

#let pwm-high-long = (
  1, 1, 1, 1, 0, 1, 1, 1,
  1, 0, 1, 1, 1, 1, 0, 1,
)

#let pwm-mid-long = (
  1, 1, 0, 0, 1, 1, 0, 0,
  1, 1, 0, 0, 1, 1, 0, 0,
)

#let pwm-low-long = (
  1, 0, 0, 0, 0, 1, 0, 0,
  0, 0, 1, 0, 0, 0, 0, 0,
)

#let hybrid-lowest-long = (
  0.25, 0, 0, 0, 0, 0.25, 0, 0,
  0, 0, 0.25, 0, 0, 0, 0, 0,
)

// =============================================================================
// Compact atlas
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
        [still analog if supported],
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
        [same peak, low duty],
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
        [PWM below floor],
        fill: blue,
      )
    ],
  )
]

// =============================================================================
// Expanded method plates
// =============================================================================

#let expanded-row(title, subtitle, samples, fill: blackish) = block(
  width: 100%,
  inset: (x: 8pt, y: 7pt),
  radius: 3pt,
  fill: white,
  stroke: hair + 0.45pt,
  breakable: false,
)[
  #grid(
    columns: (0.26fr, 1fr),
    column-gutter: 10pt,
    align: horizon,

    [
      #text(size: 8.8pt, weight: "medium", fill: ink)[#title]
      #v(2pt)
      #text(size: 6.8pt, fill: mute)[#subtitle]
    ],

    [
      #big-signal-strip(samples, fill: fill)
    ],
  )
]

#let method-plate(
  kicker,
  title,
  claim,
  body,
  rows,
  accent: blackish,
) = block(
  width: 100%,
  inset: (x: 11pt, y: 10pt),
  radius: 4pt,
  fill: panel,
  stroke: hair + 0.6pt,
  breakable: false,
)[
  #grid(
    columns: (0.31fr, 1fr),
    column-gutter: 16pt,
    align: top,

    [
      #label(kicker, fill: accent)
      #v(4pt)
      #headline(title, size: 20pt)
      #v(5pt)
      #text(size: 9.2pt, weight: "medium", fill: ink)[#claim]
      #v(7pt)
      #note(body, size: 7.7pt)
    ],

    [
      #rows
    ],
  )
]

#let compare-pill(a, b, c, accent: blackish) = block(
  width: 100%,
  inset: (x: 9pt, y: 8pt),
  radius: 3pt,
  fill: white,
  stroke: hair + 0.55pt,
  breakable: false,
)[
  #grid(
    columns: (0.25fr, 0.25fr, 1fr),
    column-gutter: 8pt,
    align: horizon,

    [#label(a, fill: accent)],
    [#text(size: 10.5pt, weight: "semibold", fill: ink)[#b]],
    [#note(c, size: 7.2pt)],
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

#bottom-takeaway(
  [visual thesis],
  [
    CCR changes current height. PWM changes on-time width. Hybrid dimming changes
    height first, then switches to width at the low end.
  ],
  accent: blue,
)

#pagebreak()

#section-intro(
  [method plates],
  [The waveform tells you what “dimmed” actually means.],
  [
    The visible scene can be equally dim in each case, but the driver can be doing
    very different work. These enlarged strips keep the same grammar as the atlas:
    height is current, width is on-time, pale bars are off-time.
  ],
  accent: blackish,
  title-size: 25pt,
)

#v(10pt)

#method-plate(
  [analog LED dimming],
  [CCR],
  [Same time profile, lower current level.],
  [
    Constant-current reduction keeps the LED continuously driven while lowering
    the current. The signal does not break into pulses; it simply operates the
    diode at a lower current level.
  ],
  [
    #expanded-row(
      [High output],
      [higher continuous current],
      full-current-long,
      fill: green,
    )

    #v(7pt)

    #expanded-row(
      [Medium output],
      [reduced continuous current],
      mid-current-long,
      fill: green,
    )

    #v(7pt)

    #expanded-row(
      [Low output],
      [low continuous current],
      low-current-long,
      fill: green,
    )
  ],
  accent: green,
)

#v(10pt)

#method-plate(
  [pulsed LED dimming],
  [PWM],
  [Same peak current, less time on.],
  [
    Pulse-width modulation keeps the LED near a peak operating current while
    reducing the fraction of time it is on. Output falls because duty cycle falls.
    The peak bars stay tall; the on-time becomes shorter.
  ],
  [
    #expanded-row(
      [High output],
      [long on-time],
      pwm-high-long,
      fill: violet,
    )

    #v(7pt)

    #expanded-row(
      [Medium output],
      [balanced on/off time],
      pwm-mid-long,
      fill: violet,
    )

    #v(7pt)

    #expanded-row(
      [Low output],
      [short pulses],
      pwm-low-long,
      fill: violet,
    )
  ],
  accent: violet,
)


#v(10pt)

#method-plate(
  [combined strategy],
  [Hybrid],
  [Current reduction first, PWM below the analog floor.],
  [
    Hybrid drivers use CCR through the range where analog reduction behaves well.
    At the low end, the driver may hold an analog floor and continue dimming by
    pulsing that floor.
  ],
  [
    #expanded-row(
      [High output],
      [upper range: CCR],
      full-current-long,
      fill: blue,
    )

    #v(7pt)

    #expanded-row(
      [Medium output],
      [middle range: CCR],
      mid-current-long,
      fill: blue,
    )

    #v(7pt)

    #expanded-row(
      [Low output],
      [analog floor],
      low-current-long,
      fill: blue,
    )

    #v(7pt)

    #expanded-row(
      [Very low output],
      [PWM below the floor],
      hybrid-lowest-long,
      fill: blue,
    )
  ],
  accent: blue,
)



// =============================================================================
// Section: Current Is Not the Same Thing as Light
// =============================================================================

#let orange = rgb("#d78700")
#let red = rgb("#c0332b")
#let cyan = rgb("#008aa8")

#let clamp01(x) = calc.min(1.0, calc.max(0.0, x))

#let metric-bar(value, fill: blackish, track: faint, height: 8pt) = block(width: 100%)[
  #grid(
    columns: (clamp01(value) * 1fr, (1.0 - clamp01(value)) * 1fr),
    column-gutter: 0pt,
    [#rect(width: 100%, height: height, fill: fill, radius: 1pt)],
    [#rect(width: 100%, height: height, fill: track, radius: 1pt)],
  )
]

#let split-row(kicker, photons, heat, note-body, accent: blackish) = block(
  width: 100%,
  inset: (x: 8pt, y: 7pt),
  radius: 3pt,
  fill: white,
  stroke: hair + 0.5pt,
  breakable: false,
)[
  #grid(
    columns: (0.25fr, 1fr, 0.27fr),
    column-gutter: 9pt,
    align: horizon,

    [
      #label(kicker, fill: accent)
    ],

    [
      #grid(
        columns: (calc.max(0.02, photons) * 1fr, calc.max(0.02, heat) * 1fr),
        column-gutter: 2pt,
        [
          #rect(width: 100%, height: 17pt, fill: accent.lighten(72%), stroke: accent + 0.45pt, radius: 2pt)[
            #align(center + horizon)[#text(size: 6.6pt, fill: accent)[photons]]
          ]
        ],
        [
          #rect(width: 100%, height: 17pt, fill: red.lighten(74%), stroke: red + 0.45pt, radius: 2pt)[
            #align(center + horizon)[#text(size: 6.6pt, fill: red)[heat]]
          ]
        ],
      )
    ],

    [
      #note(note-body, size: 6.9pt)
    ],
  )
]

#let energy-split-card() = block(
  width: 100%,
  inset: (x: 10pt, y: 9pt),
  radius: 4pt,
  fill: panel,
  stroke: hair + 0.6pt,
  breakable: false,
)[
  #grid(
    columns: (0.27fr, 1fr),
    column-gutter: 14pt,
    align: top,

    [
      #label([electrical input], fill: orange)
      #v(4pt)
      #headline([Current does not become light one-to-one.], size: 17pt)
      #v(5pt)
      #note([
        A driver controls current. The LED package converts part of that electrical
        input into photons and sheds the rest as heat. Higher drive current increases
        output, but the useful fraction does not stay fixed.
      ], size: 7.3pt)
    ],

    [
      #split-row(
        [low drive],
        0.72,
        0.28,
        [efficient region],
        accent: green,
      )
      #v(6pt)
      #split-row(
        [nominal drive],
        0.60,
        0.40,
        [normal working point],
        accent: blue,
      )
      #v(6pt)
      #split-row(
        [hard drive],
        0.46,
        0.54,
        [more heat penalty],
        accent: orange,
      )
    ],
  )
]

#let response-cell(kicker, current, light, heat, caption, accent: blackish) = block(
  width: 100%,
  inset: (x: 7pt, y: 7pt),
  radius: 3pt,
  fill: white,
  stroke: hair + 0.45pt,
  breakable: false,
)[
  #label(kicker, fill: accent)
  #v(5pt)
  #grid(
    columns: (0.28fr, 1fr),
    column-gutter: 7pt,
    row-gutter: 4pt,
    align: horizon,

    [#text(size: 6.5pt, fill: mute)[current]],
    [#metric-bar(current, fill: accent, height: 7pt)],

    [#text(size: 6.5pt, fill: mute)[light]],
    [#metric-bar(light, fill: green, height: 7pt)],

    [#text(size: 6.5pt, fill: mute)[heat]],
    [#metric-bar(heat, fill: red, height: 7pt)],
  )
  #v(6pt)
  #note(caption, size: 6.9pt)
]

#let current-response-card() = block(
  width: 100%,
  inset: (x: 10pt, y: 9pt),
  radius: 4pt,
  fill: panel,
  stroke: hair + 0.6pt,
  breakable: false,
)[
  #grid(
    columns: (0.31fr, 1fr),
    column-gutter: 13pt,
    align: top,

    [
      #label([drive response], fill: blue)
      #v(4pt)
      #headline([More current gives more light, then more penalty.], size: 17pt)
      #v(5pt)
      #note([
        The important curve bends. At ordinary currents, extra current mostly
        buys more output. Near the upper range, heat and efficiency droop take
        a larger share of the electrical input.
      ], size: 7.3pt)
    ],

    [
      #grid(
        columns: (1fr, 1fr, 1fr),
        column-gutter: 7pt,
        align: top,

        [#response-cell(
          [soft drive],
          0.28,
          0.32,
          0.18,
          [Low current is often efficient, but absolute output is small.],
          accent: green,
        )],

        [#response-cell(
          [rated drive],
          0.62,
          0.66,
          0.42,
          [The normal operating region balances output, efficacy, and lifetime.],
          accent: blue,
        )],

        [#response-cell(
          [overdrive],
          0.95,
          0.86,
          0.78,
          [Current keeps rising; useful light rises less cleanly than heat.],
          accent: orange,
        )],
      )
    ],
  )
]

#let consequence-chip(kicker, body, accent: blackish) = block(
  width: 100%,
  inset: (x: 7pt, y: 6pt),
  radius: 3pt,
  fill: white,
  stroke: hair + 0.45pt,
  breakable: false,
)[
  #label(kicker, fill: accent)
  #v(3pt)
  #note(body, size: 6.8pt)
]

#let same-average-card() = block(
  width: 100%,
  inset: (x: 10pt, y: 9pt),
  radius: 4pt,
  fill: panel,
  stroke: hair + 0.6pt,
  breakable: false,
)[
  #grid(
    columns: (0.30fr, 1fr),
    column-gutter: 13pt,
    align: top,

    [
      #label([same average], fill: violet)
      #v(4pt)
      #headline([Equal visible average can hide unequal peak stress.], size: 17pt)
      #v(5pt)
      #note([
        Two dimming methods can deliver a similar time-average output. The diode,
        camera, driver, and thermal stack still experience different instantaneous
        conditions.
      ], size: 7.3pt)
    ],

    [
      #grid(
        columns: (1fr, 1fr),
        column-gutter: 8pt,
        align: top,

        [
          #expanded-row(
            [CCR at 50%],
            [lower continuous current],
            mid-current-long,
            fill: green,
          )
          #v(6pt)
          #grid(
            columns: (1fr, 1fr),
            column-gutter: 6pt,
            [#consequence-chip([peak current], [Lower peak; lower instantaneous stress.], accent: green)],
            [#consequence-chip([time structure], [Continuous emission; no off-gaps in the signal.], accent: green)],
          )
        ],

        [
          #expanded-row(
            [PWM at 50%],
            [full current half the time],
            pwm-mid-long,
            fill: violet,
          )
          #v(6pt)
          #grid(
            columns: (1fr, 1fr),
            column-gutter: 6pt,
            [#consequence-chip([peak current], [Full peak remains; only duty cycle changes.], accent: violet)],
            [#consequence-chip([time structure], [Emission arrives in bursts; the average is visual.], accent: violet)],
          )
        ],
      )
    ],
  )
]

#let photon-dose-card() = block(
  width: 100%,
  inset: (x: 10pt, y: 9pt),
  radius: 4pt,
  fill: white,
  stroke: hair + 0.55pt,
  breakable: false,
)[
  #grid(
    columns: (0.23fr, 1fr, 1fr, 1fr),
    column-gutter: 8pt,
    align: top,

    [
      #label([area rule], fill: blackish)
      #v(3pt)
      #note([For a simplified teaching model, delivered light follows the area under the current-time signal.], size: 6.9pt)
    ],

    [#signal-cell(mid-current, [lower height × full time], fill: green)],
    [#signal-cell(pwm-mid, [full height × half time], fill: violet)],
    [#signal-cell(hybrid-lowest, [low height × short time], fill: blue)],
  )
]

// =============================================================================
// Spectral comparison: dimming behavior by source family
// =============================================================================

#let gaussian(x, center, width, amp: 1.0) = {
  let t = (x - center) / width
  amp * calc.exp(-0.5 * t * t)
}

#let map-values(xs, f) = {
  let out = ()
  for x in xs {
    out.push(f(x))
  }
  out
}

#let scale-values(values, factor) = {
  let out = ()
  for v in values {
    out.push(v * factor)
  }
  out
}

#let max-value(values) = {
  let m = 0.0
  for v in values {
    m = calc.max(m, v)
  }
  m
}

#let scale-to-reference(values, reference-max) = {
  let out = ()
  for v in values {
    out.push(if reference-max == 0 { 0 } else { v / reference-max })
  }
  out
}

// Simple idealized phosphor-white LED shape.
// The important teaching point: the shape stays stable; intensity changes.
#let led-base(l) = (
  gaussian(l, 450.0, 15.0, amp: 0.88) +
  gaussian(l, 560.0, 78.0, amp: 1.02) +
  gaussian(l, 620.0, 58.0, amp: 0.16)
)

// Simple idealized blackbody-like spectral model.
// Deliberately illustrative: lower filament temperature makes the source dimmer
// and shifts the visible balance toward longer wavelengths.
#let blackbody-radiance(l, temp) = {
  let lm = l * 1e-9
  let c2 = 1.4388e-2
  1.0 / (calc.pow(lm, 5) * (calc.exp(c2 / (lm * temp)) - 1.0))
}

#let source-wl = range(380, 781, step: 10)

// LED: normalize one full-output reference, then scale every dimmed curve from it.
// This makes the Y axis a shared intensity scale.
#let led-reference-raw = map-values(source-wl, l => led-base(l))
#let led-reference-max = max-value(led-reference-raw)
#let led-full = scale-to-reference(led-reference-raw, led-reference-max)
#let led-mid = scale-values(led-full, 0.55)
#let led-low = scale-values(led-full, 0.18)

// Incandescent: compute all temperatures in absolute blackbody-like units,
// then divide every curve by the full-output reference max.
// This preserves the visual drop in intensity and the warm spectral shift.
#let inc-full-raw = map-values(source-wl, l => blackbody-radiance(l, 2700.0))
#let inc-mid-raw = map-values(source-wl, l => blackbody-radiance(l, 2200.0))
#let inc-low-raw = map-values(source-wl, l => blackbody-radiance(l, 1800.0))

#let inc-reference-max = max-value(inc-full-raw)
#let inc-full = scale-to-reference(inc-full-raw, inc-reference-max)
#let inc-mid = scale-to-reference(inc-mid-raw, inc-reference-max)
#let inc-low = scale-to-reference(inc-low-raw, inc-reference-max)

#let led-dimming-series = (
  (
    label: [full output],
    values: led-full,
    stroke: blue + 1.25pt,
  ),
  (
    label: [medium output],
    values: led-mid,
    stroke: green + 1.1pt,
  ),
  (
    label: [low output],
    values: led-low,
    stroke: violet + 1.1pt,
  ),
)

#let inc-dimming-series = (
  (
    label: [full output],
    values: inc-full,
    stroke: amber + 1.25pt,
  ),
  (
    label: [medium output],
    values: inc-mid,
    stroke: orange + 1.1pt,
  ),
  (
    label: [low output],
    values: inc-low,
    stroke: red + 1.1pt,
  ),
)

#let spectral-compare-card(
  kicker,
  title,
  body,
  series,
  accent: blackish,
) = block(
  width: 100%,
  inset: (x: 10pt, y: 9pt),
  radius: 4pt,
  fill: panel,
  stroke: hair + 0.6pt,
  breakable: false,
)[
  #label(kicker, fill: accent)
  #v(4pt)
  #text(size: 14.5pt, weight: "medium", fill: ink)[#title]
  #v(4pt)
  #note(body, size: 7.1pt)
  #v(8pt)

  #spectrum-plot(
    source-wl,
    title: none,
    height: 6.25cm,
    legend-position: "bottom",
    xlabel: text(size: 6.4pt)[Wavelength / nm],
    ylabel: text(size: 6.4pt)[Spectral power relative to full output],
    ylim: (0, 1.08),
    series: series,
  )
]

#let mechanism-strip() = block(
  width: 100%,
  inset: (x: 10pt, y: 8pt),
  radius: 4pt,
  fill: white,
  stroke: hair + 0.55pt,
  breakable: false,
)[
  #grid(
    columns: (1fr, 1fr, 1fr),
    column-gutter: 8pt,
    align: top,

    [
      #label([LED + PWM], fill: violet)
      #v(3pt)
      #note([Same instantaneous SPD; lower time-averaged output.], size: 7.0pt)
    ],

    [
      #label([LED + CCR], fill: green)
      #v(3pt)
      #note([Nearly same SPD shape; lower continuous output.], size: 7.0pt)
    ],

    [
      #label([incandescent], fill: amber)
      #v(3pt)
      #note([Lower output and warmer spectrum because the filament cools.], size: 7.0pt)
    ],
  )
]

// =============================================================================
// Section
// =============================================================================


== Current Is Not the Same Thing as Light

#section-intro(
  [led power],
  [The driver controls current; the room receives photons, heat, and time structure.],
  [
    LED power is usually discussed through current because the diode is current-driven.
    But current is not the final visual product. The same electrical input is filtered
    through package efficiency, junction temperature, phosphor conversion, driver timing,
    and optics before it becomes useful light.
  ],
  accent: orange,
  title-size: 25pt,
)

#v(9pt)

#energy-split-card()

#v(9pt)

#current-response-card()

#v(9pt)

#bottom-takeaway(
  [section thesis],
  [
    Current is the control variable. Light output is the result after conversion losses,
    thermal behavior, spectral construction, and driver timing have all had their say.
  ],
  accent: orange,
)


#section-intro(
  [current over time],
  [Average light is not the same as instantaneous drive.],
  [
    Dimming often compares visible averages, but LEDs and cameras respond to the
    instantaneous waveform. The area under the current-time signal explains the
    average; the peaks and gaps explain stress, flicker, and driver behavior.
  ],
  accent: violet,
  title-size: 25pt,
)

#v(9pt)

#same-average-card()

#v(9pt)

#photon-dose-card()

#v(9pt)

#bottom-takeaway(
  [visual rule],
  [
    Area gives the simplified average. Shape gives the mechanism. A smooth half-current
    signal and a half-duty full-current signal can look similar while behaving differently.
  ],
  accent: violet,
)

#pagebreak()

#section-intro(
  [source behavior],
  [Dimming does not mean the same thing for every light source.],
  [
    “Less light” sounds like a simple quantity change, but the source physics matter.
    A white LED usually keeps roughly the same spectral recipe and emits less of it.
    An incandescent lamp does not. As it dims, it also gets warmer and shifts its
    spectral balance toward longer wavelengths.
  ],
  accent: cyan,
  title-size: 25pt,
)

#v(9pt)

#grid(
  columns: (1fr, 1fr),
  column-gutter: 10pt,
  align: top,

  [
    #spectral-compare-card(
      [white LED],
      [Dimming mostly changes intensity.],
      [
        In an LED system—especially with PWM, and often in well-behaved CCR—the
        emitted spectrum is substantially the same shape. The output falls, but the
        spectral construction is broadly stable.
      ],
      led-dimming-series,
      accent: blue,
    )
  ],

  [
    #spectral-compare-card(
      [incandescent / resistive lamp],
      [Dimming changes intensity and color.],
      [
        A thermal source dims by cooling. As temperature falls, short wavelengths
        collapse faster, the light appears warmer, and the spectral emphasis moves
        further toward longer wavelengths.
      ],
      inc-dimming-series,
      accent: amber,
    )
  ],
)

#v(8pt)

#mechanism-strip()

#v(8pt)

#grid(
  columns: (1fr, 1fr, 1fr),
  column-gutter: 8pt,
  align: top,

  [
    #rule-card(
      [LED takeaway],
      [The main change is amplitude. The source is usually “the same light, less of it.”],
      accent: blue,
    )
  ],

  [
    #rule-card(
      [incandescent takeaway],
      [The change is not only amplitude. The source itself gets warmer as it dims.],
      accent: amber,
    )
  ],

  [
    #rule-card(
      [axis matters],
      [The Y axis uses one shared full-output reference. Curves are not normalized independently.],
      accent: blackish,
    )
  ],
)

#v(10pt)

#bottom-takeaway(
  [visual thesis],
  [
    LED dimming is mostly a quantity story. Incandescent dimming is a quantity-and-spectrum story.
    That is why “dimming” should not be treated as one universal behavior across source types.
  ],
  accent: cyan,
)

