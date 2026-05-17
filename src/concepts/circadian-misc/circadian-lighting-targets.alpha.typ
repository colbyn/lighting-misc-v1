#import "@preview/lilaq:0.6.0" as lq

// ============================================================================
// Standalone flyer: Circadian Light Is Scheduled Light
// -----------------------------------------------------------------------------
// This file is self-contained. It includes:
// - spectral plotting helpers
// - synthetic SPD archetypes
// - idealized circadian target SPDs
// - compact editorial components
// - a single flyer sheet built around the “timing layer” framing
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
  size: 9pt,
  fill: rgb("#24242a"),
)

#set par(
  justify: false,
  leading: 0.63em,
)

// ============================================================================
// Color science helpers
// ============================================================================

#let clamp(x, lo: 0.0, hi: 1.0) = {
  calc.min(hi, calc.max(lo, x))
}

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
  columns: (16pt, auto),
  column-gutter: 5pt,
  align: horizon,
  [#line(length: 16pt, stroke: s.stroke)],
  [#text(size: 6.7pt)[#s.label]],
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
      columns: (auto, auto, auto),
      column-gutter: 10pt,
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
  ylabel: text(size: 5.8pt)[Relative radiant power],
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
        column-gutter: 10pt,
        align: top,
        diagram,
        box(inset: (top: 18pt))[#series-legend(series, direction: "vertical")],
      )
    ]
  } else if placement == "bottom" {
    block(width: width)[
      #diagram
      #v(4pt)
      #align(center)[#series-legend(series, direction: "horizontal")]
    ]
  } else if placement == "top" {
    block(width: width)[
      #align(center)[#series-legend(series, direction: "horizontal")]
      #v(4pt)
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
  let c2 = 14387768.0
  let xr = x / 560.0
  let e = calc.exp(c2 / (x * temp))

  1.0 / (calc.pow(xr, 5.0) * (e - 1.0))
}

// ============================================================================
// Synthetic spectral archetypes
// ============================================================================

#let spd-daylight-reference(x) = {
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
  blackbody(x, 1900)
}

#let spd-incandescent(x) = {
  blackbody(x, 2700)
}

#let spd-halogen(x) = {
  blackbody(x, 3000)
}

#let spd-cheap-blue-pump(x) = {
  (
    gauss(x, 450, 11, amp: 1.22) +
    skewed-gauss(x, 560, 42, 78, amp: 0.82) +
    gauss(x, 610, 52, amp: 0.22) +
    gauss(x, 660, 34, amp: 0.055)
  )
}

#let spd-commodity-blue-pump(x) = {
  (
    gauss(x, 450, 14, amp: 0.64) +
    gauss(x, 520, 47, amp: 0.30) +
    skewed-gauss(x, 575, 58, 88, amp: 0.78) +
    gauss(x, 635, 72, amp: 0.34)
  )
}

#let spd-high-cri-blue-pump(x) = {
  (
    gauss(x, 450, 15, amp: 0.48) +
    gauss(x, 505, 47, amp: 0.40) +
    gauss(x, 560, 76, amp: 0.66) +
    gauss(x, 620, 84, amp: 0.64) +
    gauss(x, 665, 46, amp: 0.32)
  )
}

#let spd-violet-pump(x) = {
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
  #text(size: 6.5pt, weight: "bold", tracking: 0.09em, fill: fill)[
    #upper(body)
  ]
]

#let headline(body, size: 24pt, weight: "medium", fill: ink) = [
  #set par(justify: false)
  #text(size: size, weight: weight, fill: fill)[#body]
]

#let lede(body, width: 100%) = [
  #set par(justify: false)
  #block(width: width)[
    #set par(leading: 0.70em)
    #text(size: 12pt, fill: soft-ink)[#body]
  ]
]

#let copy-block(body, width: 100%, size: 8.6pt) = [
  #block(width: width)[
    #set par(leading: 0.63em)
    #text(size: size, fill: soft-ink)[#body]
  ]
]

#let spread-gap() = v(10pt)

#let evidence-card(title, body, accent: black) = [
  #block(
    width: 100%,
    inset: (x: 10pt, y: 9pt),
    radius: 7pt,
    fill: panel,
    stroke: hairline + 0.55pt,
  )[
    #fine-label(title, fill: accent)
    #v(4pt)
    #copy-block(body, width: 100%, size: 8.25pt)
  ]
]


// ============================================================================
// Circadian target SPDs
// -----------------------------------------------------------------------------
// Idealized relative SPDs for client-facing explanation.
// These are not product measurements and should not be read as compliance data.
//
// Design target logic:
// - Day: strong vertical light at the eye; high melanopic stimulus.
// - Evening: usable light with reduced short-wavelength stimulus.
// - Night: minimum useful light; protect darkness and avoid glare/spill.
//
// The actual quantity to specify for circadian design is not CCT alone. Use
// melanopic EDI at the eye when the non-visual / circadian effect matters.
// ============================================================================

