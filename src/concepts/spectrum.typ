#import "@preview/lilaq:0.6.0" as lq
#import "./lib/blocks.typ": block-quote
#import "./lib/spd-plot.typ": spectrum-plot

// ============================================================================
// Data primitives
// ============================================================================

#let wl = lq.linspace(380, 780, num: 401)

#let gauss(x, center, width, amp: 1.0) = {
  amp * calc.exp(-0.5 * calc.pow((x - center) / width, 2))
}

#let skewed-gauss(x, center, left-width, right-width, amp: 1.0) = {
  if x < center {
    gauss(x, center, left-width, amp: amp)
  } else {
    gauss(x, center, right-width, amp: amp)
  }
}

#let normalize(values) = {
  let max-val = calc.max(..values)

  if max-val == 0 {
    values
  } else {
    values.map(v => v / max-val)
  }
}

#let make-series(f) = normalize(wl.map(f))

#let sub-dip(x, center, width, depth: 0.1) = {
  1.0 - depth * gauss(x, center, width)
}

#let blackbody(x, temp) = {
  // Relative Planck-like curve.
  // x is wavelength in nm.
  // c2 = h*c/k in nm*K.
  let c2 = 14387768.0
  let xr = x / 560.0
  let e = calc.exp(c2 / (x * temp))

  1.0 / (calc.pow(xr, 5.0) * (e - 1.0))
}

#let spectral-window(values, min-wl, max-wl) = {
  let pairs = ()
  for i in range(wl.len()) {
    let x = wl.at(i)
    if x >= min-wl and x <= max-wl {
      pairs.push(values.at(i))
    }
  }

  if pairs.len() == 0 {
    0
  } else {
    pairs.sum() / pairs.len()
  }
}

#let band-score(values, min-wl, max-wl) = {
  let score = spectral-window(values, min-wl, max-wl)
  calc.round(score * 100)
}


// ============================================================================
// Synthetic spectral archetypes
// ============================================================================

#let spd-daylight-reference(x) = {
  // Idealized daylight-like reference: solar-ish continuum plus absorption texture.
  let base = blackbody(x, 5778)

  let atmosphere = (
    sub-dip(x, 430, 8, depth: 0.030) *
    sub-dip(x, 486, 6, depth: 0.035) *
    sub-dip(x, 517, 8, depth: 0.025) *
    sub-dip(x, 589, 5, depth: 0.045) *
    sub-dip(x, 656, 7, depth: 0.035) *
    sub-dip(x, 690, 9, depth: 0.030) *
    sub-dip(x, 760, 12, depth: 0.090)
  )

  base * atmosphere
}

#let spd-candle(x) = {
  // Very warm thermal source.
  blackbody(x, 1900)
}

#let spd-incandescent(x) = {
  // Household tungsten archetype.
  blackbody(x, 2700)
}

#let spd-halogen(x) = {
  // Slightly hotter tungsten-halogen archetype.
  blackbody(x, 3000)
}

#let spd-cheap-blue-pump(x) = {
  // Low-cost blue-pump white LED:
  // obvious 450 nm pump, green/yellow phosphor, cyan hole, weak deep red.
  (
    gauss(x, 450, 11, amp: 1.22) +
    skewed-gauss(x, 560, 42, 78, amp: 0.82) +
    gauss(x, 610, 52, amp: 0.22) +
    gauss(x, 660, 34, amp: 0.055)
  )
}

#let spd-commodity-blue-pump(x) = {
  // Generic commodity white LED:
  // less ugly than the cheap case but still visibly pump-driven.
  (
    gauss(x, 450, 14, amp: 0.64) +
    gauss(x, 520, 47, amp: 0.30) +
    skewed-gauss(x, 575, 58, 88, amp: 0.78) +
    gauss(x, 635, 72, amp: 0.34)
  )
}

#let spd-high-cri-blue-pump(x) = {
  // High-CRI blue-pump archetype:
  // better cyan and red fill, still anchored by blue pump.
  (
    gauss(x, 450, 15, amp: 0.48) +
    gauss(x, 505, 47, amp: 0.40) +
    gauss(x, 560, 76, amp: 0.66) +
    gauss(x, 620, 84, amp: 0.64) +
    gauss(x, 665, 46, amp: 0.32)
  )
}

#let spd-violet-pump(x) = {
  // Violet-pump / full-spectrum archetype:
  // pump is moved down toward violet; visible region is rebuilt with phosphors.
  (
    gauss(x, 410, 12, amp: 0.44) +
    gauss(x, 445, 34, amp: 0.20) +
    gauss(x, 490, 54, amp: 0.43) +
    gauss(x, 555, 84, amp: 0.70) +
    gauss(x, 620, 86, amp: 0.62) +
    gauss(x, 675, 52, amp: 0.36)
  )
}

