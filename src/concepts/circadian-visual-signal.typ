#import "@preview/lilaq:0.6.0" as lq

/*
Circadian visual signal sheet — graph-first redesign, v2.

This is a full replacement, not a patch.

Intent:
- Do not explain circadian lighting as a set of boxes.
- Do not make every time curve the same hill.
- Show the difficult part visually: the same photons have different biological
  meaning depending on clock time, spectrum, intensity, and duration.

Design move:
- Use graphs that conflict with each other instead of repeating the same ramp.
- Put the phase-response curve near the front: evening light and morning light
  do opposite things.
- Use small-multiple SPDs only after the time logic is visible.
- Leave room for later commentary; this file is the visual argument.
*/

#set page(
  paper: "us-letter",
  flipped: true,
  margin: (x: 0.34in, y: 0.30in),
  fill: white,
)

#set text(font: "Avenir Next", size: 9pt, fill: rgb("#23242a"))
#set par(justify: false, leading: 0.66em)

// -----------------------------------------------------------------------------
// Color and editorial tokens
// -----------------------------------------------------------------------------

#let ink = rgb("#23242a")
#let soft = rgb("#50525d")
#let mute = rgb("#777985")
#let hair = rgb("#ddddE8")
#let faint = rgb("#f6f7fb")

#let blue = rgb("#005eff")
#let cyan = rgb("#0097a7")
#let green = rgb("#3a9a00")
#let violet = rgb("#7a3cff")
#let amber = rgb("#bd6a00")
#let red = rgb("#b03a3a")
#let blackish = rgb("#111111")

#let label(body, fill: mute) = text(size: 6.5pt, weight: "bold", tracking: 0.10em, fill: fill)[#upper(body)]
#let headline(body, size: 29pt) = text(size: size, weight: "medium", fill: ink)[#body]
#let lede(body, size: 13pt) = block(width: 100%)[
  #set par(leading: 0.74em)
  #text(size: size, fill: soft)[#body]
]
#let note(body, size: 8.4pt, fill: soft) = block(width: 100%)[
  #set par(leading: 0.66em)
  #text(size: size, fill: fill)[#body]
]
#let rule(stroke: hair + 0.6pt) = line(length: 100%, stroke: stroke)

// -----------------------------------------------------------------------------
// Generic helpers
// -----------------------------------------------------------------------------

#let clamp(x, lo: 0.0, hi: 1.0) = calc.min(hi, calc.max(lo, x))
#let mix(a, b, t) = a + (b - a) * t
#let segment(x, x0, x1, y0, y1) = {
  if x <= x0 {
    y0
  } else if x >= x1 {
    y1
  } else {
    mix(y0, y1, (x - x0) / (x1 - x0))
  }
}

// -----------------------------------------------------------------------------
// Spectral plotting helpers
// -----------------------------------------------------------------------------

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
    let r = srgb-encode(3.2406 * x - 1.5372 * y - 0.4986 * z)
    let g = srgb-encode(-0.9689 * x + 1.8758 * y + 0.0415 * z)
    let b = srgb-encode(0.0557 * x - 0.2040 * y + 1.0570 * z)
    rgb(
      int(calc.round(r * 255)),
      int(calc.round(g * 255)),
      int(calc.round(b * 255)),
    )
  }
}

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
  [#text(size: 6.5pt, fill: soft)[#s.label]],
)

#let series-legend(series, direction: "horizontal", columns: (auto, auto, auto, auto)) = {
  let items = ()
  for s in series {
    items.push(legend-item(s))
  }
  if direction == "vertical" {
    grid(columns: (auto,), row-gutter: 3pt, ..items)
  } else {
    grid(columns: columns, column-gutter: 8pt, row-gutter: 3pt, ..items)
  }
}

#let spectrum-plot(
  wavelengths,
  title: [],
  series: (),
  height: 3.2cm,
  legend-position: "none",
  xlabel: text(size: 5.5pt)[Wavelength / nm],
  ylabel: text(size: 5.5pt)[Relative power],
  ylim: (0, 1.08),
) = {
  let plots = ()
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
    xlim: (wavelengths.first(), wavelengths.last()),
    ylim: ylim,
    legend: none,
    ..plots,
  )

  if legend-position == "bottom" {
    block(width: 100%)[
      #diagram
      #v(4pt)
      #align(center)[#series-legend(series)]
    ]
  } else if legend-position == "right" {
    grid(
      columns: (1fr, auto),
      column-gutter: 8pt,
      align: top,
      diagram,
      box(inset: (top: 16pt))[#series-legend(series, direction: "vertical")],
    )
  } else {
    diagram
  }
}

