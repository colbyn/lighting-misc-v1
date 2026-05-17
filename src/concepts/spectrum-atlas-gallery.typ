#import "@preview/lilaq:0.6.0" as lq

// ============================================================================
// Standalone one-page spectral atlas
// ============================================================================
// This file combines:
// - spectral plotting helpers
// - synthetic SPD archetypes
// - compact editorial components
// - a one-page 3 × 2 gallery / atlas layout
//
// Requires Typst package:
//   @preview/lilaq:0.6.0
// ============================================================================

#set page(
  paper: "us-letter",
  margin: (
    x: 0.20in,
    y: 0.20in,
  ),
  fill: white,
  flipped: true,
)

#set text(
  font: "Avenir Next",
  size: 9.2pt,
  fill: rgb("#24242a"),
)

#set par(
  leading: 0.62em,
  justify: false,
)

// ============================================================================
// Color science helpers
// ============================================================================

#let clamp(x, lo: 0.0, hi: 1.0) = {
  calc.min(hi, calc.max(lo, x))
}

// Analytic approximation to the CIE 1931 2° color matching functions.
// Based on Wyman, Sloan, Shirley:
// "Simple Analytic Approximations to the CIE XYZ Color Matching Functions"
#let asymmetric-gaussian(x, center, left-scale, right-scale, amp: 1.0) = {
  let t = if x < center {
    (x - center) * left-scale
  } else {
    (x - center) * right-scale
  }

  amp * calc.exp(-0.5 * t * t)
}

#let cie-x(l) = {
  let x1 = asymmetric-gaussian(l, 442.0, 0.0624, 0.0374, amp: 0.362)
  let x2 = asymmetric-gaussian(l, 599.8, 0.0264, 0.0323, amp: 1.056)
  let x3 = asymmetric-gaussian(l, 501.1, 0.0490, 0.0382, amp: 0.065)

  x1 + x2 - x3
}

#let cie-y(l) = {
  let y1 = asymmetric-gaussian(l, 568.8, 0.0213, 0.0247, amp: 0.821)
  let y2 = asymmetric-gaussian(l, 530.9, 0.0613, 0.0322, amp: 0.286)

  y1 + y2
}

#let cie-z(l) = {
  let z1 = asymmetric-gaussian(l, 437.0, 0.0845, 0.0278, amp: 1.217)
  let z2 = asymmetric-gaussian(l, 459.0, 0.0385, 0.0725, amp: 0.681)

  z1 + z2
}

#let srgb-encode(u) = {
  let u = clamp(u)

  if u <= 0.0031308 {
    12.92 * u
  } else {
    1.055 * calc.pow(u, 1.0 / 2.4) - 0.055
  }
}

#let wavelength-rgb(l) = {
  if l < 380 or l > 780 {
    rgb(0, 0, 0)
  } else {
    let x = cie-x(l)
    let y = cie-y(l)
    let z = cie-z(l)

    // XYZ -> linear sRGB, D65
    let r-lin = 3.2406 * x - 1.5372 * y - 0.4986 * z
    let g-lin = -0.9689 * x + 1.8758 * y + 0.0415 * z
    let b-lin = 0.0557 * x - 0.2040 * y + 1.0570 * z

    let r = srgb-encode(r-lin)
    let g = srgb-encode(g-lin)
    let b = srgb-encode(b-lin)

    rgb(
      int(calc.round(r * 255)),
      int(calc.round(g * 255)),
      int(calc.round(b * 255)),
    )
  }
}

// ============================================================================
// Plot construction
// ============================================================================

#let spectral-area-strips(wavelengths, values, z-index: 1) = {
  let strips = ()

  for i in range(values.len() - 1) {
    let x1 = wavelengths.at(i)
    let x2 = wavelengths.at(i + 1)
    let y1 = values.at(i)
    let y2 = values.at(i + 1)
    let mid = (x1 + x2) / 2

    strips.push(
      lq.fill-between(
        (x1, x2),
        (y1, y2),
        fill: wavelength-rgb(mid),
        stroke: none,
        smooth: false,
        z-index: z-index,
      )
    )
  }

  strips
}

#let legend-item(s) = grid(
  columns: (14pt, auto),
  column-gutter: 4pt,
  align: horizon,
  [#line(length: 14pt, stroke: s.stroke)],
  [#text(size: 6.8pt)[#s.label]],
)

#let series-legend(series, direction: "horizontal") = {
  let cells = ()

  for s in series {
    cells.push(legend-item(s))
  }

  if direction == "vertical" {
    grid(
      columns: (auto,),
      row-gutter: 3pt,
      ..cells,
    )
  } else {
    grid(
      columns: (auto, auto),
      column-gutter: 9pt,
      row-gutter: 3pt,
      ..cells,
    )
  }
}

