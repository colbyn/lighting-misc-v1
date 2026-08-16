// Fragment: lower end / night products.
//
// Defines the biological-night lighting layer: spectrally constrained,
// low-melanopic sources for orientation and essential nighttime tasks.

#import "components.typ": *
#import "spectrum.typ": *

// =============================================================================
// Page-local helper
// =============================================================================

#let night-source-feature(
  src,
  value,
  kicker,
  title,
  principle,
  accent,
  plot-height: 2.75cm,
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
        size: 13pt,
        weight: "semibold",
        fill: ink,
      )[
        #title
      ]

      #v(3pt)

      #note(
        principle,
        size: 6.65pt,
      )

      #v(5pt)

      #metric-pill(
        value,
        melanopic-der-max,
        fill: violet,
      )
    ],

    [
      #spectrum-plot(
        wl,
        height: plot-height,
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
    ],
  )

  #v(4pt)

  #note(
    src.detail,
    size: 6.55pt,
  )
]

// =============================================================================
// PAGE 1 — Biological-night source layer
// =============================================================================

#grid(
  columns: (0.36fr, 0.64fr),
  column-gutter: 13pt,
  align: top,

  // ---------------------------------------------------------------------------
  // LEFT — design logic
  // ---------------------------------------------------------------------------

  [
    #section-intro(
      [night layer],
      [Night lighting should be designed as a separate operating layer.],
      [
        Biological night places a different requirement on the lighting system.
        The objective is no longer general illumination, but enough light for
        safe movement and essential tasks with minimal melanopic exposure.
      ],
      accent: red,
      title-size: 24pt,
    )

    #v(10pt)

    #callout-card(
      [source-side control],
      [Control the spectrum before the light enters the room.],
      [
        Dimming reduces exposure, but it does not fundamentally change the
        spectral proportions of an ordinary white source. A dedicated night
        source reduces both output and the short-wavelength content that
        contributes strongly to melanopic response.
      ],
      accent: violet,
      fill: faint,
      inset-x: 9pt,
      inset-y: 8pt,
    )

    #v(9pt)

    #callout-card(
      [the boundary],
      [Warm-white is useful in the evening — but it is still white light.],
      [
        A 2200–2700 K phosphor LED can substantially improve an evening scene,
        yet still retain a short-wavelength pump. Biological-night lighting
        begins where spectral restraint becomes an explicit source requirement,
        rather than a consequence of warm appearance.
      ],
      accent: amber,
      inset-y: 8pt,
    )

    #v(9pt)

    #callout-card(
      [application],
      [Use the night layer where limited visibility is sufficient.],
      [
        Typical locations include bedside lighting, bathrooms, corridors,
        stairs, nurseries, toe-kick lighting, closet edges, and low-level
        kitchen paths. These are local orientation and task functions rather
        than room-filling scenes.
      ],
      accent: red,
      inset-y: 8pt,
    )

    #v(9pt)

    #callout-card(
      [two constraints],
      [Low melanopic efficiency does not authorize high output.],
      [
        Spectral control reduces melanopic stimulus per unit of photopic light.
        Total exposure still increases with illuminance. Biological-night
        lighting therefore requires both a constrained spectrum and a
        constrained light level.
      ],
      accent: violet,
      fill: faint,
      inset-y: 8pt,
    )

    #v(8pt)

    #bottom-takeaway(
      [design rule],
      [
        Treat the night layer as its own source class: low output, low
        melanopic efficiency, limited spatial distribution, and reserved for
        locations where illumination remains operationally necessary.
      ],
      accent: red,
    )
  ],

  // ---------------------------------------------------------------------------
  // RIGHT — source hierarchy
  // ---------------------------------------------------------------------------

  [
    #page-kicker(
      [from evening white to biological night],
      accent: red,
    )

    #v(6pt)

    #night-source-feature(
      source-defs.at(6),
      melanopic-der-values.at(6),
      [boundary case],
      [Warm phosphor LED],
      [
        Appropriate for evening transition, but not equivalent to a dedicated
        biological-night source.
      ],
      amber,
    )

    #v(7pt)

    #night-source-feature(
      source-defs.at(9),
      melanopic-der-values.at(9),
      [night source],
      [Amber night source],
      [
        A dedicated long-wavelength source preserves basic visibility while
        sharply reducing melanopic efficiency.
      ],
      red,
    )

    #v(7pt)

    #night-source-feature(
      source-defs.at(10),
      melanopic-der-values.at(10),
      [maximum restraint],
      [Deep-red night source],
      [
        An extreme low-melanopic state for situations where color rendering and
        general illumination are secondary to biological-night protection.
      ],
      red,
    )

    #v(7pt)

    #page-kicker(
      [same requirement, increasing spectral restraint],
      accent: blackish,
    )

    #v(5pt)

    #reference-overlay-key()

    #v(5pt)

    #note(
      size: 7.25pt,
      fill: mute,
    )[
      The transition is not simply from brighter to dimmer light. The emitted
      spectrum itself moves away from the short-wavelength region receiving the
      strongest melanopic weighting. Warm-white remains a useful transition
      state; amber and deep-red sources establish a distinct biological-night
      layer.
    ]
  ],
)

#pagebreak()

// =============================================================================
// PAGE 2 — Product specification
// =============================================================================