// -----------------------------------------------------------------------------
// Time-series plotting helpers
// -----------------------------------------------------------------------------

#let times = lq.linspace(0, 24, num: 193)

#let time-legend-item(s) = grid(
  columns: (14pt, auto),
  column-gutter: 4pt,
  align: horizon,
  [#line(length: 14pt, stroke: s.stroke)],
  [#text(size: 6.5pt, fill: soft)[#s.label]],
)

#let time-legend(series) = {
  let items = ()
  for s in series {
    items.push(time-legend-item(s))
  }
  grid(columns: (auto, auto, auto, auto), column-gutter: 8pt, row-gutter: 3pt, ..items)
}

#let time-legend(series, columns: (auto, auto, auto, auto)) = {
  let items = ()
  for s in series {
    items.push(time-legend-item(s))
  }

  grid(
    columns: columns,
    column-gutter: 8pt,
    row-gutter: 3pt,
    ..items,
  )
}

#let time-plot(
  title: [],
  series: (),
  height: 5.5cm,
  xlabel: text(size: 5.5pt)[Hour of day],
  ylabel: text(size: 5.5pt)[Relative level],
  legend: true,
  ylim: (0, 1.05),
  legend-columns: (auto, auto, auto, auto),
) = {
  let plots = ()
  for s in series {
    plots.push(
      lq.plot(
        times,
        s.values,
        label: none,
        mark: none,
        smooth: true,
        stroke: s.stroke,
      )
    )
  }

  let diagram = lq.diagram(
    width: 100%,
    height: height,
    title: title,
    xlabel: xlabel,
    ylabel: ylabel,
    xlim: (0, 24),
    ylim: ylim,
    legend: none,
    ..plots,
  )

  if legend {
    block(width: 100%)[
      #diagram
      #v(4pt)
      #align(center)[#time-legend(series, columns: legend-columns)]
    ]
  } else {
    diagram
  }
}

// -----------------------------------------------------------------------------
// Data: spectral archetypes and schedule curves
// -----------------------------------------------------------------------------

#let wl = lq.linspace(380, 780, num: 401)
#let gauss(x, center, width, amp: 1.0) = amp * calc.exp(-0.5 * calc.pow((x - center) / width, 2))
#let normalize(values) = {
  let max-val = calc.max(..values)
  if max-val == 0 {
    values
  } else {
    values.map(v => v / max-val)
  }
}
#let make-series(f) = normalize(wl.map(f))
#let sub-dip(x, center, width, depth: 0.1) = 1.0 - depth * gauss(x, center, width)
#let blackbody(x, temp) = {
  let c2 = 14387768.0
  let xr = x / 560.0
  let e = calc.exp(c2 / (x * temp))
  1.0 / (calc.pow(xr, 5.0) * (e - 1.0))
}

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

#let spd-morning(x) = gauss(x, 455, 36, amp: 0.72) + gauss(x, 505, 58, amp: 0.72) + gauss(x, 570, 82, amp: 0.84) + gauss(x, 650, 88, amp: 0.42)
#let spd-day(x) = gauss(x, 455, 38, amp: 0.86) + gauss(x, 505, 62, amp: 0.80) + gauss(x, 570, 82, amp: 0.88) + gauss(x, 650, 92, amp: 0.46)
#let spd-evening(x) = gauss(x, 455, 30, amp: 0.10) + gauss(x, 520, 70, amp: 0.28) + gauss(x, 595, 88, amp: 0.86) + gauss(x, 660, 78, amp: 0.64)
#let spd-night(x) = gauss(x, 455, 26, amp: 0.012) + gauss(x, 525, 55, amp: 0.040) + gauss(x, 610, 48, amp: 0.42) + gauss(x, 660, 38, amp: 0.82)
#let spd-static-neutral(x) = gauss(x, 450, 15, amp: 0.54) + gauss(x, 505, 46, amp: 0.34) + gauss(x, 575, 78, amp: 0.82) + gauss(x, 638, 70, amp: 0.34)
#let spd-static-warm(x) = gauss(x, 452, 18, amp: 0.18) + gauss(x, 525, 55, amp: 0.28) + gauss(x, 600, 86, amp: 0.92) + gauss(x, 665, 64, amp: 0.58)
#let spd-melanopic-weight(x) = gauss(x, 490, 36, amp: 1.0) * sub-dip(x, 610, 90, depth: 0.40)