#let spd-rgb-white(x) = {
  // RGB mixed white archetype:
  // can make white visually, but spectral coverage is sparse.
  (
    gauss(x, 460, 18, amp: 0.88) +
    gauss(x, 530, 24, amp: 0.96) +
    gauss(x, 625, 28, amp: 0.74)
  )
}

#let daylight = make-series(spd-daylight-reference)
#let candle = make-series(spd-candle)
#let incandescent = make-series(spd-incandescent)
#let halogen = make-series(spd-halogen)
#let cheap-blue-pump = make-series(spd-cheap-blue-pump)
#let commodity-blue-pump = make-series(spd-commodity-blue-pump)
#let high-cri-blue-pump = make-series(spd-high-cri-blue-pump)
#let violet-pump = make-series(spd-violet-pump)
#let rgb-white = make-series(spd-rgb-white)


// ============================================================================
// Design tokens
// ============================================================================

#let ink = rgb("#24242a")
#let soft-ink = rgb("#4d4d58")
#let mute = rgb("#6f707b")
#let faint = rgb("#f5f5f8")
#let panel = rgb("#fcfcff")
#let rule-color = rgb("#d9d9e3")
#let hairline = rgb("#dbdbeb")

#let blue = rgb("#005eff")
#let cyan = rgb("#008f9a")
#let green = rgb("#3a9a00")
#let violet = rgb("#7a3cff")
#let amber = rgb("#bd6a00")
#let red = rgb("#a83232")
#let black = rgb("#111111")

#let fine-label(body, fill: mute) = [
  #set par(justify: false)
  #text(size: 7.4pt, weight: "bold", tracking: 0.09em, fill: fill)[
    #upper(body)
  ]
]

#let section-rule() = [
  #v(32pt)
  #line(length: 100%, stroke: rule-color + 0.8pt)
  #v(26pt)
]

#let spread-gap() = v(24pt)
#let unit-gap() = v(16pt)
#let tight-gap() = v(9pt)

#let note(body) = [
  #block(
    width: 100%,
    inset: (x: 12pt, y: 10pt),
    radius: 8pt,
    fill: faint,
    stroke: hairline + 0.6pt,
  )[
    #set par(leading: 0.66em)
    #text(size: 8.8pt, fill: soft-ink)[#body]
  ]
]

#let copy-block(body, width: 92%, size: 10pt) = [
  #block(width: width)[
    #set par(leading: 0.68em)
    #text(size: size, fill: soft-ink)[#body]
  ]
]

#let lede(body, width: 92%) = [
  #set par(justify: false)
  #block(width: width)[
    #set par(leading: 0.72em)
    #text(size: 13pt, fill: soft-ink)[#body]
  ]
]

#let headline(body, size: 24pt, weight: "medium", fill: ink) = [
  #set par(justify: false)
  #text(size: size, weight: weight, fill: fill)[#body]
]

#let data-chip(label, value, accent: black) = [
  #block(
    inset: (x: 7pt, y: 5pt),
    radius: 5pt,
    fill: rgb("#ffffff"),
    stroke: hairline + 0.55pt,
  )[
    #text(size: 6.8pt, weight: "bold", tracking: 0.06em, fill: mute)[
      #upper(label)
    ]

    #text(size: 8pt, weight: "medium", fill: accent)[#value]
  ]
]

#let evidence-card(title, body, accent: black) = [
  #block(
    width: 100%,
    inset: (x: 12pt, y: 12pt),
    radius: 6pt,
    fill: panel,
    stroke: hairline + 0.5pt,
  )[
    #fine-label(title, fill: accent)

    #copy-block(body, width: 96%, size: 9.6pt)
  ]
]

#let claim-card(title, body, accent: black) = [
  #block(
    width: 100%,
    inset: (x: 16pt, y: 15pt),
    radius: 11pt,
    fill: white,
    stroke: hairline + 0.75pt,
  )[
    #fine-label(title, fill: accent)

    #v(9pt)

    #copy-block(body, width: 96%, size: 10pt)
  ]
]

#let table-cell(body, size: 9pt, fill: ink) = [
  #set par(leading: 0.62em)
  #text(size: size, fill: fill)[#body]
]