#let spd-circadian-day(x) = {
  // Broad daylight-like white with strong short-wavelength presence.
  // Visual message: strong daytime clock signal.
  (
    gauss(x, 455, 38, amp: 0.82) +
    gauss(x, 505, 62, amp: 0.78) +
    gauss(x, 570, 82, amp: 0.88) +
    gauss(x, 650, 92, amp: 0.46)
  )
}

#let spd-circadian-evening(x) = {
  // Warm white with short wavelengths deliberately reduced.
  // Visual message: usable light, lower clock signal.
  (
    gauss(x, 455, 30, amp: 0.10) +
    gauss(x, 520, 70, amp: 0.28) +
    gauss(x, 595, 88, amp: 0.86) +
    gauss(x, 660, 78, amp: 0.64)
  )
}

#let spd-circadian-night(x) = {
  // Amber/red-biased navigation light.
  // Visual message: minimum biological signal.
  (
    gauss(x, 455, 26, amp: 0.015) +
    gauss(x, 525, 55, amp: 0.045) +
    gauss(x, 610, 48, amp: 0.42) +
    gauss(x, 660, 38, amp: 0.82)
  )
}

#let circadian-day = make-series(spd-circadian-day)
#let circadian-evening = make-series(spd-circadian-evening)
#let circadian-night = make-series(spd-circadian-night)

#let circadian-target-series = (
  (
    label: [day / strong clock signal],
    values: circadian-day,
    stroke: blue + 0.95pt,
    draw-area: false,
  ),
  (
    label: [evening / reduced signal],
    values: circadian-evening,
    stroke: amber + 0.95pt,
    draw-area: false,
  ),
  (
    label: [night / protected darkness],
    values: circadian-night,
    stroke: red + 0.95pt,
    draw-area: false,
  ),
)

#let daylight-reference-series = (
  (
    label: [idealized daylight reference],
    values: daylight,
    stroke: black + 0.85pt,
    draw-area: false,
  ),
)

// ============================================================================
// Circadian flyer components
// ============================================================================

#let time-rule = rgb("#e7e3d8")
#let day-fill = rgb("#f2f7ff")
#let evening-fill = rgb("#fff7ea")
#let night-fill = rgb("#fbf2ef")

#let compact-note(title, body, accent: black) = [
  #block(
    width: 100%,
    inset: (x: 8pt, y: 7pt),
    radius: 5pt,
    fill: white,
    stroke: hairline + 0.55pt,
  )[
    #fine-label(title, fill: accent)
    #v(3pt)
    #copy-block(body, size: 7.7pt)
  ]
]

#let target-chip(kicker, value, body, accent: black, fill: panel) = [
  #block(
    width: 100%,
    inset: (x: 9pt, y: 8pt),
    radius: 6pt,
    fill: fill,
    stroke: hairline + 0.55pt,
  )[
    #fine-label(kicker, fill: accent)
    #v(4pt)
    #text(size: 15pt, weight: "semibold", fill: ink)[#value]
    #v(3pt)
    #copy-block(body, size: 7.7pt)
  ]
]

#let timeline-stop(label, caption, signal, accent: black, fill: white) = [
  #block(
    width: 100%,
    inset: (x: 8pt, y: 7pt),
    radius: 7pt,
    fill: fill,
    stroke: hairline + 0.55pt,
  )[
    #fine-label(label, fill: accent)
    #v(4pt)
    #text(size: 9.4pt, weight: "semibold", fill: ink)[#caption]
    #v(4pt)
    #line(length: 100%, stroke: accent + 0.75pt)
    #v(4pt)
    #copy-block(signal, size: 7.5pt)
  ]
]

#let schedule-strip() = [
  #block(
    width: 100%,
    inset: (x: 10pt, y: 9pt),
    radius: 8pt,
    fill: rgb("#fdfdfb"),
    stroke: hairline + 0.55pt,
  )[
    #grid(
      columns: (0.98fr, 1.10fr, 0.98fr, 0.74fr),
      column-gutter: 7pt,
      align: top,
      timeline-stop(
        [morning],
        [wake the system],
        [High vertical light. Broad spectrum. Strong melanopic presence.],
        accent: blue,
        fill: day-fill,
      ),
      timeline-stop(
        [day],
        [hold the anchor],
        [Keep the biological day signal stable enough to support alertness.],
        accent: cyan,
        fill: rgb("#f1fbfb"),
      ),
      timeline-stop(
        [evening],
        [step the signal down],
        [Dimmer, warmer, lower short-wavelength content at the eye.],
        accent: amber,
        fill: evening-fill,
      ),
      timeline-stop(
        [night],
        [protect darkness],
        [Use only enough light for orientation, safety, and low-glare tasks.],
        accent: red,
        fill: night-fill,
      ),
    )
  ]
]