#let daylight = make-series(spd-daylight-reference)
#let morning = make-series(spd-morning)
#let day = make-series(spd-day)
#let evening = make-series(spd-evening)
#let night = make-series(spd-night)
#let static-neutral = make-series(spd-static-neutral)
#let static-warm = make-series(spd-static-warm)
#let melanopic = make-series(spd-melanopic-weight)

#let visual-need(t) = {
  // Occupancy-oriented light need: morning ramp, broad workday plateau,
  // soft evening decay, almost zero at night.
  if t < 5.5 {
    0.03
  } else if t < 8.0 {
    segment(t, 5.5, 8.0, 0.03, 0.74)
  } else if t < 16.5 {
    0.86 + 0.06 * gauss(t, 13.0, 2.2)
  } else if t < 21.5 {
    segment(t, 16.5, 21.5, 0.78, 0.22)
  } else {
    0.05
  }
}

#let melanopic-availability(t) = {
  // Blue-cyan channel: intentional morning/day exposure, then a hard cliff.
  if t < 5.5 {
    0.02
  } else if t < 7.5 {
    segment(t, 5.5, 7.5, 0.02, 0.88)
  } else if t < 14.5 {
    0.74 + 0.18 * gauss(t, 10.0, 2.8)
  } else if t < 18.5 {
    segment(t, 14.5, 18.5, 0.70, 0.16)
  } else if t < 21.0 {
    segment(t, 18.5, 21.0, 0.16, 0.035)
  } else {
    0.015
  }
}

#let visual-warmth(t) = {
  // Warmth/visual softness is intentionally not the inverse of brightness.
  // It remains low through daytime, then rises into evening.
  if t < 6.5 {
    0.54
  } else if t < 11.0 {
    segment(t, 6.5, 11.0, 0.54, 0.16)
  } else if t < 16.0 {
    0.14
  } else if t < 20.0 {
    segment(t, 16.0, 20.0, 0.14, 0.78)
  } else {
    0.88
  }
}

#let night-risk(t) = {
  // Sensitivity/risk curve: low by day, high near biological night.
  gauss(t, 23.0, 2.1, amp: 0.92) + gauss(t, 2.0, 2.4, amp: 0.82) + gauss(t, 20.5, 1.4, amp: 0.32)
}

#let phase-response(t) = {
  // Stylized phase response curve: evening light delays, morning light advances.
  // It crosses zero; this is the graph the previous version was missing.
  let advance = gauss(t, 7.0, 1.7, amp: 0.92)
  let delay = gauss(t, 22.6, 2.0, amp: 0.86) + gauss(t, 1.0, 1.5, amp: 0.46)
  advance - delay
}

#let scheduled-clock-effect(t) = visual-need(t) * melanopic-availability(t)
#let static-neutral-effect(t) = visual-need(t) * 0.50
#let static-warm-effect(t) = visual-need(t) * 0.18
#let static-night-spill(t) = night-risk(t) * 0.50
#let scheduled-night-spill(t) = night-risk(t) * melanopic-availability(t)

#let values-visual = times.map(visual-need)
#let values-melanopic = times.map(melanopic-availability)
#let values-warmth = times.map(visual-warmth)
#let values-risk = times.map(night-risk)
#let values-phase = times.map(phase-response)
#let values-clock = times.map(scheduled-clock-effect)
#let values-static-neutral = times.map(static-neutral-effect)
#let values-static-warm = times.map(static-warm-effect)
#let values-static-spill = times.map(static-night-spill)
#let values-scheduled-spill = times.map(scheduled-night-spill)

// -----------------------------------------------------------------------------
// Small graphic components
// -----------------------------------------------------------------------------