#let airy-table(..children) = [
  #block(
    width: 100%,
    inset: (x: 14pt, y: 12pt),
    radius: 10pt,
    fill: panel,
    stroke: hairline + 0.7pt,
  )[
    #table(
      columns: (0.55fr, 0.85fr, 1.65fr),
      inset: (x: 8pt, y: 8pt),
      stroke: none,
      align: top,
      ..children,
    )
  ]
]


// ============================================================================
// Plot helpers
// ============================================================================

#let daylight-series = (
  (
    label: [☀️ idealized daylight],
    values: daylight,
    stroke: black + 1.0pt,
    draw-area: false,
  ),
)

#let thermal-series = (
  (
    label: [candle / flame],
    values: candle,
    stroke: rgb("#8b3f00") + 0.9pt,
    draw-area: false,
  ),
  (
    label: [incandescent],
    values: incandescent,
    stroke: amber + 1.0pt,
    draw-area: false,
  ),
  (
    label: [halogen],
    values: halogen,
    stroke: rgb("#d98900") + 0.9pt,
    draw-area: false,
  ),
)

#let led-family-series = (
  (
    label: [cheap blue-pump],
    values: cheap-blue-pump,
    stroke: blue + 0.9pt,
    draw-area: false,
  ),
  (
    label: [commodity blue-pump],
    values: commodity-blue-pump,
    stroke: cyan + 0.9pt,
    draw-area: false,
  ),
  (
    label: [high-CRI blue-pump],
    values: high-cri-blue-pump,
    stroke: green + 0.9pt,
    draw-area: false,
  ),
  (
    label: [violet-pump],
    values: violet-pump,
    stroke: violet + 0.9pt,
    draw-area: false,
  ),
  (
    label: [RGB mixed white],
    values: rgb-white,
    stroke: red + 0.9pt,
    draw-area: false,
  ),
)

#let all-archetypes-series = daylight-series + thermal-series + led-family-series

#let compare-to-daylight(label, values, stroke, title: [], height: 4.1cm, area: true) = {
  spectrum-plot(
    wl,
    title: title,
    height: height,
    legend-position: "bottom",
    series: daylight-series + (
      (
        label: label,
        values: values,
        stroke: stroke,
        draw-area: area,
      ),
    ),
  )
}

#let compare-two(a-label, a-values, a-stroke, b-label, b-values, b-stroke, title: [], height: 4.7cm) = {
  spectrum-plot(
    wl,
    title: title,
    height: height,
    legend-position: "bottom",
    series: (
      (
        label: a-label,
        values: a-values,
        stroke: a-stroke,
        draw-area: true,
      ),
      (
        label: b-label,
        values: b-values,
        stroke: b-stroke,
        draw-area: false,
      ),
    ),
  )
}

#let archetype-card(
  eyebrow,
  title,
  values,
  stroke,
  accent,
  body,
  chips: (),
) = [
  #block(
    width: 100%,
    inset: 10pt,
    radius: 11pt,
    fill: white,
    stroke: hairline + 0.7pt,
    breakable: false,
  )[
    #fine-label(eyebrow, fill: accent)
    #text(size: 11pt, weight: "medium", fill: ink)[#title]
    
    #compare-to-daylight(
      title,
      values,
      stroke,
      title: [],
      height: 3.05cm,
    )

    #copy-block(body, width: 100%, size: 8.8pt)

    #if chips.len() > 0 [
      #v(9pt)

      #grid(
        columns: (auto, auto, auto),
        column-gutter: 5pt,
        row-gutter: 5pt,
        ..chips,
      )
    ]
  ]
]

#let score-strip(label, values, accent) = [
  #grid(
    columns: (1fr, auto, auto, auto),
    column-gutter: 8pt,
    align: horizon,

    [
      #text(size: 8.8pt, weight: "medium", fill: ink)[#label]
    ],
    data-chip([cyan], [#band-score(values, 470, 510)], accent: accent),
    data-chip([red], [#band-score(values, 620, 700)], accent: accent),
    data-chip([violet/blue], [#band-score(values, 400, 460)], accent: accent),
  )
]


// ============================================================================
// Section content
// ============================================================================

#pagebreak()

== Spectrum Is the Real Light Source

#grid(
  columns: (0.40fr, 1fr),
  column-gutter: 10pt,
  align: top,
  [
    #fine-label[the hidden layer]
    #headline[
      White light is not a substance.
    ]
    #lede[
      It is a spectral construction that happens to land on a white appearance.
    ]
  ],
  [
    #spectrum-plot(
      wl,
      title: [Different ways to make something that looks white],
      height: 8.0cm,
      legend-position: "bottom",
      series: all-archetypes-series,
    )
  ],
)