#let compare-circadian(a-label, a-values, a-stroke, b-label, b-values, b-stroke, title: [], height: 4.15cm) = {
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


#let spd-melanopic-weight(x) = {
  gauss(x, 490, 36, amp: 1.0) * sub-dip(x, 610, 90, depth: 0.40)
}

#let melanopic-weight = make-series(spd-melanopic-weight)

#let meter-row(label, width, value, accent: black) = [
  #grid(
    columns: (56pt, 1fr, auto),
    column-gutter: 6pt,
    align: horizon,
    [#text(size: 6.7pt, fill: mute)[#label]],
    [
      #block(
        width: 100%,
        inset: (x: 2pt, y: 2.5pt),
        radius: 99pt,
        fill: faint,
      )[
        #rect(width: width, height: 4.4pt, fill: accent, radius: 99pt)
      ]
    ],
    [#text(size: 6.7pt, weight: "medium", fill: soft-ink)[#value]],
  )
]

#let phase-panel(
  kicker,
  title,
  series-label,
  series-values,
  series-stroke,
  body,
  accent: black,
  fill: white,
  brightness-width: 80%,
  brightness-value: [high],
  blue-width: 80%,
  blue-value: [high],
  clock-width: 80%,
  clock-value: [high],
) = [
  #block(
    width: 100%,
    inset: (x: 10pt, y: 9pt),
    radius: 8pt,
    fill: fill,
    stroke: hairline + 0.55pt,
  )[
    #fine-label(kicker, fill: accent)
    #v(4pt)
    #text(size: 10.8pt, weight: "semibold", fill: ink)[#title]
    #v(7pt)
    #spectrum-plot(
      wl,
      title: [#text(size: 8.2pt)[Relative SPD]],
      height: 3.15cm,
      legend-position: "none",
      xlabel: text(size: 5.5pt)[Wavelength / nm],
      ylabel: text(size: 5.5pt)[Power],
      series: (
        (
          label: series-label,
          values: series-values,
          stroke: series-stroke,
          draw-area: true,
        ),
        (
          label: [melanopic band],
          values: melanopic-weight,
          stroke: violet + 0.75pt,
          draw-area: false,
        ),
      ),
    )
    #v(7pt)
    #meter-row([overall light], brightness-width, brightness-value, accent: accent)
    #v(2.5pt)
    #meter-row([blue-cyan content], blue-width, blue-value, accent: violet)
    #v(2.5pt)
    #meter-row([clock stimulus], clock-width, clock-value, accent: accent)
    #v(7pt)
    #copy-block(body, size: 7.6pt)
  ]
]

// ============================================================================
// Flyer content
// ============================================================================

== Circadian Light Is Scheduled Light

#grid(
  columns: (0.31fr, 1fr),
  column-gutter: 14pt,
  align: top,

  [
    #fine-label[the timing layer]

    #v(5pt)

    #headline(size: 27pt)[
      Light is a clock signal.
    ]

    #v(8pt)

    #lede[
      The same spectrum can support wakefulness by day and disturb rest at night.
    ]

    #v(10pt)

    #block(
      width: 100%,
      inset: (x: 8pt, y: 8pt),
      radius: 3pt,
      fill: white,
      stroke: hairline + 0.5pt,
    )[
      #fine-label[reading rule]
      #v(4pt)
      #copy-block(size: 8.45pt)[
        Do not ask only whether the light is warm or cool. Ask when the light appears, how much reaches the eye, and how melanopically active the spectrum is.
      ]
    ]
  ],

  [
    #spectrum-plot(
      wl,
      title: [Idealized circadian lighting targets],
      height: 8.55cm,
      legend-position: "bottom",
      xlabel: text(size: 5.7pt)[Wavelength / nm],
      ylabel: text(size: 5.7pt)[Relative radiant power],
      series: circadian-target-series,
    )
  ],
)

#v(8pt)

#schedule-strip()

#v(9pt)

#grid(
  columns: (1fr, 1fr, 1fr, 1fr),
  column-gutter: 8pt,
  align: top,

  target-chip(
    [daytime target],
    [high],
    [Enough melanopic stimulus at the eye to make the room read as biological day.],
    accent: blue,
    fill: day-fill,
  ),

  target-chip(
    [evening target],
    [low],
    [The same room shifts from alerting light toward calmer visual support.],
    accent: amber,
    fill: evening-fill,
  ),

  target-chip(
    [sleep target],
    [near zero],
    [Darkness is the design condition. Ambient light becomes an intrusion.],
    accent: red,
    fill: night-fill,
  ),

  target-chip(
    [night task target],
    [brief + dim],
    [Path, bathroom, and safety light should preserve orientation without waking the clock.],
    accent: violet,
    fill: rgb("#f8f3ff"),
  ),
)

