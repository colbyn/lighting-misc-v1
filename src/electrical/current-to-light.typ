// =============================================================================
// Electrical section: Current Is Not the Same Thing as Light
// =============================================================================
//
// Page-local composition and teaching plates only.
// Shared visual grammar comes from spectra/components.typ.
// Shared electrical primitives come from electrical/components.typ.

#import "../spectra/components.typ": *
#import "components.typ": (
  split-row,
  response-cell,
  expanded-row,
  consequence-chip,
  signal-cell,
  mid-current,
  pwm-mid,
  hybrid-lowest,
  mid-current-long,
  pwm-mid-long,
)

// =============================================================================
// Page-local helpers
// =============================================================================

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

// =============================================================================
// Current Is Not the Same Thing as Light
// =============================================================================

#pagebreak()

#grid(
  columns: (0.32fr, 0.68fr),
  column-gutter: 13pt,
  align: top,

  // ---------------------------------------------------------------------------
  // LEFT — distinguish control signal from optical result
  // ---------------------------------------------------------------------------

  [
    #section-intro(
      [current → light],
      [Current is the control signal. Light is the result.],
      [
        LED dimming begins electrically, but electrical current, optical output,
        heat, and time structure are not interchangeable quantities. The driver
        determines the current waveform; the LED package determines what that
        waveform becomes.
      ],
      accent: amber,
      title-size: 25pt,
    )

    #v(9pt)

    #callout-card(
      [conversion chain],
      [Electrical input is only the beginning.],
      [
        Driver current enters the LED package. Some of that electrical input
        becomes optical output and the remainder becomes heat. The relationship
        is strong, but it is not one-to-one.
      ],
      accent: amber,
      fill: faint,
      inset-x: 9pt,
      inset-y: 8pt,
    )

    #v(8pt)

    #callout-card(
      [drive response],
      [More current does not buy light at a fixed rate.],
      [
        At moderate drive levels, additional current produces additional light
        efficiently. As the operating point rises, junction temperature and
        efficiency droop make each added increment of current less productive.
      ],
      accent: blue,
      inset-y: 7pt,
    )

    #v(8pt)

    #callout-card(
      [same visible average],
      [Equal output can hide different instantaneous conditions.],
      [
        CCR can deliver a lower continuous current while PWM can preserve full
        peak current and reduce duty cycle. The time-averaged visible result may
        be similar even though the diode, driver, camera, and thermal system see
        different waveforms.
      ],
      accent: violet,
      fill: faint,
      inset-y: 7pt,
    )

    #v(9pt)

    #bottom-takeaway(
      [electrical rule],
      [
        Do not infer the electrical state from the visible level alone. Follow
        the chain from current waveform to optical output, heat, and time-average
        behavior.
      ],
      accent: amber,
    )
  ],

  // ---------------------------------------------------------------------------
  // RIGHT — follow the conversion and compare equivalent averages
  // ---------------------------------------------------------------------------

  [
    #page-kicker(
      [from electrical input to delivered light],
      accent: amber,
    )

    #v(6pt)

    #energy-split-card()

    #v(7pt)

    #current-response-card()

    #v(7pt)

    #same-average-card()

    #v(7pt)

    #photon-dose-card()
  ],
)

