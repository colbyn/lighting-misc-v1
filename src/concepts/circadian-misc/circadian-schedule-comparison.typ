#import "@preview/lilaq:0.6.0" as lq

// ============================================================================
// Standalone flyer: Spectrum Has a Schedule
// -----------------------------------------------------------------------------
// This file explores circadian lighting as a time-varying spectral strategy.
// It presents:
// - an idealized SPD schedule over the day
// - the rationale for why the spectrum changes with time
// - a comparison against common real-world approaches
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
  columns: (14pt, auto),
  column-gutter: 4pt,
  align: horizon,
  [#line(length: 14pt, stroke: s.stroke)],
  [#text(size: 6.4pt)[#s.label]],
)

#let series-legend(series, direction: "horizontal") = {
  let cells = ()

  for s in series {
    cells.push(legend-item(s))
  }

  if direction == "vertical" {
    grid(
      columns: (auto,),
      row-gutter: 2.5pt,
      ..cells,
    )
  } else {
    grid(
      columns: (auto, auto, auto, auto),
      column-gutter: 8pt,
      row-gutter: 2.5pt,
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
  xlabel: text(size: 5.6pt)[Wavelength / nm],
  ylabel: text(size: 5.6pt)[Power],
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
        column-gutter: 9pt,
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
  } else if placement == "none" {
    diagram
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
// Spectral archetypes
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

#let spd-circadian-day(x) = {
  (
    gauss(x, 455, 38, amp: 0.82) +
    gauss(x, 505, 62, amp: 0.78) +
    gauss(x, 570, 82, amp: 0.88) +
    gauss(x, 650, 92, amp: 0.46)
  )
}

#let spd-circadian-morning(x) = {
  (
    gauss(x, 455, 36, amp: 0.72) +
    gauss(x, 505, 58, amp: 0.72) +
    gauss(x, 570, 82, amp: 0.84) +
    gauss(x, 650, 88, amp: 0.42)
  )
}

#let spd-circadian-evening(x) = {
  (
    gauss(x, 455, 30, amp: 0.10) +
    gauss(x, 520, 70, amp: 0.28) +
    gauss(x, 595, 88, amp: 0.86) +
    gauss(x, 660, 78, amp: 0.64)
  )
}

#let spd-circadian-night(x) = {
  (
    gauss(x, 455, 26, amp: 0.015) +
    gauss(x, 525, 55, amp: 0.045) +
    gauss(x, 610, 48, amp: 0.42) +
    gauss(x, 660, 38, amp: 0.82)
  )
}

#let spd-static-neutral(x) = {
  (
    gauss(x, 450, 15, amp: 0.54) +
    gauss(x, 505, 46, amp: 0.34) +
    gauss(x, 575, 78, amp: 0.82) +
    gauss(x, 638, 70, amp: 0.34)
  )
}

#let spd-static-warm(x) = {
  (
    gauss(x, 452, 18, amp: 0.18) +
    gauss(x, 525, 55, amp: 0.28) +
    gauss(x, 600, 86, amp: 0.92) +
    gauss(x, 665, 64, amp: 0.58)
  )
}

#let spd-basic-tunable-day(x) = {
  (
    gauss(x, 452, 16, amp: 0.45) +
    gauss(x, 510, 50, amp: 0.32) +
    gauss(x, 582, 82, amp: 0.80) +
    gauss(x, 642, 72, amp: 0.36)
  )
}

#let spd-basic-tunable-evening(x) = {
  (
    gauss(x, 452, 18, amp: 0.16) +
    gauss(x, 525, 58, amp: 0.26) +
    gauss(x, 600, 88, amp: 0.88) +
    gauss(x, 665, 68, amp: 0.58)
  )
}

#let spd-melanopic-weight(x) = {
  gauss(x, 490, 36, amp: 1.0) * sub-dip(x, 610, 90, depth: 0.40)
}

