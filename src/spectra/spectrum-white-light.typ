// Standalone spectra page: Spectrum Is the Real Light Source
//
// Intended location:
//   src/spectra/spectrum-white-light.typ

#import "components.typ": *
#import "spectrum.typ": *

// =============================================================================
// Page-local helpers
// =============================================================================

#let source-series(label, values, stroke, draw-area: false) = (
  label: label,
  values: values,
  stroke: stroke,
  draw-area: draw-area,
)

#let comparison-card(
  kicker,
  title,
  body,
  source-label,
  source-values,
  source-stroke,
  accent: blackish,
  plot-height: 5.0cm,
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
    height: plot-height,
    legend-position: "bottom",
    legend-columns: (auto, auto),
    xlabel: text(size: 4.9pt)[Wavelength / nm],
    ylabel: text(size: 4.9pt)[Relative power],
    series: (
      source-series(
        source-label,
        source-values,
        source-stroke,
        draw-area: true,
      ),
      source-series(
        [idealized daylight],
        daylight,
        0.75pt + ref-day,
      ),
    ),
  )

  #v(4pt)

  #note(
    body,
    size: 6.65pt,
  )
]

#let source-chip(
  kicker,
  title,
  body,
  values,
  stroke,
  accent: blackish,
) = block(
  width: 100%,
  inset: (x: 7pt, y: 6pt),
  radius: 4pt,
  fill: faint,
  stroke: hair + 0.55pt,
  breakable: false,
)[
  #label(kicker, fill: accent)

  #v(2pt)

  #text(
    size: 10.2pt,
    weight: "semibold",
    fill: ink,
  )[
    #title
  ]

  #v(3pt)

  #spectrum-plot(
    wl,
    height: 3.0cm,
    legend-position: "none",
    xlabel: text(size: 0pt)[],
    ylabel: text(size: 0pt)[],
    series: ((
      label: [],
      values: values,
      stroke: stroke,
      draw-area: true,
      z: 2,
    ),),
  )

  #v(4pt)

  #note(
    body,
    size: 6.15pt,
  )
]

// =============================================================================
// PAGE 1 — White is an appearance
// =============================================================================

#grid(
  columns: (0.4fr, 1fr),
  column-gutter: 10pt,
  align: top,

  [
    #section-intro(
      [the hidden layer],
      [White is an appearance, not a spectrum.],
      [
        It is a spectral construction that happens to land on a white appearance.
      ],
      accent: violet,
      title-size: 24pt,
    )

    #v(10pt)

    #callout-card(
      [reading rule],
      [Read where the energy is.],
      [
        Warm, neutral, and cool describe how the source appears. The spectral
        power distribution shows how that appearance was actually constructed:
        where the source rises, where it falls away, and which wavelengths do
        most of the work.
      ],
      accent: violet,
      fill: faint,
      inset-x: 9pt,
      inset-y: 8pt,
    )

    #v(9pt)

    #callout-card(
      [what the eye hides],
      [Chromaticity is a compression.],
      [
        The visual system can collapse very different spectral distributions
        into a similar judgment of white. Matching appearance therefore does
        not imply matching spectral structure.
      ],
      accent: ref-visual,
      inset-y: 7pt,
    )

    #v(9pt)

    #callout-card(
      [source versus result],
      [“White” tells you where the source landed — not how it got there.],
      [
        A glowing filament, a blue LED driving phosphor, a violet pump, or
        separate red, green, and blue emitters can all arrive at a white
        chromaticity by very different physical routes.
      ],
      accent: violet,
      fill: faint,
      inset-y: 7pt,
    )
  ],

  [
    #spectrum-plot(
      wl,
      title: [Different spectral routes to white],
      height: 13.0cm,
      legend-position: "bottom",
      legend-columns: (auto, auto, auto),
      xlabel: text(size: 5.1pt)[Wavelength / nm],
      ylabel: text(size: 5.1pt)[Relative power],
      series: (
        source-series(
          [idealized daylight],
          daylight,
          0.85pt + ref-day,
        ),
        source-series(
          [incandescent],
          incandescent,
          0.90pt + amber,
        ),
        source-series(
          [blue-pump LED],
          cheap-blue-led,
          0.90pt + blue,
        ),
        source-series(
          [neutral phosphor LED],
          neutral-led,
          0.85pt + cyan,
        ),
        source-series(
          [violet-pump LED],
          violet-pump-led,
          0.90pt + violet,
        ),
        source-series(
          [RGB mixed white],
          rgb-white,
          0.90pt + red,
        ),
      ),
    )

    #v(9pt)

    #grid(
      columns: (1fr, 1fr),
      column-gutter: 8pt,
      align: top,

      [
        #small-rule-note(
          [same category],
          [
            All six sources can occupy the broad visual category of white,
            despite radically different distributions underneath.
          ],
          accent: ref-visual,
        )
      ],

      [
        #small-rule-note(
          [different physics],
          [
            The peaks, slopes, gaps, and continua are fingerprints of the
            physical mechanism producing the light.
          ],
          accent: violet,
        )
      ],
    )

    #v(9pt)

    #bottom-takeaway(
      [first rule],
      [
        If the question concerns what the light physically contains, start with
        the spectrum. CCT is a useful visual summary; it is not a source
        description.
      ],
      accent: violet,
    )
  ],
)

