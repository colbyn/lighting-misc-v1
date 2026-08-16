// Fragment: three spectral states.
//
// Expresses circadian lighting as a sequence of changing spectral objectives:
// daytime support, evening transition, and nighttime protection.

#import "components.typ": *
#import "spectrum.typ": *

// =============================================================================
// Page-local helper
// =============================================================================

#let spectral-state-card(
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
  inset: (x: 8pt, y: 7pt),
  radius: 4pt,
  fill: white,
  stroke: hair + 0.55pt,
  breakable: false,
)[
  #grid(
    columns: (0.30fr, 0.70fr),
    column-gutter: 9pt,
    align: top,

    [
      #label(kicker, fill: accent)

      #v(3pt)

      #text(
        size: 13.5pt,
        weight: "semibold",
        fill: ink,
      )[
        #title
      ]

      #v(4pt)

      #note(
        principle,
        size: 6.9pt,
      )
    ],

    [
      #spectrum-plot(
        wl,
        height: 2.85cm,
        legend-position: "none",
        xlabel: text(size: 0pt)[],
        ylabel: text(size: 0pt)[],
        series: with-reference-overlays(((
          label: [],
          values: values,
          stroke: stroke,
          draw-area: true,
          z: 2,
        ),)),
      )
    ],
  )

  #v(5pt)

  #grid(
    columns: (1fr, 1fr),
    column-gutter: 8pt,
    align: top,

    [
      #small-rule-note(
        [visual task],
        visual-body,
        accent: ref-visual,
      )
    ],

    [
      #small-rule-note(
        [melanopic task],
        clock-body,
        accent: violet,
      )
    ],
  )
]

// =============================================================================
// Three spectral states
// =============================================================================

#grid(
  columns: (0.36fr, 0.64fr),
  column-gutter: 13pt,
  align: top,

  // ---------------------------------------------------------------------------
  // LEFT — operating logic
  // ---------------------------------------------------------------------------

  [
    #section-intro(
      [day structure],
      [Lighting should change as its biological role changes.],
      [
        A circadian lighting system is not defined by one preferred spectrum.
        It is defined by how light changes across the day as visual and
        biological requirements change.
      ],
      accent: blue,
      title-size: 24pt,
    )

    #v(10pt)

    #callout-card(
      [two control dimensions],
      [Intensity and spectrum solve different problems.],
      [
        Dimming changes the amount of light reaching the eye. Spectral control
        changes how that light is distributed by wavelength. Effective
        circadian lighting uses both rather than treating brightness as the
        only control variable.
      ],
      accent: violet,
      fill: faint,
      inset-x: 9pt,
      inset-y: 8pt,
    )

    #v(9pt)

    #callout-card(
      [day],
      [Support the biological daytime signal.],
      [
        During normal waking hours, lighting should provide adequate visual
        illumination together with a deliberate melanopic contribution.
        Short-wavelength energy is useful here rather than something to avoid.
      ],
      accent: blue,
      inset-y: 8pt,
    )

    #v(9pt)

    #callout-card(
      [evening],
      [Reduce melanopic exposure before removing useful light.],
      [
        As bedtime approaches, the objective changes. The system should retain
        enough illumination for ordinary activity while progressively reducing
        both overall exposure and melanopic efficiency.
      ],
      accent: amber,
      inset-y: 8pt,
    )

    #v(9pt)

    #callout-card(
      [night],
      [Treat illumination as an exception.],
      [
        During the sleep period, general room lighting is no longer the design
        target. Necessary light should be limited to navigation, safety, and
        essential tasks, with both intensity and short-wavelength content kept
        low.
      ],
      accent: red,
      fill: faint,
      inset-y: 8pt,
    )

    #v(8pt)

    #bottom-takeaway(
      [design principle],
      [
        The transition from day to night is not simply a dimming curve.
        It is a change in both the required quantity of light and the spectral
        character of that light.
      ],
      accent: violet,
    )
  ],

  // ---------------------------------------------------------------------------
  // RIGHT — operating states
  // ---------------------------------------------------------------------------

  [
    #page-kicker(
      [three operating states],
      accent: violet,
    )

    #v(6pt)

    #spectral-state-card(
      [state 01],
      [Active daytime],
      day-state,
      1.0pt + blue,
      blue,
      [
        Provide useful visual illumination together with a strong daytime
        melanopic signal.
      ],
      [
        Broad white light supports work, movement, color discrimination, and
        normal daytime visual tasks.
      ],
      [
        Short- and middle-wavelength content remains substantial, producing
        melanopic exposure appropriate to the biological day.
      ],
    )

    #v(7pt)

    #spectral-state-card(
      [state 02],
      [Evening transition],
      evening-state,
      1.0pt + amber,
      amber,
      [
        Preserve visual utility while deliberately reducing melanopic exposure.
      ],
      [
        Warm, comfortable illumination remains available for faces,
        circulation, social activity, and routine evening tasks.
      ],
      [
        Short-wavelength output is reduced so melanopic stimulus declines as
        the lighting environment approaches biological night.
      ],
    )

    #v(7pt)

    #spectral-state-card(
      [state 03],
      [Biological night],
      night-state,
      1.0pt + red,
      red,
      [
        Minimize exposure when artificial light is still operationally required.
      ],
      [
        Light is limited to navigation, orientation, safety, and essential
        low-demand tasks rather than general illumination.
      ],
      [
        Blue-cyan content is strongly constrained so necessary visibility
        produces as little melanopic stimulus as practical.
      ],
    )

    #v(7pt)

    #page-kicker(
      [fixed references, changing source],
      accent: blackish,
    )

    #v(5pt)

    #reference-overlay-key()

    #v(5pt)

    #note(
      size: 7.3pt,
      fill: mute,
    )[
      The reference curves remain unchanged across all three states. What
      changes is the source spectrum: broad daytime output gives way to
      progressively lower short-wavelength content as the lighting system
      moves toward biological night.
    ]
  ],
)
