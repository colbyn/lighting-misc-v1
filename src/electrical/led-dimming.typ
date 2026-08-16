// =============================================================================
// Electrical section: Dimming Is Not Just “Less Power”
// =============================================================================
//
// Shared electrical presentation components live in components.typ.
// Global page geometry / typography come from main.typ.

#import "../spectra/components.typ": amber, green, violet, blackish, section-intro
#import "components.typ": rule-card, signal-atlas

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
      [Each strip is current over time. Bar height is current. Muted bars are off-time.],
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