#v(10pt)

#pagebreak()

#grid(
  columns: (0.37fr, 1fr),
  column-gutter: 14pt,
  align: top,

  [
    #fine-label[data view]
    #v(5pt)
    #headline(size: 24pt)[
      Where the clock sees the spectrum
    ]
    #v(8pt)
    #lede[
      Circadian lighting is not a color-temperature story. It is a short-wavelength management story, scaled by timing, intensity, and the amount of light reaching the eye.
    ]
    #v(10pt)
    #compact-note(
      [how to read this],
      [The violet curve is a simplified melanopic sensitivity band. Daylight-supportive light keeps substantial energy in that region. Evening and night progressively empty it out.],
      accent: violet,
    )
    #v(8pt)
    #compact-note(
      [design implication],
      [Do not specify “circadian” by CCT alone. A warm source can still be too bright at the eye, and a cool source can be ineffective if it is weak, badly aimed, or badly timed.],
      accent: amber,
    )
  ],

  [
    #spectrum-plot(
      wl,
      title: [Circadian targets against a simplified melanopic sensitivity band],
      height: 8.8cm,
      legend-position: "right",
      xlabel: text(size: 5.7pt)[Wavelength / nm],
      ylabel: text(size: 5.7pt)[Relative power],
      series: (
        (
          label: [day target],
          values: circadian-day,
          stroke: blue + 1.0pt,
          draw-area: false,
        ),
        (
          label: [evening target],
          values: circadian-evening,
          stroke: amber + 1.0pt,
          draw-area: false,
        ),
        (
          label: [night target],
          values: circadian-night,
          stroke: red + 0.95pt,
          draw-area: false,
        ),
        (
          label: [melanopic sensitivity],
          values: melanopic-weight,
          stroke: violet + 0.85pt,
          draw-area: false,
        ),
      ),
    )
  ],
)

#pagebreak()

#grid(
  columns: (1.02fr, 1.02fr, 1.02fr),
  column-gutter: 10pt,
  align: top,

  phase-panel(
    [day mode],
    [Anchor the biological day],
    [day target],
    circadian-day,
    blue + 1.0pt,
    [This is broad, bright, visually comfortable light with real blue-cyan presence at the eye. The goal is not a theatrical blue spike. The goal is a credible daytime signal that fills the room and reaches the observer.],
    accent: blue,
    fill: day-fill,
    brightness-width: 92%,
    brightness-value: [high],
    blue-width: 86%,
    blue-value: [high],
    clock-width: 90%,
    clock-value: [strong],
  ),

  phase-panel(
    [evening mode],
    [Step the signal down],
    [evening target],
    circadian-evening,
    amber + 1.0pt,
    [Evening light still supports faces, tasks, and hospitality, but the blue-cyan region is intentionally thinned. This is where dimming range, vertical light control, and scene scheduling start to matter.],
    accent: amber,
    fill: evening-fill,
    brightness-width: 54%,
    brightness-value: [moderate],
    blue-width: 24%,
    blue-value: [reduced],
    clock-width: 28%,
    clock-value: [low],
  ),

  phase-panel(
    [night mode],
    [Protect darkness],
    [night target],
    circadian-night,
    red + 0.95pt,
    [Night light is a special case. It should be brief, local, shielded, and low glare—good enough for orientation and safety, but poor at pretending that the night is still day.],
    accent: red,
    fill: night-fill,
    brightness-width: 16%,
    brightness-value: [minimal],
    blue-width: 4%,
    blue-value: [near zero],
    clock-width: 6%,
    clock-value: [near zero],
  ),
)

#v(9pt)

#grid(
  columns: (1fr, 1fr, 1fr),
  column-gutter: 8pt,
  align: top,

  evidence-card(
    [not a CCT rule],
    [Circadian design is not simply “cool by day, warm by night.” CCT hides intensity, spectrum shape, direction, duration, and timing.],
    accent: violet,
  ),

  evidence-card(
    [eye-level quantity],
    [The relevant exposure is the light reaching the eye, not only the lumens delivered to a table, wall, or floor.],
    accent: cyan,
  ),

  evidence-card(
    [architecture matters],
    [Indirect light, vertical surfaces, glare control, dimming range, and scheduling matter as much as the diode recipe.],
    accent: amber,
  ),
)
