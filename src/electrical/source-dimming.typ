// =============================================================================
// Electrical section: Source Dimming Behavior
// =============================================================================
//
// Page-local composition and source-dimming transforms only.
// Shared visual grammar comes from spectra/components.typ.
// Shared spectral computation / source models come from spectra/spectrum.typ.

#import "../spectra/components.typ": *
#import "../spectra/spectrum.typ": spectrum-plot, wl, neutral-led, blackbody

// =============================================================================
// Page-local spectral helpers
// =============================================================================

#let scale-values(values, factor) = values.map(v => v * factor)

#let scale-to-reference(values, reference-max) = values.map(
  v => if reference-max == 0 { 0 } else { v / reference-max }
)

// LED: keep the common neutral-LED spectral recipe and scale amplitude only.
#let led-full = neutral-led
#let led-mid = scale-values(led-full, 0.55)
#let led-low = scale-values(led-full, 0.18)

// Incandescent: evaluate the common blackbody model at progressively lower
// filament temperatures, then preserve one shared full-output reference.
#let inc-full-raw = wl.map(l => blackbody(l, 2700.0))
#let inc-mid-raw = wl.map(l => blackbody(l, 2200.0))
#let inc-low-raw = wl.map(l => blackbody(l, 1800.0))

#let inc-reference-max = calc.max(..inc-full-raw)

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
    stroke: blackish + 1.25pt,
  ),
  (
    label: [medium output],
    values: inc-mid,
    stroke: amber + 1.1pt,
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
  plot-height: 5.45cm,
) = block(
  width: 100%,
  inset: (x: 8pt, y: 7pt),
  radius: 4pt,
  fill: white,
  stroke: hair + 0.55pt,
  breakable: false,
)[
  #label(kicker, fill: accent)

  #v(3pt)

  #text(
    size: 11.6pt,
    weight: "semibold",
    fill: ink,
  )[
    #title
  ]

  #v(4pt)

  #spectrum-plot(
    wl,
    title: none,
    height: plot-height,
    legend-position: "bottom",
    legend-columns: (auto, auto, auto),
    xlabel: text(size: 5.0pt)[Wavelength / nm],
    ylabel: text(size: 5.0pt)[Spectral power relative to full output],
    ylim: (0, 1.08),
    series: series,
  )

  #v(4pt)

  #note(
    body,
    size: 6.65pt,
  )
]

#let mechanism-strip() = block(
  width: 100%,
  inset: (x: 8pt, y: 7pt),
  radius: 4pt,
  fill: faint,
  stroke: hair + 0.55pt,
  breakable: false,
)[
  #grid(
    columns: (1fr, 1fr, 1fr),
    column-gutter: 8pt,
    align: top,

    [
      #small-rule-note(
        [LED + PWM],
        [Same instantaneous SPD; lower time-averaged output.],
        accent: violet,
      )
    ],

    [
      #small-rule-note(
        [LED + CCR],
        [Nearly the same SPD shape; lower continuous output.],
        accent: green,
      )
    ],

    [
      #small-rule-note(
        [incandescent],
        [Lower output and a warmer spectrum because the filament cools.],
        accent: amber,
      )
    ],
  )
]

// =============================================================================
// Source Dimming Behavior
// =============================================================================

#pagebreak()

#grid(
  columns: (0.34fr, 0.66fr),
  column-gutter: 13pt,
  align: top,

  // ---------------------------------------------------------------------------
  // LEFT — why source physics matters
  // ---------------------------------------------------------------------------

  [
    #section-intro(
      [source behavior],
      [Dimming does not mean the same thing for every light source.],
      [
        “Less light” sounds like a simple quantity change, but the source physics
        matter. A white LED usually keeps roughly the same spectral recipe and
        emits less of it. An incandescent lamp does not: as it dims, it also gets
        warmer and shifts its spectral balance toward longer wavelengths.
      ],
      accent: cyan,
      title-size: 25pt,
    )

    #v(9pt)

    #callout-card(
      [white LED],
      [Usually the same spectrum, scaled down.],
      [
        With PWM, the instantaneous LED spectrum is essentially unchanged while
        the on-time falls. With well-behaved CCR, the spectral shape is also
        generally much more stable than the change in total output.
      ],
      accent: blue,
      fill: faint,
      inset-x: 9pt,
      inset-y: 8pt,
    )

    #v(8pt)

    #callout-card(
      [incandescent],
      [The source itself changes as it dims.],
      [
        A filament dims by cooling. Lower temperature reduces total radiant power
        and changes the spectral distribution, suppressing short wavelengths more
        strongly and moving the visible balance toward red.
      ],
      accent: amber,
      inset-y: 7pt,
    )

    #v(8pt)

    #callout-card(
      [important comparison],
      [Amplitude change and spectral change are different things.],
      [
        Two sources can both be described as “50% dimmed” while undergoing very
        different physical changes. The dimming command alone does not tell you
        whether the emitted spectrum stayed stable.
      ],
      accent: violet,
      fill: faint,
      inset-y: 7pt,
    )

    #v(9pt)

    #bottom-takeaway(
      [source rule],
      [
        Before treating dimming as a universal operation, identify the source
        mechanism. LED dimming is usually dominated by output modulation;
        thermal-source dimming also changes the spectrum itself.
      ],
      accent: cyan,
    )
  ],

  // ---------------------------------------------------------------------------
  // RIGHT — compare the spectral behavior
  // ---------------------------------------------------------------------------

  [
    #page-kicker(
      [same command, different source physics],
      accent: cyan,
    )

    #v(6pt)

    #grid(
      columns: (1fr, 1fr),
      column-gutter: 9pt,
      align: top,

      [
        #spectral-compare-card(
          [white LED],
          [Dimming mostly changes intensity.],
          [
            The modeled LED curves preserve one spectral construction while the
            amplitude falls. The source remains recognizably the same spectral
            architecture across the dimming range.
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
            The modeled thermal curves use progressively lower filament
            temperatures. As output falls, the distribution itself moves toward
            longer wavelengths rather than merely shrinking in place.
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
        #callout-card(
          [LED takeaway],
          [Mostly an amplitude change.],
          [
            The source is usually the same spectral construction at a lower
            delivered output.
          ],
          accent: blue,
          inset-y: 7pt,
        )
      ],

      [
        #callout-card(
          [incandescent takeaway],
          [Amplitude and spectrum both change.],
          [
            The filament cools as output falls, so the emitted distribution
            shifts toward longer wavelengths.
          ],
          accent: amber,
          fill: faint,
          inset-y: 7pt,
        )
      ],

      [
        #callout-card(
          [axis matters],
          [One shared full-output reference.],
          [
            The curves are not normalized independently, so their vertical
            separation represents the actual modeled drop in relative output.
          ],
          accent: blackish,
          inset-y: 7pt,
        )
      ],
    )
  ],
)

