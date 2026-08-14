// Fragment: three spectral states.
//
// Expresses circadian lighting as a sequence of changing spectral jobs:
// daytime activation, evening transition, and nighttime protection.

#import "components.typ": *
#import "spectrum.typ": *

#let state-row(
  kicker,
  title,
  values,
  stroke,
  accent,
  principle,
  visual-body,
  clock-body,
) = block(
  width: 100%,
  inset: (x: 8pt, y: 6pt),
  radius: 4pt,
  fill: white,
  stroke: hair + 0.55pt,
  breakable: false,
)[
  #grid(
    columns: (0.20fr, 0.49fr, 0.155fr, 0.155fr),
    column-gutter: 9pt,
    align: top,
    [
      #label(kicker, fill: accent)
      #v(3pt)
      #text(size: 15pt, weight: "semibold", fill: ink)[#title]
      #v(5pt)
      #note(principle, size: 7.1pt)
    ],
    [
      #spectrum-plot(
        wl,
        height: 3.15cm,
        legend-position: "none",
        xlabel: text(size: 5.2pt)[Wavelength / nm],
        ylabel: text(size: 5.2pt)[Relative power],
        series: with-reference-overlays(((
          label: [],
          values: values,
          stroke: stroke,
          draw-area: true,
          z: 2,
        ),)),
      )
    ],
    [#small-rule-note([visual], visual-body, accent: ref-visual)],
    [#small-rule-note([clock], clock-body, accent: violet)],
  )
]

// =============================================================================
// Three spectral states
// =============================================================================

#grid(
  columns: (0.38fr, 0.62fr),
  column-gutter: 13pt,
  align: top,

  [
    #section-intro(
      [day structure],
      [Good lighting is a function.],
      [The design target is not one optimized white spectrum. It is a day that changes spectral job.],
      accent: blue,
      title-size: 28pt,
    )
  ],

  [
    #callout-card(
      [from dimming],
      [Quantity is not character.],
      [Dimming changes how much light the ipRGC receives. It does not change the spectral efficiency of what remains. A dimmed blue-pump LED is still a blue-pump LED.],
      accent: blackish,
      fill: faint,
      inset-y: 8pt,
    )
  ],
)

#v(8pt)

#state-row(
  [state 01],
  [Awake Daytime],
  day-state,
  1.0pt + blue,
  blue,
  [Drive the ipRGC signal when the body needs it.],
  [High visual output with broad white appearance for work, orientation, and task performance.],
  [Intentional blue-cyan presence activates melanopsin, suppresses melatonin, and anchors the SCN to daytime.],
)

#v(7pt)

#state-row(
  [state 02],
  [Evening Transition],
  evening-state,
  1.0pt + amber,
  amber,
  [Separate visual comfort from circadian activation.],
  [Warm, usable, socially comfortable light — sufficient for faces, tasks, and hospitality.],
  [Short-wavelength content is reduced so ipRGC drive falls and melatonin can rise ahead of sleep.],
)

#v(7pt)

#state-row(
  [state 03],
  [Restful Nighttime],
  night-state,
  1.0pt + red,
  red,
  [Withdraw the ipRGC signal as completely as possible.],
  [Minimal task light: navigation, safety, and orientation only. Not a room-filling scene.],
  [Blue-cyan energy is minimized as the primary design goal, not as a cosmetic warmth decision.],
)

#v(7pt)

#grid(
  columns: (auto, 1fr),
  column-gutter: 12pt,
  align: horizon,

  [
    #reference-overlay-key()
  ],

  [
    #note(size: 7.7pt)[
      The reference curves stay on every state so the reader sees the same rule repeated: visual brightness and clock activation are overlapping but different readings of the same spectrum.
    ]
  ],
)
