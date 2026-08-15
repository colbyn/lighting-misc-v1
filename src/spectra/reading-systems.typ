// Fragment: two reading systems.
//
// Introduces the visual / photopic and non-visual / melanopic readers,
// then demonstrates how two visually comparable white sources can produce
// different melanopic-weighted outputs.

#import "components.typ": *
#import "spectrum.typ": *

// =============================================================================
// Page-local helper
// =============================================================================

#let reading-example(
  kicker,
  src,
  value,
  verdict,
  accent: blackish,
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
    size: 11pt,
    weight: "semibold",
    fill: ink,
  )[#src.name]

  #v(4pt)

  #spectrum-plot(
    wl,
    height: 2.7cm,
    legend-position: "none",
    xlabel: text(size: 0pt)[],
    ylabel: text(size: 0pt)[],
    series: with-reference-overlays(((
      label: [],
      values: src.values,
      stroke: src.stroke,
      draw-area: true,
      z: 2,
    ),)),
  )

  #v(4pt)

  #metric-pill(
    value,
    melanopic-der-max,
    fill: violet,
  )

  #v(3pt)

  #note(
    verdict,
    size: 6.9pt,
  )
]

// =============================================================================
// Two reading systems
// =============================================================================

#grid(
  columns: (0.36fr, 0.64fr),
  column-gutter: 13pt,
  align: top,

  [
    #section-intro(
      [circadian lighting],
      [Spectrum is read by more than one system.],
      [The retina does not send one report to the brain. It sends a visual report and a biological timing report.],
      accent: blue,
      title-size: 32pt,
    )

    #v(10pt)

    #callout-card(
      [the hidden reader],
      [The same photons carry two meanings.],
      [Beyond rods and cones, the retina contains intrinsically photosensitive retinal ganglion cells, or ipRGCs. These cells project through the retinohypothalamic tract to the suprachiasmatic nucleus, the brain's master circadian clock, and to pathways involved in pupil constriction, alertness, morning cortisol release, and melatonin suppression.],
      accent: violet,
      fill: faint,
      inset-x: 9pt,
      inset-y: 8pt,
    )

    #v(9pt)

    #grid(
      columns: (1fr, 1fr),
      column-gutter: 8pt,
      align: top,

      [
        #callout-card(
          [visual system],
          [Photopic — V(λ)],
          [Peaks near 555 nm. It is the basis for lux, footcandles, and luminous efficacy — the quantities that tell a lighting designer how bright the room appears.],
          accent: ref-visual,
          inset-y: 7pt,
        )
      ],

      [
        #callout-card(
          [non-visual system],
          [Melanopic — ipRGC],
          [Peaks near 480–490 nm. It is produced by melanopsin in intrinsically photosensitive retinal ganglion cells and is quantified in melanopic EDI.],
          accent: violet,
          inset-y: 7pt,
        )
      ],
    )

    #v(9pt)

    #callout-card(
      [reading the number],
      [What the pill numbers on the right mean.],
      [Each modeled source is evaluated by melanopic DER: its melanopic response is compared with its photopic response, then referenced to D65 daylight, which has a DER of 1.0. Higher DER means more melanopic stimulus for the same amount of visual light.],
      accent: violet,
      fill: faint,
      inset-y: 7pt,
    )

    #v(9pt)

    #bottom-takeaway(
      [first rule],
      [Brightness, warmth, CCT, and CRI describe the visual layer. They do not prove what the source does biologically. The circadian layer requires reading the spectrum itself.],
      accent: blue,
    )
  ],

  [
    #spectrum-plot(
      wl,
      title: [Two sensitivity functions reading the same spectrum],
      height: 6.45cm,
      legend-position: "bottom",
      legend-columns: (auto, auto, auto),
      series: (
        (
          label: [☀️ idealized daylight (CIE D65)],
          values: daylight,
          stroke: 1.0pt + ref-day,
        ),
        (
          label: [photopic weight — V(λ) / visual],
          values: photopic,
          stroke: 1.15pt + ref-visual,
        ),
        (
          label: [melanopic weight — ipRGC / clock],
          values: melanopic,
          stroke: 1.8pt + violet,
          halo: true,
        ),
      ),
    )

    #v(10pt)

    #grid(
      columns: (1fr, 1fr),
      column-gutter: 9pt,
      align: top,

      [
        #reading-example(
          [same visual target],
          source-catalog.at("cheap_blue_pump_led"),
          melanopic-der-values.at(1),
          [Ordinary white light, but the pump peak sits inside the ipRGC window: a strong clock signal riding on an unremarkable-looking lamp.],
          accent: blue,
        )
      ],

      [
        #reading-example(
          [same visual target],
          source-catalog.at("warm_phosphor_led"),
          melanopic-der-values.at(6),
          [Comparable brightness, warmer appearance, and a somewhat lower melanopic DER: a modest reduction in clock drive, not an escape from it.],
          accent: amber,
        )
      ],
    )

    #v(6pt)

    #note(
      size: 7.4pt,
      fill: mute,
    )[
      Both lamps can look reasonably white and pass ordinary lux, CCT, and CRI checks — the two curves above are what actually distinguish them biologically.
    ]
  ],
)
