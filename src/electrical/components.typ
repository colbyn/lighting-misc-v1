// =============================================================================
// Shared electrical presentation primitives
// =============================================================================
//
// Reusable electrical / control visual grammar only.
//
// Global page geometry and document typography are owned by main.typ.
// General-purpose colors and typography components are owned by
// spectra/components.typ.
//
// Page-specific compositions — such as the CCR/PWM atlas or current-to-light
// teaching plates — belong in the section files that render them.

#import "../spectra/components.typ": ink, mute, hair, faint, white, green, violet, blue, red, blackish, label, note

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

#let signal-cell(
  samples,
  caption,
  fill: blackish,
) = block(
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

#let method-label(
  kicker,
  title,
  subtitle,
  accent: blackish,
) = block(width: 100%)[
  #label(kicker, fill: accent)
  #v(3pt)
  #text(size: 12.2pt, weight: "medium", fill: ink)[#title]
  #v(2pt)
  #text(size: 7.3pt, fill: mute)[#subtitle]
]

#let column-head(
  title,
  subtitle,
) = block(width: 100%)[
  #text(size: 7.6pt, weight: "bold", fill: ink)[#title]
  #v(1.5pt)
  #text(size: 6.2pt, fill: mute)[#subtitle]
]

// =============================================================================
// Signal samples
// =============================================================================
//
// These are illustrative waveform samples used across electrical teaching
// graphics. Keep the signal data here so individual pages do not duplicate it.

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

#let mid-current-long = (
  0.55, 0.55, 0.55, 0.55, 0.55, 0.55, 0.55, 0.55,
  0.55, 0.55, 0.55, 0.55, 0.55, 0.55, 0.55, 0.55,
)

#let pwm-mid-long = (
  1, 1, 0, 0, 1, 1, 0, 0,
  1, 1, 0, 0, 1, 1, 0, 0,
)

// =============================================================================
// Expanded waveform row
// =============================================================================

#let expanded-row(
  title,
  subtitle,
  samples,
  fill: blackish,
) = block(
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
// Normalized response bars
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

    [
      #rect(
        width: 100%,
        height: height,
        fill: fill,
        radius: 1pt,
      )
    ],

    [
      #rect(
        width: 100%,
        height: height,
        fill: track,
        radius: 1pt,
      )
    ],
  )
]

// =============================================================================
// Electrical comparison primitives
// =============================================================================

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

#let consequence-chip(
  kicker,
  body,
  accent: blackish,
) = block(
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