#let auto-legend-placement(series) = {
  if series.len() > 3 {
    "right"
  } else {
    "bottom"
  }
}

#let spectrum-plot(
  wavelengths,
  title: [Relative spectral power distribution],
  series: (),
  width: 100%,
  height: 4cm,
  legend-position: auto,
  xlabel: text(size: 5.8pt)[Wavelength / nm],
  ylabel: text(size: 5.8pt)[Relative power],
  xlim: none,
  ylim: (0, 1.08),
) = {
  let plots = ()

  let resolved-xlim = if xlim == none {
    (wavelengths.first(), wavelengths.last())
  } else {
    xlim
  }

  for s in series {
    if s.at("draw-area", default: false) {
      for strip in spectral-area-strips(wavelengths, s.values, z-index: 1) {
        plots.push(strip)
      }
    }

    plots.push(
      lq.plot(
        wavelengths,
        s.values,
        label: none,
        mark: none,
        smooth: true,
        stroke: s.stroke,
        z-index: 2,
      )
    )
  }

  let diagram = lq.diagram(
    width: 100%,
    height: height,
    title: title,
    xlabel: xlabel,
    ylabel: ylabel,
    xlim: resolved-xlim,
    ylim: ylim,
    legend: none,
    ..plots,
  )

  let placement = if legend-position == auto {
    auto-legend-placement(series)
  } else {
    legend-position
  }

  if placement == "right" {
    block(width: width)[
      #grid(
        columns: (1fr, auto),
        column-gutter: 8pt,
        align: top,
        diagram,
        box(inset: (top: 18pt))[#series-legend(series, direction: "vertical")],
      )
    ]
  } else if placement == "bottom" {
    block(width: width)[
      #diagram
      #v(3pt)
      #align(center)[#series-legend(series, direction: "horizontal")]
    ]
  } else if placement == "top" {
    block(width: width)[
      #align(center)[#series-legend(series, direction: "horizontal")]
      #v(3pt)
      #diagram
    ]
  } else {
    diagram
  }
}

// ============================================================================
// Spectral data primitives
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

#let spd-incandescent(x) = {
  // Household tungsten archetype.
  blackbody(x, 2700)
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
#let incandescent = make-series(spd-incandescent)
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
#let panel = rgb("#fcfcff")
#let faint = rgb("#f5f5f8")
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
  #text(size: 6.3pt, weight: "bold", tracking: 0.09em, fill: fill)[
    #upper(body)
  ]
]

#let headline(body, size: 19pt, weight: "medium", fill: ink) = [
  #set par(justify: false)
  #text(size: size, weight: weight, fill: fill)[#body]
]

#let lede(body, width: 100%) = [
  #set par(justify: false)
  #block(width: width)[
    #set par(leading: 0.68em)
    #text(size: 10.4pt, fill: soft-ink)[#body]
  ]
]

#let copy-block(body, width: 100%, size: 8.3pt) = [
  #block(width: width)[
    #set par(leading: 0.62em)
    #text(size: size, fill: soft-ink)[#body]
  ]
]

#let data-chip(label, value, accent: black) = [
  #block(
    inset: (x: 4.4pt, y: 2.5pt),
    radius: 3.2pt,
    fill: rgb("#ffffff"),
    stroke: hairline + 0.45pt,
  )[
    #text(size: 5.4pt, weight: "bold", tracking: 0.04em, fill: mute)[
      #upper(label)
    ]

    #text(size: 6.7pt, weight: "medium", fill: accent)[#value]
  ]
]

#let reading-note(label, body, accent: black) = [
  #block(
    width: 100%,
    inset: (x: 7pt, y: 6pt),
    radius: 3pt,
    fill: white,
    stroke: hairline + 0.55pt,
  )[
    #fine-label(label, fill: accent)
    #v(2pt)
    #copy-block(body, size: 7.55pt)
  ]
]

// ============================================================================
// Plot helpers
// ============================================================================

#let daylight-series = (
  (
    label: [daylight reference],
    values: daylight,
    stroke: black + 0.8pt,
    draw-area: false,
  ),
)