#grid(
  columns: (0.36fr, 0.64fr),
  column-gutter: 13pt,
  align: top,

  // ---------------------------------------------------------------------------
  // LEFT — what is actually being specified
  // ---------------------------------------------------------------------------

  [
    #section-intro(
      [product specification],
      [Specify performance, not the color name on the box.],
      [
        A night-lighting product should be selected by what it emits, where it
        places that light, and how it behaves in the control system. Marketing
        terms such as amber, warm, or sleep light are not sufficient.
      ],
      accent: violet,
      title-size: 24pt,
    )

    #v(10pt)

    #callout-card(
      [spectral evidence],
      [Ask for the emitted spectrum.],
      [
        The useful evidence is the spectral power distribution and a melanopic
        metric derived from it. CCT alone cannot show whether a nominally warm
        product retains a substantial short-wavelength component.
      ],
      accent: violet,
      fill: faint,
      inset-x: 9pt,
      inset-y: 8pt,
    )

    #v(9pt)

    #callout-card(
      [usable output],
      [The fixture must work at genuinely low levels.],
      [
        A suitable source should remain stable and controllable at the low
        outputs required for nighttime circulation. A low-DER lamp that cannot
        operate gracefully at low illuminance is still a poor night-layer
        product.
      ],
      accent: red,
      inset-y: 8pt,
    )

    #v(9pt)

    #callout-card(
      [optical control],
      [Place the light where the task occurs.],
      [
        Distribution matters alongside spectrum. Shielding, low mounting,
        directional optics, and small illuminated areas can provide useful
        visibility without raising the ambient exposure of the entire room.
      ],
      accent: amber,
      inset-y: 8pt,
    )

    #v(9pt)

    #callout-card(
      [control behavior],
      [The night source should be independently addressable.],
      [
        A nighttime action should recall the dedicated night layer rather than
        simply dim an ordinary white scene. Separate scene behavior allows the
        system to change source, output, and distribution together.
      ],
      accent: blue,
      fill: faint,
      inset-y: 8pt,
    )

    #v(8pt)

    #bottom-takeaway(
      [selection rule],
      [
        A credible night product is not defined by one favorable number.
        Spectrum, minimum usable output, optical distribution, and control
        behavior must work together.
      ],
      accent: violet,
    )
  ],

  // ---------------------------------------------------------------------------
  // RIGHT — specification framework
  // ---------------------------------------------------------------------------

  [
    #page-kicker(
      [four specification dimensions],
      accent: violet,
    )

    #v(6pt)

    #grid(
      columns: (1fr, 1fr),
      column-gutter: 8pt,
      row-gutter: 8pt,
      align: top,

      [
        #spec-panel(
          [01 spectrum],
          [Verify what the source emits.],
          [
            Record the spectral power distribution, melanopic DER, and relevant
            photometric operating condition. Do not infer low melanopic
            performance from CCT or appearance alone.
          ],
          accent: violet,
        )
      ],

      [
        #spec-panel(
          [02 output],
          [Verify the low end of the operating range.],
          [
            Establish the minimum stable output and the actual illuminance
            delivered at the eye or task plane. Night performance depends on
            usable low output, not merely rated maximum output.
          ],
          accent: red,
        )
      ],

      [
        #spec-panel(
          [03 distribution],
          [Constrain where the light goes.],
          [
            Prefer low-level, shielded, and task-specific distribution.
            Orientation lighting should illuminate the path or working surface
            without unnecessarily increasing room-wide ambient exposure.
          ],
          accent: amber,
        )
      ],

      [
        #spec-panel(
          [04 control],
          [Make the night state explicit.],
          [
            The source should participate in a dedicated nighttime scene,
            schedule, or control state so that an ordinary interaction does not
            restore a higher-output white-light condition.
          ],
          accent: blue,
        )
      ],
    )

    #v(9pt)

    #page-kicker(
      [selection sequence],
      accent: blackish,
    )

    #v(6pt)

    #grid(
      columns: (1fr, auto, 1fr, auto, 1fr),
      column-gutter: 7pt,
      align: horizon,

      [
        #sequence-chip(
          [source],
          [Choose the spectrum],
          [
            Establish the spectral class appropriate to the nighttime task.
          ],
          accent: violet,
        )
      ],

      [
        #text(
          size: 14pt,
          fill: mute,
        )[
          →
        ]
      ],

      [
        #sequence-chip(
          [fixture],
          [Control the distribution],
          [
            Put light only where visibility is required.
          ],
          accent: amber,
        )
      ],

      [
        #text(
          size: 14pt,
          fill: mute,
        )[
          →
        ]
      ],

      [
        #sequence-chip(
          [system],
          [Commission the scene],
          [
            Set the low output and ensure the night layer is recalled reliably.
          ],
          accent: blue,
        )
      ],
    )

    #v(9pt)

    #page-kicker(
      [record at commissioning],
      accent: red,
    )

    #v(6pt)

    #grid(
      columns: (1fr, 1fr),
      column-gutter: 8pt,
      align: top,

      [
        #callout-card(
          [source data],
          [Keep the spectral record with the fixture schedule.],
          [
            Record the product identity, spectral data used for selection,
            melanopic DER, nominal operating state, and any assumptions used to
            establish the night scene.
          ],
          accent: violet,
          fill: faint,
          inset-y: 8pt,
        )
      ],

      [
        #callout-card(
          [field condition],
          [Verify the installed result, not only the catalog value.],
          [
            Final performance also depends on output setting, mounting,
            distribution, surface reflection, and viewing geometry. Commission
            the installed scene at the level at which it will actually operate.
          ],
          accent: red,
          fill: faint,
          inset-y: 8pt,
        )
      ],
    )

    #v(8pt)

    #note(
      size: 7.25pt,
      fill: mute,
    )[
      Product selection establishes the capability of the night layer;
      commissioning determines whether that capability survives in the actual
      space. A spectrally appropriate source can still be undermined by excessive
      output, poor distribution, or incorrect scene behavior.
    ]
  ],
)