#let meter(label-body, width, value-body, accent: blackish) = block(width: 100%)[
  #grid(
    columns: (48pt, 1fr, 34pt),
    column-gutter: 6pt,
    align: horizon,
    [#label(label-body, fill: accent)],
    [
      #box(width: 100%, height: 4pt, fill: rgb("#ececf4"))[
        #box(width: width, height: 4pt, fill: accent)[]
      ]
    ],
    [#text(size: 6.8pt, fill: mute)[#value-body]],
  )
]

#let phase-panel(
  kicker,
  title,
  values,
  stroke,
  accent,
  level-width,
  clock-width,
  level-text,
  clock-text,
) = block(width: 100%)[
  #label(kicker, fill: accent)
  #v(4pt)
  #text(size: 12.8pt, weight: "semibold", fill: ink)[#title]
  #v(4pt)
  #spectrum-plot(
    wl,
    title: [],
    height: 2.8cm,
    legend-position: "none",
    xlabel: text(size: 0pt)[],
    ylabel: text(size: 0pt)[],
    series: ((label: [], values: values, stroke: stroke, draw-area: true),),
  )
  #v(5pt)
  #meter([light], level-width, level-text, accent: accent)
  #v(2pt)
  #meter([clock], clock-width, clock-text, accent: accent)
]

#let caption-line(left, right) = grid(
  columns: (1fr, auto),
  column-gutter: 10pt,
  align: horizon,
  [#note(left, size: 8.1pt)],
  [#text(size: 7pt, fill: mute)[#right]],
)

// -----------------------------------------------------------------------------
// PAGE 1 — time changes the meaning of light
// -----------------------------------------------------------------------------

#grid(
  columns: (0.50fr, 1fr),
  column-gutter: 18pt,
  align: top,
  [
    #label[core claim]
    #v(6pt)
    #headline[Light is a clock signal.]
    #v(8pt)
    #lede[
      The same spectrum can support wakefulness by day and disturb rest at night.
    ]
    #v(12pt)
    #note[
      The missing dimension is not another label on the lamp. It is clock time. Morning light and evening light do not merely differ in preference; they can push the biological clock in opposite directions.
    ]
  ],
  [
    #time-plot(
      title: [Stylized phase response to light],
      height: 6.0cm,
      ylabel: text(size: 5.5pt)[Phase direction],
      ylim: (-1.0, 1.0),
      legend-columns: (auto, auto),
      series: (
        (label: [advance / delay curve], values: values-phase, stroke: 1.5pt + blue),
        (label: [zero line], values: times.map(t => 0), stroke: 0.7pt + hair),
      ),
    )
  ],
)

#v(8pt)
#rule()
#v(8pt)

#grid(
  columns: (1fr, 1fr),
  column-gutter: 16pt,
  align: top,
  [
    #time-plot(
      title: [Controls that should not move together],
      height: 4.2cm,
      legend-columns: (auto, auto, auto),
      series: (
        (label: [visual need], values: values-visual, stroke: 1.1pt + amber),
        (label: [blue–cyan channel], values: values-melanopic, stroke: 1.1pt + cyan),
        (label: [visual warmth], values: values-warmth, stroke: 1.1pt + red),
      ),
    )
  ],
  [
    #time-plot(
      title: [Night risk is not a brightness curve],
      height: 4.2cm,
      legend-columns: (auto, auto),
      series: (
        (label: [biological sensitivity], values: values-risk, stroke: 1.2pt + violet),
        (label: [visual need], values: values-visual, stroke: 1.0pt + amber),
      ),
    )
  ],
)

#v(9pt)
#caption-line(
  [This is the real design problem: brightness, spectral content, visual comfort, and circadian sensitivity have different shapes.],
  [time logic]
)

#pagebreak()

// -----------------------------------------------------------------------------
// PAGE 2 — a day is not one spectrum
// -----------------------------------------------------------------------------

#grid(
  columns: (0.50fr, 1fr),
  column-gutter: 18pt,
  align: top,
  [
    #label[spectral schedule]
    #v(6pt)
    #headline[A day is not one spectrum.]
    #v(8pt)
    #lede[
      Circadian lighting is better understood as a sequence of spectral states than as a single “good” white point.
    ]
  ],
  [
    #spectrum-plot(
      wl,
      title: [Reference curves],
      height: 5.0cm,
      legend-position: "bottom",
      series: (
        (label: [daylight ref.], values: daylight, stroke: 0.95pt + green),
        (label: [melanopic weight], values: melanopic, stroke: 1.1pt + violet),
      ),
    )
  ],
)

