// =============================================================================
// Electrical section: Dimming Is Not Just “Less Power”
// =============================================================================
//
// Page-local composition only.
// Shared visual grammar comes from spectra/components.typ.
// Shared electrical primitives and waveform samples come from
// electrical/components.typ.

#import "../spectra/components.typ": *
#import "components.typ": (
  column-head,
  method-label,
  signal-cell,
  full-current,
  mid-current,
  low-current,
  pwm-high,
  pwm-mid,
  pwm-low,
  hybrid-lowest,
)

// =============================================================================
// Page-local helpers
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

// =============================================================================
// Dimming Is Not Just “Less Power”
// =============================================================================

#grid(
  columns: (0.32fr, 0.68fr),
  column-gutter: 13pt,
  align: top,

  // ---------------------------------------------------------------------------
  // LEFT — how to read the electrical signal
  // ---------------------------------------------------------------------------

  [
    #section-intro(
      [dimming],
      [The same visible level can come from different electrical signals.],
      [
        For LEDs, “less light” does not identify the mechanism. One driver lowers
        current. Another keeps peak current high and shortens on-time. A hybrid
        driver may reduce current first, then switch to pulses at the bottom of
        the range.
      ],
      accent: amber,
      title-size: 27pt,
    )

    #v(9pt)

    #callout-card(
      [reading rule],
      [Read the strip as current over time.],
      [
        Bar height represents instantaneous current. Horizontal position represents
        time. A lower bar means less current while the LED remains on; a missing
        bar means an off interval.
      ],
      accent: blackish,
      fill: faint,
      inset-x: 9pt,
      inset-y: 8pt,
    )

    #v(8pt)

    #callout-card(
      [CCR / analog dimming],
      [Change the height.],
      [
        Constant-current reduction lowers the drive current continuously. The
        waveform stays present through time, but its amplitude falls as the lamp
        is dimmed.
      ],
      accent: green,
      inset-y: 7pt,
    )

    #v(8pt)

    #callout-card(
      [PWM / pulsed dimming],
      [Change the width.],
      [
        Pulse-width modulation keeps the on-state near the same peak current and
        reduces average output by shortening how long the LED remains on during
        each cycle.
      ],
      accent: violet,
      fill: faint,
      inset-y: 7pt,
    )

    #v(8pt)

    #callout-card(
      [hybrid drivers],
      [Use both mechanisms across the range.],
      [
        A hybrid driver can use current reduction through the upper and middle
        range, then introduce PWM after the analog current reaches a practical
        lower limit.
      ],
      accent: blue,
      inset-y: 7pt,
    )
  ],

  // ---------------------------------------------------------------------------
  // RIGHT — compare the waveforms
  // ---------------------------------------------------------------------------

  [
    #page-kicker(
      [three ways to reduce delivered output],
      accent: amber,
    )

    #v(6pt)

    #signal-atlas()

    #v(9pt)

    #grid(
      columns: (1fr, 1fr, 1fr),
      column-gutter: 8pt,
      align: top,

      [
        #small-rule-note(
          [CCR],
          [
            The LED remains continuously driven. Dimming is represented mainly
            by lower current amplitude.
          ],
          accent: green,
        )
      ],

      [
        #small-rule-note(
          [PWM],
          [
            Peak current can remain high. Dimming is represented mainly by a
            smaller fraction of time spent on.
          ],
          accent: violet,
        )
      ],

      [
        #small-rule-note(
          [hybrid],
          [
            The driver changes strategy across its range rather than relying on
            one mechanism from full output to minimum.
          ],
          accent: blue,
        )
      ],
    )

    #v(9pt)

    #bottom-takeaway(
      [electrical rule],
      [
        A dimming percentage describes the requested average output, not the
        electrical waveform that produced it. To understand driver behavior,
        flicker, camera interaction, thermal loading, and deep-dimming quality,
        identify the mechanism as well as the level.
      ],
      accent: amber,
    )
  ],
)