#spread-gap()

#block(breakable: false)[
  #grid(
    columns: (1fr, 1fr),
    column-gutter: 8pt,
    row-gutter: 8pt,
    align: top,

    evidence-card(
      [thermal light],
      [
        A hot object emits a continuum. The spectrum is a consequence of temperature.
      ],
      accent: amber,
    ),

    evidence-card(
      [phosphor-converted LED],
      [
        A narrow semiconductor pump excites phosphors. The spectrum is assembled from pump leakage plus converted light.
      ],
      accent: blue,
    ),

    evidence-card(
      [multi-channel light],
      [
        Multiple primaries can mix to white while leaving large spectral gaps between channels.
      ],
      accent: red,
    ),

    evidence-card(
      [design implication],
      [
        A white appearance is not enough information. The wavelength distribution determines rendering, comfort, biological effect, camera behavior, and how materials appear.
      ],
      accent: green,
    ),
  )
]

#pagebreak()

== The Same Word “White” Hides Different Machinery

#fine-label[mechanism matters]

#let mechanism-panel(label, title, accent, body, rows) = [
  #block(
    width: 100%,
    inset: (x: 15pt, y: 14pt),
    radius: 11pt,
    fill: white,
    stroke: hairline + 0.75pt,
    breakable: false,
  )[
    #fine-label(label, fill: accent)

    #v(7pt)

    #text(size: 13pt, weight: "medium", fill: ink)[#title]

    #v(9pt)

    #copy-block(body, width: 100%, size: 9.3pt)

    #v(12pt)

    #table(
      columns: (0.42fr, 1fr),
      inset: (x: 0pt, y: 5pt),
      stroke: none,
      align: top,
      ..rows.map(row => (
        table-cell(row.at(0), size: 7.8pt, fill: mute),
        table-cell(row.at(1), size: 8.8pt, fill: ink),
      )).flatten(),
    )
  ]
]

#grid(
  columns: (1fr, 1fr),
  column-gutter: 10pt,
  align: top,
  [
    #align(center)[
      #headline(size: 16pt, weight: "semibold", fill: rgb("#808090"))[ Incandescent light is emitted. ]
    ]
    #mechanism-panel(
      [thermal source],
      [Incandescent is constrained by temperature.],
      amber,
      [
        The spectrum follows from a hot filament. You can dim it, cool it, or heat it, but the source remains a continuous thermal radiator.
      ],
      (
        ([source variable], [filament temperature]),
        ([spectral shape], [continuous, red-heavy curve]),
        ([main tradeoff], [beautiful continuity, poor efficiency]),
        ([what to verify], [mostly output, heat, lifetime]),
      ),
    )
  ],
  [
    #align(center)[
      #headline(size: 16pt, weight: "semibold", fill: rgb("#808090"))[ LED white is engineered. ]
    ]
    #mechanism-panel(
      [engineered source],
      [LED white is a product architecture.],
      blue,
      [
        The spectrum is assembled from semiconductor emission, phosphor conversion, package design, current, heat, optics, and driver behavior.
      ],
      (
        ([source variable], [pump wavelength + phosphor recipe]),
        ([spectral shape], [spike, valley, hump, red tail]),
        ([main tradeoff], [efficiency versus spectral quality]),
        ([what to verify], [SPD, flicker, thermal behavior, control mode]),
      ),
    )
  ],
)

#lede[
  That single difference changes what has to be specified, verified, and controlled. The visible result may be called “white” in both cases, but the machinery behind that appearance is completely different.
]

#grid(
  columns: (1fr, 1fr),
  column-gutter: 18pt,
  row-gutter: 18pt,
  align: top,

  [
    #compare-two(
      [incandescent],
      incandescent,
      amber + 1.0pt,
      [☀️ idealized daylight],
      daylight,
      black + 0.9pt,
      title: [#text(size: 10pt)[Thermal light: continuous, warm, red-heavy]],
      height: 4.9cm,
    )

    #v(9pt)

    #copy-block[
      Incandescent is spectrally continuous, but tilted heavily toward long wavelengths. Its weakness is efficiency, not spectral assembly.
    ]
  ],

  [
    #compare-two(
      [cheap blue-pump LED],
      cheap-blue-pump,
      blue + 1.0pt,
      [☀️ idealized daylight],
      daylight,
      black + 0.9pt,
      title: [#text(size: 10pt)[Basic LED: spike, valley, phosphor hump]],
      height: 4.9cm,
    )

    #v(9pt)

    #copy-block[
      A basic blue-pump LED can look white while still having a hard pump spike, a cyan depression, and weak deep red.
    ]
  ],
)