#let daylight = make-series(spd-daylight-reference)
#let circadian-morning = make-series(spd-circadian-morning)
#let circadian-day = make-series(spd-circadian-day)
#let circadian-evening = make-series(spd-circadian-evening)
#let circadian-night = make-series(spd-circadian-night)
#let static-neutral = make-series(spd-static-neutral)
#let static-warm = make-series(spd-static-warm)
#let basic-tunable-day = make-series(spd-basic-tunable-day)
#let basic-tunable-evening = make-series(spd-basic-tunable-evening)
#let melanopic-weight = make-series(spd-melanopic-weight)

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

#let day-fill = rgb("#f2f7ff")
#let evening-fill = rgb("#fff7ea")
#let night-fill = rgb("#fbf2ef")
#let morning-fill = rgb("#f3f8ff")
#let cool-fill = rgb("#f5f8ff")
#let warm-fill = rgb("#fff8ef")

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

#let copy-block(body, width: 100%, size: 8.5pt) = [
  #block(width: width)[
    #set par(leading: 0.63em)
    #text(size: size, fill: soft-ink)[#body]
  ]
]

#let evidence-card(title, body, accent: black, fill: panel) = [
  #block(
    width: 100%,
    inset: (x: 10pt, y: 9pt),
    radius: 7pt,
    fill: fill,
    stroke: hairline + 0.55pt,
  )[
    #fine-label(title, fill: accent)
    #v(4pt)
    #copy-block(body, size: 8.0pt)
  ]
]

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
    #copy-block(body, size: 7.6pt)
  ]
]

#let meter-row(label, width, value, accent: black) = [
  #grid(
    columns: (52pt, 1fr, auto),
    column-gutter: 6pt,
    align: horizon,
    [#text(size: 6.4pt, fill: mute)[#label]],
    [
      #block(
        width: 100%,
        inset: (x: 2pt, y: 2.5pt),
        radius: 99pt,
        fill: faint,
      )[
        #rect(width: width, height: 4.2pt, fill: accent, radius: 99pt)
      ]
    ],
    [#text(size: 6.4pt, weight: "medium", fill: soft-ink)[#value]],
  )
]

#let phase-card(
  kicker,
  title,
  values,
  stroke,
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
    inset: (x: 9pt, y: 8pt),
    radius: 8pt,
    fill: fill,
    stroke: hairline + 0.55pt,
  )[
    #fine-label(kicker, fill: accent)
    #v(4pt)
    #text(size: 10pt, weight: "semibold", fill: ink)[#title]
    #v(6pt)
    #spectrum-plot(
      wl,
      title: [#text(size: 8pt)[Relative SPD]],
      height: 2.75cm,
      legend-position: "none",
      xlabel: text(size: 5.2pt)[nm],
      ylabel: text(size: 5.2pt)[power],
      series: (
        (
          label: [target],
          values: values,
          stroke: stroke,
          draw-area: true,
        ),
        (
          label: [melanopic band],
          values: melanopic-weight,
          stroke: violet + 0.72pt,
          draw-area: false,
        ),
      ),
    )
    #v(6pt)
    #meter-row([overall light], brightness-width, brightness-value, accent: accent)
    #v(2pt)
    #meter-row([blue-cyan], blue-width, blue-value, accent: violet)
    #v(2pt)
    #meter-row([clock signal], clock-width, clock-value, accent: accent)
    #v(6pt)
    #copy-block(body, size: 7.45pt)
  ]
]

#let matrix-head(label) = [
  #block(
    width: 100%,
    inset: (x: 6pt, y: 6pt),
    radius: 5pt,
    fill: faint,
    stroke: hairline + 0.45pt,
  )[
    #align(center)[#text(size: 7pt, weight: "semibold", fill: ink)[#label]]
  ]
]