#pagebreak()

// =============================================================================
// PAGE 2 — Source architecture leaves fingerprints
// =============================================================================

#grid(
  columns: (1fr, 0.4fr),
  column-gutter: 10pt,
  align: top,

  [
    #grid(
      columns: (1fr, 1fr),
      column-gutter: 9pt,
      align: top,

      [
        #comparison-card(
          [thermal source],
          [Continuous does not mean daylight-like.],
          [
            Incandescent output forms a smooth thermal continuum, but the
            distribution is heavily weighted toward red and longer wavelengths.
          ],
          [incandescent],
          incandescent,
          1.0pt + amber,
          accent: amber,
        )
      ],

      [
        #comparison-card(
          [phosphor source],
          [White appearance can hide a pump spike.],
          [
            The blue pump remains a distinct spectral feature even after the
            phosphor contribution broadens the source into visually white light.
          ],
          [blue-pump LED],
          cheap-blue-led,
          1.0pt + blue,
          accent: blue,
        )
      ],
    )

    #v(9pt)

    #page-kicker(
      [three engineered routes],
      accent: violet,
    )

    #v(6pt)

    #grid(
      columns: (1fr, 1fr, 1fr),
      column-gutter: 7pt,
      align: top,

      [
        #source-chip(
          [blue pump],
          [Phosphor white],
          [
            A narrow blue emitter supplies the pump while a broad converted band
            fills the middle and long wavelengths.
          ],
          cheap-blue-led,
          0.95pt + blue,
          accent: blue,
        )
      ],

      [
        #source-chip(
          [violet pump],
          [Broader conversion],
          [
            Moving the pump toward violet allows the converted spectrum to
            distribute output more broadly across the visible range.
          ],
          violet-pump-led,
          0.95pt + violet,
          accent: violet,
        )
      ],

      [
        #source-chip(
          [additive mixing],
          [RGB white],
          [
            Three narrow emitters can converge on white appearance without
            filling the wavelengths between their individual peaks.
          ],
          rgb-white,
          0.95pt + red,
          accent: red,
        )
      ],
    )

    #v(7pt)

    #note(
      size: 7.35pt,
      fill: mute,
    )[
      These are not merely different colors of white. They are different source
      architectures that happen to produce a similar visual category.
    ]

    #v(9pt)

    #bottom-takeaway(
      [useful question],
      [
        Do not stop at “what color is this light?” Ask what physical mechanism
        produced it, and what spectral structure that mechanism leaves behind.
      ],
      accent: violet,
    )
  ],

  [
    #section-intro(
      [source architecture],
      [How white light is made.],
      [
        The spectrum reveals the physical process behind the appearance: thermal emission, phosphor conversion, or narrow-band mixing.
      ],
      accent: violet,
      title-size: 24pt,
    )

    #v(10pt)

    #callout-card(
      [thermal emission],
      [A continuum can still be strongly biased.],
      [
        Incandescent light comes from a hot radiator. Its spectrum is smooth,
        but it climbs strongly toward longer wavelengths and continues beyond
        the visible range into infrared. Continuous does not mean daylight-like.
      ],
      accent: amber,
      fill: faint,
      inset-y: 8pt,
    )

    #v(9pt)

    #callout-card(
      [phosphor conversion],
      [A white lamp can retain the pump that created it.],
      [
        In a blue-pump LED, a narrow blue emitter excites a much broader
        phosphor band. The resulting mixture can look ordinary and balanced
        while the pump remains plainly visible in the spectrum.
      ],
      accent: blue,
      inset-y: 8pt,
    )

    #v(9pt)

    #callout-card(
      [narrow-band mixing],
      [White does not require a continuous spectrum.],
      [
        Red, green, and blue emitters can be mixed to a white chromaticity even
        though large portions of the visible range remain comparatively sparse.
      ],
      accent: red,
      fill: faint,
      inset-y: 8pt,
    )
  ],
)