#let compare-to-daylight(label, values, stroke, title: [], height: 2.25cm, area: true) = {
  spectrum-plot(
    wl,
    title: title,
    height: height,
    legend-position: "bottom",
    xlabel: text(size: 5.25pt)[Wavelength / nm],
    ylabel: text(size: 5.25pt)[Relative power],
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

#let atlas-card(eyebrow, title, values, stroke, accent, chips: ()) = [
  #block(
    width: 100%,
    inset: (x: 6.5pt, y: 6.3pt),
    radius: 3pt,
    fill: white,
    stroke: hairline + 0.6pt,
    breakable: false,
  )[
    #fine-label(eyebrow, fill: accent)
    #v(1.5pt)
    #text(size: 9pt, weight: "medium", fill: ink)[#title]

    #v(2.5pt)

    #compare-to-daylight(
      title,
      values,
      stroke,
      title: [],
      height: 2.5cm,
      area: true,
    )

    #v(2pt)

    #if chips.len() > 0 [
      #grid(
        columns: (auto, auto, auto),
        column-gutter: 2.6pt,
        row-gutter: 2.6pt,
        ..chips,
      )
    ]
  ]
]

// ============================================================================
// One-page atlas
// ============================================================================

#grid(
  columns: (0.36fr, 1fr),
  column-gutter: 18pt,
  align: top,

  [
    #fine-label[Spectral atlas]
    #v(4pt)

    #headline(size: 16pt)[
      Not warm versus cool.
    ]

    #v(4pt)

    #headline(size: 16pt)[
      Where is the energy?
    ]
  ],

  [
    #lede[
      A white-light spectrum is an energy distribution, not a color name. The useful habit is to read the machinery: pump, gap, phosphor hump, and red tail.
    ]

    #v(8pt)

    #grid(
      columns: (1fr, 1fr, 1fr, 1fr),
      column-gutter: 5.5pt,
      align: top,

      reading-note(
        [pump],
        [Find the narrow source peak: usually blue around 450 nm, sometimes violet near 405 nm.],
        accent: blue,
      ),

      reading-note(
        [gap],
        [Check whether cyan is weak. A blue-green depression can matter visually and biologically.],
        accent: cyan,
      ),

      reading-note(
        [phosphor hump],
        [Read the broad converted output. This is where much of the visible “white” is assembled.],
        accent: green,
      ),

      reading-note(
        [red tail],
        [Look at how far the spectrum carries into deep red: rendering, warmth, and material appearance live there.],
        accent: red,
      ),
    )
  ],
)

#v(12pt)

#grid(
  columns: (1fr, 1fr, 1fr),
  column-gutter: 7pt,
  row-gutter: 7pt,
  align: top,

  atlas-card(
    [thermal continuum],
    [Incandescent],
    incandescent,
    amber + 0.9pt,
    amber,
    chips: (
      data-chip([shape], [smooth], accent: amber),
      data-chip([blue], [low], accent: amber),
      data-chip([red], [high], accent: amber),
    ),
  ),

  atlas-card(
    [blue-pump minimum],
    [Cheap blue-pump LED],
    cheap-blue-pump,
    blue + 0.9pt,
    blue,
    chips: (
      data-chip([pump], [450 nm], accent: blue),
      data-chip([cyan], [weak], accent: blue),
      data-chip([red], [weak], accent: blue),
    ),
  ),

  atlas-card(
    [commodity white],
    [Commodity blue-pump LED],
    commodity-blue-pump,
    cyan + 0.9pt,
    cyan,
    chips: (
      data-chip([pump], [visible], accent: cyan),
      data-chip([cyan], [partial], accent: cyan),
      data-chip([red], [partial], accent: cyan),
    ),
  ),

  atlas-card(
    [better phosphor blend],
    [High-CRI blue-pump LED],
    high-cri-blue-pump,
    green + 0.9pt,
    green,
    chips: (
      data-chip([pump], [present], accent: green),
      data-chip([cyan], [better], accent: green),
      data-chip([red], [better], accent: green),
    ),
  ),

  atlas-card(
    [violet-pump strategy],
    [Violet-pump full-spectrum LED],
    violet-pump,
    violet + 0.9pt,
    violet,
    chips: (
      data-chip([pump], [~410 nm], accent: violet),
      data-chip([blue spike], [reduced], accent: violet),
      data-chip([coverage], [broad], accent: violet),
    ),
  ),

  atlas-card(
    [white by mixing],
    [RGB mixed white],
    rgb-white,
    red + 0.9pt,
    red,
    chips: (
      data-chip([channels], [3], accent: red),
      data-chip([gaps], [large], accent: red),
      data-chip([white], [metameric], accent: red),
    ),
  ),
)

#v(8pt)

#block(
  width: 100%,
  inset: (x: 9pt, y: 7pt),
  radius: 3pt,
  fill: white,
  stroke: hairline + 0.55pt,
)[
  #grid(
    columns: (0.16fr, 1fr),
    column-gutter: 8pt,
    align: horizon,
    [#fine-label[reading rule]],
    [#text(size: 8.15pt, fill: soft-ink)[A white appearance is not enough information. Ask where the energy is, where it is missing, and whether the source is continuous, phosphor-converted, or channel-mixed.]],
  )
]