== The Spectral Anatomy of Common White Light

#v(8pt)

#grid(
  columns: (0.34fr, 1fr),
  column-gutter: 26pt,
  align: top,

  [
    // #set par(justify: false)
    #fine-label[mental model]

    #headline(size: 22pt)[
      Not warm versus cool.
    ]

    Please manufacturer, designers everywhere: stop talking about kelvin.

    #headline(size: 22pt)[
      Where is the energy?
    ]
  ],

  [
    #lede[
      The useful reading habit is to stop treating white as a single category. A white-light spectrum is an energy distribution, not a color name.
    ]

    #v(12pt)

    #grid(
      columns: (1fr, 1fr),
      column-gutter: 10pt,
      row-gutter: 18pt,
      align: top,

      [
        #fine-label[pump]

        #v(4pt)

        Look for the narrow source peak: usually blue around 450 nm, sometimes violet closer to 405 nm.
      ],

      [
        #fine-label[gap]

        #v(4pt)

        Check whether the cyan region is weak. A dip around blue-green wavelengths can matter visually and biologically.
      ],

      [
        #fine-label[phosphor hump]

        #v(4pt)

        Read the broad converted output. This is where much of the visible “white” impression is assembled.
      ],

      [
        #fine-label[red tail]

        #v(4pt)

        Look at how far the spectrum carries into deep red. This affects warmth, color rendering, and material appearance.
      ],
    )
  ],
)

#spread-gap()

#grid(
  columns: (1fr, 1fr),
  column-gutter: 10pt,
  row-gutter: 10pt,
  align: top,

  archetype-card(
    [thermal continuum],
    [Incandescent],
    incandescent,
    amber + 0.95pt,
    amber,
    [
      Smooth and red-heavy. Good continuity, poor efficiency, weak short-wavelength output.
    ],
    chips: (
      data-chip([shape], [smooth], accent: amber),
      data-chip([blue], [low], accent: amber),
      data-chip([red], [high], accent: amber),
    ),
  ),

  archetype-card(
    [blue-pump minimum],
    [Cheap blue-pump LED],
    cheap-blue-pump,
    blue + 0.95pt,
    blue,
    [
      Obvious pump spike near 450 nm, broad phosphor hump, weak cyan and red. Often the spectral pattern behind cheap “white” light.
    ],
    chips: (
      data-chip([pump], [450 nm], accent: blue),
      data-chip([cyan], [weak], accent: blue),
      data-chip([red], [weak], accent: blue),
    ),
  ),

  archetype-card(
    [commodity white],
    [Commodity blue-pump LED],
    commodity-blue-pump,
    cyan + 0.95pt,
    cyan,
    [
      The blend is more acceptable, but the source is still visibly structured by the blue pump and phosphor package.
    ],
    chips: (
      data-chip([pump], [visible], accent: cyan),
      data-chip([cyan], [partial], accent: cyan),
      data-chip([red], [partial], accent: cyan),
    ),
  ),

  archetype-card(
    [better phosphor blend],
    [High-CRI blue-pump LED],
    high-cri-blue-pump,
    green + 0.95pt,
    green,
    [
      Better cyan and red fill. Still not thermal, still not daylight, but far better spectral coverage than a cheap blue-pump lamp.
    ],
    chips: (
      data-chip([pump], [present], accent: green),
      data-chip([cyan], [better], accent: green),
      data-chip([red], [better], accent: green),
    ),
  ),

  archetype-card(
    [violet-pump strategy],
    [Violet-pump full-spectrum LED],
    violet-pump,
    violet + 0.95pt,
    violet,
    [
      Moves the pump toward violet and rebuilds more of the visible spectrum through phosphors. The goal is less blue-spike dominance and smoother visible coverage.
    ],
    chips: (
      data-chip([pump], [~410 nm], accent: violet),
      data-chip([blue spike], [reduced], accent: violet),
      data-chip([coverage], [broad], accent: violet),
    ),
  ),

  archetype-card(
    [white by mixing],
    [RGB mixed white],
    rgb-white,
    red + 0.95pt,
    red,
    [
      Can land on a white appearance while leaving large gaps between primaries. Useful for color effects, weaker as a general-quality white source (understatement).
    ],
    chips: (
      data-chip([channels], [3], accent: red),
      data-chip([gaps], [large], accent: red),
      data-chip([white], [metameric], accent: red),
    ),
  ),
)