#v(10pt)

#grid(
  columns: (1fr, 1fr, 1fr, 1fr),
  column-gutter: 12pt,
  align: top,
  [#phase-panel([window 01], [Morning], morning, 1.0pt + cyan, cyan, 60%, 68%, [rising], [high])],
  [#phase-panel([window 02], [Day], day, 1.0pt + blue, blue, 98%, 94%, [high], [strong])],
  [#phase-panel([window 03], [Evening], evening, 1.0pt + amber, amber, 22%, 18%, [reduced], [low])],
  [#phase-panel([window 04], [Night], night, 1.0pt + red, red, 5%, 3%, [minimal], [protected])],
)

#v(10pt)
#caption-line(
  [The point is not that these exact curves are sacred. The point is that the lighting strategy changes job as the day changes phase.],
  [small multiples]
)

#pagebreak()

// -----------------------------------------------------------------------------
// PAGE 3 — static lighting creates two different failures
// -----------------------------------------------------------------------------

#grid(
  columns: (0.52fr, 1fr),
  column-gutter: 18pt,
  align: top,
  [
    #label[comparison]
    #v(6pt)
    #headline[Static lighting fails in two directions.]
    #v(8pt)
    #lede[
      Neutral static light leaks too much signal into the night. Warm static light gives away too much daytime signal.
    ]
    #v(10pt)
    #note[
      This is why the argument should not be “warm versus cool.” The better axis is scheduled versus static.
    ]
  ],
  [
    #time-plot(
      title: [Useful clock signal across the occupied day],
      height: 4.3cm,
      legend-columns: (auto, auto, auto),
      series: (
        (label: [scheduled], values: values-clock, stroke: 1.5pt + blue),
        (label: [static neutral], values: values-static-neutral, stroke: 1.1pt + blackish),
        (label: [static warm], values: values-static-warm, stroke: 1.1pt + amber),
      ),
    )
    #v(8pt)
    #time-plot(
      title: [Night disruption risk],
      height: 3.5cm,
      legend-columns: (auto, auto),
      series: (
        (label: [static neutral spill], values: values-static-spill, stroke: 1.3pt + red),
        (label: [scheduled spill], values: values-scheduled-spill, stroke: 1.3pt + blue),
      ),
    )
  ],
)

#v(10pt)
#rule()
#v(10pt)

#grid(
  columns: (1fr, 1fr, 1fr),
  column-gutter: 14pt,
  align: top,
  [
    #label[target state, fill: blue]
    #v(4pt)
    #text(size: 12.5pt, weight: "semibold", fill: ink)[Scheduled day / evening]
    #v(5pt)
    #spectrum-plot(
      wl,
      title: [],
      height: 4.1cm,
      legend-position: "bottom",
      series: (
        (label: [day], values: day, stroke: 1.0pt + blue, draw-area: true),
        (label: [evening], values: evening, stroke: 1.0pt + amber),
      ),
    )
  ],
  [
    #label[static neutral, fill: blackish]
    #v(4pt)
    #text(size: 12.5pt, weight: "semibold", fill: ink)[One fixed neutral state]
    #v(5pt)
    #spectrum-plot(
      wl,
      title: [],
      height: 4.1cm,
      legend-position: "none",
      series: (
        (label: [neutral], values: static-neutral, stroke: 1.0pt + blackish, draw-area: true),
      ),
    )
    #v(4pt)
    #note(size: 7.9pt)[Acceptable by day; biologically loud after dark.]
  ],
  [
    #label[static warm, fill: amber]
    #v(4pt)
    #text(size: 12.5pt, weight: "semibold", fill: ink)[One fixed warm state]
    #v(5pt)
    #spectrum-plot(
      wl,
      title: [],
      height: 4.1cm,
      legend-position: "none",
      series: (
        (label: [warm], values: static-warm, stroke: 1.0pt + amber, draw-area: true),
      ),
    )
    #v(4pt)
    #note(size: 7.9pt)[Pleasant late; weak as a daytime anchor.]
  ],
)

#v(10pt)
#caption-line(
  [A scheduled system separates the jobs. It does not ask one fixed spectrum to be day-safe, night-safe, comfortable, and biologically useful at once.],
  [static failure]
)