#let row-label(title, body, accent: black, fill: panel) = [
  #block(
    width: 100%,
    inset: (x: 4pt, y: 4pt),
    radius: 3pt,
    fill: fill,
    stroke: hairline + 0.55pt,
  )[
    #fine-label[approach, fill: accent]
    #text(size: 9.2pt, weight: "semibold", fill: ink)[#title]
    #copy-block(body, size: 7.35pt)
  ]
]

#let verdict-chip(text-body, accent: black, fill: white) = [
  #box(
    inset: (x: 5pt, y: 2pt),
    radius: 99pt,
    fill: fill,
    stroke: accent + 0.55pt,
  )[
    #text(size: 6pt, weight: "semibold", fill: accent)[#upper(text-body)]
  ]
]

#let matrix-cell(values, stroke, verdict, note, accent: black, fill: white) = [
  #block(
    width: 100%,
    inset: (x: 4pt, y: 4pt),
    radius: 3pt,
    fill: fill,
    stroke: hairline + 0.55pt,
  )[
    #align(left)[#verdict-chip(verdict, accent: accent, fill: white)]
    #spectrum-plot(
      wl,
      title: [#text(size: 7.7pt)[SPD]],
      height: 1.75cm,
      legend-position: "none",
      xlabel: text(size: 4.8pt)[nm],
      ylabel: text(size: 4.8pt)[p],
      series: (
        (
          label: [case],
          values: values,
          stroke: stroke,
          draw-area: true,
        ),
      ),
    )
    #copy-block(note, size: 6.95pt)
  ]
]

// ============================================================================
// Flyer content: Page 1
// ============================================================================

== Spectrum Has a Schedule

#grid(
  columns: (0.34fr, 1fr),
  column-gutter: 14pt,
  align: top,

  [
    #fine-label[circadian sequence]
    #v(5pt)
    #headline(size: 27pt)[
      The right spectrum depends on the hour.
    ]
    #v(8pt)
    #lede[
      Circadian lighting is not one SPD. It is a sequence: supportive by day, restrained by evening, and sparse by night.
    ]
    #v(10pt)
    #compact-note(
      [core idea],
      [The spectrum changes because the biological job changes. Daytime light should reinforce wakefulness. Evening light should reduce the alerting signal. Night light should preserve darkness while still supporting safety.],
      accent: blue,
    )
    #v(8pt)
    #compact-note(
      [what the eye reads],
      [The most important shift is not cosmetic warmth. It is the amount of energy left in the blue-cyan region, combined with timing, brightness, and the amount of light reaching the eye.],
      accent: violet,
    )
  ],

  [
    TODO
  ],
)

#pagebreak()

#grid(
  columns: (1fr, 1fr, 1fr, 1fr),
  column-gutter: 9pt,
  align: top,

  phase-card(
    [morning],
    [Start the day],
    circadian-morning,
    cyan + 0.95pt,
    [Morning light should begin rebuilding the daytime signal: broad, bright, and visibly active in the blue-cyan region.],
    accent: cyan,
    fill: morning-fill,
    brightness-width: 72%,
    brightness-value: [rising],
    blue-width: 74%,
    blue-value: [strong],
    clock-width: 76%,
    clock-value: [high],
  ),

  phase-card(
    [day],
    [Anchor the clock],
    circadian-day,
    blue + 1.0pt,
    [This is the strongest daytime condition: broad-spectrum light with enough vertical and ambient presence to make the room read as biological day.],
    accent: blue,
    fill: day-fill,
    brightness-width: 92%,
    brightness-value: [high],
    blue-width: 86%,
    blue-value: [high],
    clock-width: 90%,
    clock-value: [strong],
  ),

  phase-card(
    [evening],
    [Step the signal down],
    circadian-evening,
    amber + 1.0pt,
    [Evening light still supports hospitality and tasks, but the short-wavelength content is intentionally thinned and overall light levels begin to fall.],
    accent: amber,
    fill: evening-fill,
    brightness-width: 48%,
    brightness-value: [moderate],
    blue-width: 22%,
    blue-value: [reduced],
    clock-width: 26%,
    clock-value: [low],
  ),

  phase-card(
    [night],
    [Protect darkness],
    circadian-night,
    red + 0.95pt,
    [Night light is a special case: local, shielded, low-glare, and used only where needed. The point is orientation, not prolonging the day.],
    accent: red,
    fill: night-fill,
    brightness-width: 14%,
    brightness-value: [minimal],
    blue-width: 4%,
    blue-value: [near zero],
    clock-width: 6%,
    clock-value: [near zero],
  ),
)

