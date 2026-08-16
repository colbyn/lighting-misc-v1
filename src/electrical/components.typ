// =============================================================================
// Shared electrical presentation components
// =============================================================================
//
// Reusable visual grammar for electrical / control sections.
//
// Global page geometry and document typography are owned by main.typ.
// General-purpose colors and typography components are owned by
// spectra/components.typ.
//
// Keep rendered section narrative in the individual electrical/*.typ files.

#import "../spectra/components.typ": ink, mute, hair, faint, white, amber, green, violet, blue, red, blackish, label, headline, note

// =============================================================================
// General electrical cards
// =============================================================================

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

// =============================================================================
// Signal-strip grammar
// =============================================================================

#let signal-strip(
  samples,
  height: 31pt,
  fill: blackish,
  zero-fill: hair,
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
  zero-fill: hair,
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
// Signal samples
// =============================================================================

#let full-current = (
  0.85, 0.85, 0.85, 0.85, 0.85, 0.85,
  0.85, 0.85, 0.85, 0.85, 0.85, 0.85,
)

#let mid-current = (
  0.55, 0.55, 0.55, 0.55, 0.55, 0.55,
  0.55, 0.55, 0.55, 0.55, 0.55, 0.55,
)

#let low-current = (
  0.25, 0.25, 0.25, 0.25, 0.25, 0.25,
  0.25, 0.25, 0.25, 0.25, 0.25, 0.25,
)

#let pwm-high = (
  1, 1, 1, 1, 0, 1,
  1, 1, 1, 0, 1, 1,
)

#let pwm-mid = (
  1, 1, 0, 0, 1, 1,
  0, 0, 1, 1, 0, 0,
)

#let pwm-low = (
  1, 0, 0, 0, 0, 1,
  0, 0, 0, 0, 1, 0,
)

#let hybrid-lowest = (
  0.25, 0, 0, 0, 0, 0.25,
  0, 0, 0, 0, 0.25, 0,
)

// Longer samples for expanded teaching plates.

#let mid-current-long = (
  0.55, 0.55, 0.55, 0.55, 0.55, 0.55, 0.55, 0.55,
  0.55, 0.55, 0.55, 0.55, 0.55, 0.55, 0.55, 0.55,
)

#let pwm-mid-long = (
  1, 1, 0, 0, 1, 1, 0, 0,
  1, 1, 0, 0, 1, 1, 0, 0,
)

// =============================================================================
// CCR / PWM / hybrid comparison
// =============================================================================

#let signal-atlas() = block(
  width: 100%,
  inset: (x: 10pt, y: 9pt),
  radius: 4pt,
  fill: faint,
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

// =============================================================================
// Current → light response graphics
// =============================================================================

#let clamp01(x) = calc.min(1.0, calc.max(0.0, x))

#let response-bar(
  value,
  fill: blackish,
  track: faint,
  height: 8pt,
) = block(width: 100%)[
  #grid(
    columns: (
      clamp01(value) * 1fr,
      (1.0 - clamp01(value)) * 1fr,
    ),
    column-gutter: 0pt,
    [#rect(width: 100%, height: height, fill: fill, radius: 1pt)],
    [#rect(width: 100%, height: height, fill: track, radius: 1pt)],
  )
]

#let split-row(
  kicker,
  photons,
  heat,
  note-body,
  accent: blackish,
) = block(
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
        columns: (
          calc.max(0.02, photons) * 1fr,
          calc.max(0.02, heat) * 1fr,
        ),
        column-gutter: 2pt,

        [
          #rect(
            width: 100%,
            height: 17pt,
            fill: faint,
            stroke: accent + 0.45pt,
            radius: 2pt,
          )[
            #align(center + horizon)[
              #text(size: 6.6pt, fill: accent)[photons]
            ]
          ]
        ],

        [
          #rect(
            width: 100%,
            height: 17pt,
            fill: faint,
            stroke: red + 0.45pt,
            radius: 2pt,
          )[
            #align(center + horizon)[
              #text(size: 6.6pt, fill: red)[heat]
            ]
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
  fill: faint,
  stroke: hair + 0.6pt,
  breakable: false,
)[
  #grid(
    columns: (0.27fr, 1fr),
    column-gutter: 14pt,
    align: top,

    [
      #label([electrical input], fill: amber)
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
        accent: amber,
      )
    ],
  )
]

#let response-cell(
  kicker,
  current,
  light,
  heat,
  caption,
  accent: blackish,
) = block(
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
    [#response-bar(current, fill: accent, height: 7pt)],

    [#text(size: 6.5pt, fill: mute)[light]],
    [#response-bar(light, fill: green, height: 7pt)],

    [#text(size: 6.5pt, fill: mute)[heat]],
    [#response-bar(heat, fill: red, height: 7pt)],
  )

  #v(6pt)
  #note(caption, size: 6.9pt)
]

#let current-response-card() = block(
  width: 100%,
  inset: (x: 10pt, y: 9pt),
  radius: 4pt,
  fill: faint,
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

        [
          #response-cell(
            [soft drive],
            0.28,
            0.32,
            0.18,
            [Low current is often efficient, but absolute output is small.],
            accent: green,
          )
        ],

        [
          #response-cell(
            [rated drive],
            0.62,
            0.66,
            0.42,
            [The normal operating region balances output, efficacy, and lifetime.],
            accent: blue,
          )
        ],

        [
          #response-cell(
            [overdrive],
            0.95,
            0.86,
            0.78,
            [Current keeps rising; useful light rises less cleanly than heat.],
            accent: amber,
          )
        ],
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
  fill: faint,
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
            [
              #consequence-chip(
                [peak current],
                [Lower peak; lower instantaneous stress.],
                accent: green,
              )
            ],
            [
              #consequence-chip(
                [time structure],
                [Continuous emission; no off-gaps in the signal.],
                accent: green,
              )
            ],
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
            [
              #consequence-chip(
                [peak current],
                [Full peak remains; only duty cycle changes.],
                accent: violet,
              )
            ],
            [
              #consequence-chip(
                [time structure],
                [Emission arrives in bursts; the average is visual.],
                accent: violet,
              )
            ],
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
      #note(
        [For a simplified teaching model, delivered light follows the area under the current-time signal.],
        size: 6.9pt,
      )
    ],

    [
      #signal-cell(
        mid-current,
        [lower height × full time],
        fill: green,
      )
    ],

    [
      #signal-cell(
        pwm-mid,
        [full height × half time],
        fill: violet,
      )
    ],

    [
      #signal-cell(
        hybrid-lowest,
        [low height × short time],
        fill: blue,
      )
    ],
  )
]

