// =============================================================================
// Electrical section: Source Dimming Behavior
// =============================================================================
//
// Shared document styling comes from spectra/components.typ.
// Shared spectral computation / source models come from spectra/spectrum.typ.
// This file keeps only the source-dimming transforms and section composition.

#import "../spectra/components.typ": ink, hair, faint, white, amber, green, violet, blue, cyan, red, blackish, label, note, section-intro, bottom-takeaway
#import "../spectra/spectrum.typ": spectrum-plot, wl, neutral-led, blackbody
#import "components.typ": rule-card

// =============================================================================
// Spectral comparison: dimming behavior by source family
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
) = block(
  width: 100%,
  inset: (x: 10pt, y: 9pt),
  radius: 4pt,
  fill: faint,
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
    wl,
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
// Render
// =============================================================================

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