#pagebreak()

#grid(
  columns: (1.15fr, 1fr),
  column-gutter: 12pt,
  align: top,

  [
    #spectrum-plot(
      wl,
      title: [How the ideal schedule moves across the day],
      height: 6.9cm,
      legend-position: "right",
      xlabel: text(size: 5.7pt)[Wavelength / nm],
      ylabel: text(size: 5.7pt)[Relative power],
      series: (
        (
          label: [morning],
          values: circadian-morning,
          stroke: cyan + 0.95pt,
          draw-area: false,
        ),
        (
          label: [day],
          values: circadian-day,
          stroke: blue + 1.0pt,
          draw-area: false,
        ),
        (
          label: [evening],
          values: circadian-evening,
          stroke: amber + 0.95pt,
          draw-area: false,
        ),
        (
          label: [night],
          values: circadian-night,
          stroke: red + 0.95pt,
          draw-area: false,
        ),
      ),
    )
  ],

  [
    #evidence-card(
      [the rationale],
      [The visual logic is simple. The day needs broad, clock-strength light. Evening reduces the short-wavelength driver and begins lowering overall exposure. Night strips that signal down to the minimum useful condition.],
      accent: black,
    )
    #v(8pt)
    #evidence-card(
      [not just warmer],
      [Warmth alone is not enough. A warm source can still be too bright, too unshielded, or too persistent at the eye. Circadian design is a schedule, not a single color cue.],
      accent: amber,
      fill: warm-fill,
    )
    #v(8pt)
    #evidence-card(
      [architectural consequence],
      [Controls, dimming range, glare management, vertical illumination, and scene timing matter as much as the emitter recipe. The SPD is only one layer of the system.],
      accent: violet,
    )
  ],
)

#v(9pt)

#grid(
  columns: (1fr, 1fr, 1fr),
  column-gutter: 8pt,
  align: top,

  evidence-card(
    [daytime problem],
    [A static warm source usually underperforms in the daytime because it never builds a convincing biological day signal.],
    accent: blue,
  ),

  evidence-card(
    [evening problem],
    [A static neutral or cool source often remains too biologically active deep into the evening, especially when bright vertical surfaces stay on.],
    accent: amber,
  ),

  evidence-card(
    [night problem],
    [The night condition is not “less of the same.” It is a different operating mode with a different spectral and architectural goal.],
    accent: red,
  ),
)

// ============================================================================
// Flyer content: Next Page
// ============================================================================

#pagebreak()

#grid(
  columns: (0.36fr, 1fr),
  column-gutter: 14pt,
  align: top,
  [
    #fine-label[comparison]
    #v(5pt)
    #headline(size: 24pt)[
      Compare that to what the market usually does
    ]
    #v(8pt)
    #lede[
      Most lighting systems do not change their SPD strategy enough across the day. The result is predictable: underpowered daytime light, overactive evening light, or both.
    ]
    #v(10pt)
    #compact-note(
      [how to read the matrix],
      [Each row is a lighting approach. Each column is a time of day. The best case changes its spectrum and intensity target as the day unfolds. The weaker cases stay too static or shift too little.],
      accent: violet,
    )
  ]
)

// ============================================================================
// Flyer content: Next Page
// ============================================================================

#pagebreak()

#set page(
  paper: "us-letter",
  margin: (
    x: 0.1in,
    y: 0.1in,
  ),
  fill: white,
  flipped: true,
)

#grid(
  columns: (0.74fr, 1fr, 1fr, 1fr, 1fr),
  column-gutter: 8pt,
  row-gutter: 8pt,
  align: top,

  [],
  matrix-head([morning]),
  matrix-head([day]),
  matrix-head([evening]),
  matrix-head([night]),

  row-label(
    [Ideal scheduled spectrum],
    [A purposeful sequence: rising signal in the morning, strong daytime anchor, lowered evening load, and protected darkness at night.],
    accent: blue,
    fill: day-fill,
  ),
  matrix-cell(circadian-morning, cyan + 0.95pt, [on target], [Builds the signal early rather than waiting until midday.], accent: cyan, fill: morning-fill),
  matrix-cell(circadian-day, blue + 1.0pt, [on target], [Broad and biologically active enough to establish daytime.], accent: blue, fill: day-fill),
  matrix-cell(circadian-evening, amber + 0.95pt, [on target], [Steps the system down without abandoning usability.], accent: amber, fill: evening-fill),
  matrix-cell(circadian-night, red + 0.95pt, [on target], [Low, local, and almost empty in the blue-cyan region.], accent: red, fill: night-fill),

  row-label(
    [Static neutral / office-white],
    [A common 3500–4000 K style approach. It can feel serviceable all day, but that is the problem: it keeps saying the same thing biologically.],
    accent: cyan,
    fill: cool-fill,
  ),
  matrix-cell(static-neutral, cyan + 0.9pt, [acceptable], [Not disastrous in the morning, but still generic rather than targeted.], accent: cyan, fill: white),
  matrix-cell(static-neutral, cyan + 0.9pt, [weaker than ideal], [Usable, but often not robust enough as a true daytime anchor.], accent: blue, fill: white),
  matrix-cell(static-neutral, cyan + 0.9pt, [too active], [The same spectral shape now carries too much blue-cyan content.], accent: amber, fill: white),
  matrix-cell(static-neutral, cyan + 0.9pt, [bad at night], [A static neutral spectrum is the wrong night condition.], accent: red, fill: white),

  row-label(
    [Static warm-white],
    [A common 2700–3000 K strategy. Better for evening comfort, but usually too weak as an all-day biological strategy and still not truly a night mode.],
    accent: amber,
    fill: warm-fill,
  ),
  matrix-cell(static-warm, amber + 0.9pt, [soft start], [Comfortable, but it begins the day with a compromised signal.], accent: amber, fill: white),
  matrix-cell(static-warm, amber + 0.9pt, [underpowered], [The daytime signal remains too weak and too static.], accent: blue, fill: white),
  matrix-cell(static-warm, amber + 0.9pt, [closer], [Better aligned with evening than a neutral static source.], accent: green, fill: white),
  matrix-cell(static-warm, amber + 0.9pt, [still not night], [Even warm-white is often too bright and too room-filling for night use.], accent: red, fill: white),

  row-label(
    [Basic tunable white],
    [A better control layer: cooler by day, warmer by evening. But many systems only move CCT, not enough intensity, glare, or spectral restraint.],
    accent: violet,
    fill: rgb("#f8f3ff"),
  ),
  matrix-cell(basic-tunable-day, blue + 0.9pt, [good], [Morning performance is better because the system at least begins to aim upward.], accent: blue, fill: white),
  matrix-cell(basic-tunable-day, blue + 0.9pt, [good], [Often the closest common option to the ideal daytime case.], accent: green, fill: white),
  matrix-cell(basic-tunable-evening, amber + 0.9pt, [better], [A real improvement, but still depends heavily on dimming and scene discipline.], accent: amber, fill: white),
  matrix-cell(basic-tunable-evening, amber + 0.9pt, [incomplete], [Without a true night scene, it usually stops short of darkness protection.], accent: red, fill: white),
)
