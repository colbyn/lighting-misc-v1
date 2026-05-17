#import "@preview/lilaq:0.6.0" as lq

/*
Circadian lighting visual-options sampler.

This is not a final section. It is a menu of graph directions.

Purpose:
- Show options for communicating that visual brightness and biological
  circadian signal are not the same quantity.
- Compare SPD, photopic illuminance, melanopic EDI, M/P ratio, source families,
  dimming behavior, and schedule behavior.
- Use synthetic illustrative data only. Replace with measured SPD data later.

Core claim:
A light can be dimmer to the eye and louder to the clock.
*/

#set page(
  paper: "us-letter",
  flipped: true,
  margin: (x: 0.32in, y: 0.30in),
  fill: white,
)

#set text(font: "Avenir Next", size: 9pt, fill: rgb("#24242a"))
#set par(justify: false, leading: 0.66em)

// -----------------------------------------------------------------------------
// Tokens
// -----------------------------------------------------------------------------

#let ink = rgb("#24242a")
#let soft = rgb("#4f505b")
#let mute = rgb("#767883")
#let hair = rgb("#dedee8")
#let faint = rgb("#f7f7fb")
#let blue = rgb("#005eff")
#let cyan = rgb("#008f9a")
#let violet = rgb("#7a3cff")
#let amber = rgb("#bd6a00")
#let red = rgb("#a83232")
#let green = rgb("#3a9a00")
#let blackish = rgb("#111111")

#let fine-label(body, fill: mute) = text(size: 6.4pt, weight: "bold", tracking: 0.10em, fill: fill)[#upper(body)]
#let headline(body, size: 26pt) = text(size: size, weight: "medium", fill: ink)[#body]
#let lede(body, size: 12.5pt) = block(width: 100%)[
  #set par(leading: 0.74em)
  #text(size: size, fill: soft)[#body]
]
#let copy(body, size: 8.4pt, fill: soft) = block(width: 100%)[
  #set par(leading: 0.66em)
  #text(size: size, fill: fill)[#body]
]
#let rule(stroke: hair + 0.6pt) = line(length: 100%, stroke: stroke)

#let option-head(number, title, body) = block(width: 100%)[
  #fine-label([option #number])
  #v(4pt)
  #headline(title, size: 20pt)
  #v(6pt)
  #copy(body, size: 8.6pt)
]

// -----------------------------------------------------------------------------
// Math helpers
// -----------------------------------------------------------------------------

#let clamp(x, lo: 0.0, hi: 1.0) = calc.min(hi, calc.max(lo, x))
#let gauss(x, center, width, amp: 1.0) = amp * calc.exp(-0.5 * calc.pow((x - center) / width, 2))
#let normalize(values) = {
  let max-val = calc.max(..values)
  if max-val == 0 {
    values
  } else {
    values.map(v => v / max-val)
  }
}

// -----------------------------------------------------------------------------
// Wavelength color helpers
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

// -----------------------------------------------------------------------------
// Plot helpers
// -----------------------------------------------------------------------------

#let hours = lq.linspace(0, 24, num: 145)

#let legend-item(s) = grid(
  columns: (14pt, auto),
  column-gutter: 4pt,
  align: horizon,
  [#line(length: 14pt, stroke: s.stroke)],
  [#text(size: 6.3pt, fill: soft)[#s.label]],
)

#let legend(series, columns: (auto, auto, auto, auto)) = {
  let items = ()
  for s in series {
    items.push(legend-item(s))
  }
  grid(columns: columns, column-gutter: 8pt, row-gutter: 3pt, ..items)
}

#let spectrum-plot(
  wavelengths,
  title: [],
  series: (),
  height: 4.0cm,
  legend-position: "bottom",
  xlabel: text(size: 5.5pt)[Wavelength / nm],
  ylabel: text(size: 5.5pt)[Relative power],
  ylim: (0, 1.08),
  legend-columns: (auto, auto, auto, auto),
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
      #align(center)[#legend(series, columns: legend-columns)]
    ]
  } else {
    diagram
  }
}

#let xy-plot(
  x-values,
  title: [],
  series: (),
  height: 5.0cm,
  xlim: (0, 500),
  ylim: (0, 500),
  xlabel: text(size: 5.5pt)[Photopic illuminance / lux],
  ylabel: text(size: 5.5pt)[Melanopic EDI / lx],
  legend-columns: (auto, auto, auto, auto),
) = {
  let plots = ()
  for s in series {
    plots.push(
      lq.plot(
        x-values,
        s.values,
        label: none,
        mark: none,
        smooth: true,
        stroke: s.stroke,
      )
    )
  }

  block(width: 100%)[
    #lq.diagram(
      width: 100%,
      height: height,
      title: title,
      xlabel: xlabel,
      ylabel: ylabel,
      xlim: xlim,
      ylim: ylim,
      legend: none,
      ..plots,
    )
    #v(4pt)
    #align(center)[#legend(series, columns: legend-columns)]
  ]
}

#let time-plot(
  title: [],
  series: (),
  height: 4.6cm,
  xlabel: text(size: 5.5pt)[Hour of day],
  ylabel: text(size: 5.5pt)[Relative target],
  ylim: (0, 1.05),
  legend-columns: (auto, auto, auto),
) = {
  let plots = ()
  for s in series {
    plots.push(
      lq.plot(
        hours,
        s.values,
        label: none,
        mark: none,
        smooth: true,
        stroke: s.stroke,
      )
    )
  }

  block(width: 100%)[
    #lq.diagram(
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
    #v(4pt)
    #align(center)[#legend(series, columns: legend-columns)]
  ]
}

// -----------------------------------------------------------------------------
// Synthetic SPD data
// -----------------------------------------------------------------------------

#let wl = lq.linspace(380, 780, num: 401)
#let make-spd(f) = normalize(wl.map(f))
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

#let spd-cheap-blue-led(x) = (
  gauss(x, 450, 14, amp: 0.82) +
  gauss(x, 505, 40, amp: 0.22) +
  gauss(x, 575, 78, amp: 0.82) +
  gauss(x, 638, 72, amp: 0.32)
)

#let spd-violet-pump-led(x) = (
  gauss(x, 415, 18, amp: 0.28) +
  gauss(x, 455, 34, amp: 0.42) +
  gauss(x, 505, 48, amp: 0.58) +
  gauss(x, 570, 74, amp: 0.80) +
  gauss(x, 650, 84, amp: 0.50)
)

#let spd-incandescent(x) = blackbody(x, 2700)

#let spd-day-state(x) = (
  gauss(x, 455, 38, amp: 0.86) +
  gauss(x, 510, 64, amp: 0.82) +
  gauss(x, 575, 84, amp: 0.86) +
  gauss(x, 660, 92, amp: 0.42)
)

#let spd-evening-state(x) = (
  gauss(x, 455, 28, amp: 0.06) +
  gauss(x, 520, 70, amp: 0.22) +
  gauss(x, 596, 84, amp: 0.86) +
  gauss(x, 665, 76, amp: 0.68)
)

#let spd-night-state(x) = (
  gauss(x, 455, 24, amp: 0.006) +
  gauss(x, 525, 52, amp: 0.026) +
  gauss(x, 612, 46, amp: 0.34) +
  gauss(x, 666, 34, amp: 0.90)
)

#let spd-melanopic-weight(x) = gauss(x, 490, 36, amp: 1.0) * sub-dip(x, 610, 90, depth: 0.40)

#let daylight = make-spd(spd-daylight-reference)
#let cheap-led = make-spd(spd-cheap-blue-led)
#let violet-led = make-spd(spd-violet-pump-led)
#let incandescent = make-spd(spd-incandescent)
#let day-state = make-spd(spd-day-state)
#let evening-state = make-spd(spd-evening-state)
#let night-state = make-spd(spd-night-state)
#let melanopic-weight = make-spd(spd-melanopic-weight)

// -----------------------------------------------------------------------------
// Synthetic metric data
// -----------------------------------------------------------------------------

#let source-names = ([Incandescent], [Cheap blue-pump LED], [Violet-pump LED], [Daylight ref.])
#let source-colors = (amber, blue, violet, green)
#let mp-ratios = (0.24, 0.92, 0.74, 1.04)
#let equal-lux = 300
#let equal-lux-mel = (72, 276, 222, 312)

#let lux-axis = (0, 100, 200, 300, 400, 500)
#let diagonal-025 = lux-axis.map(x => x * 0.25)
#let diagonal-050 = lux-axis.map(x => x * 0.50)
#let diagonal-100 = lux-axis.map(x => x * 1.00)

#let dim-lux = (50, 125, 250, 375, 500)
#let incandescent-dim = (5, 18, 55, 95, 140)
#let cheap-dim = (46, 115, 230, 345, 460)
#let violet-dim = (37, 92, 185, 277, 370)
#let daylight-dim = (52, 130, 260, 390, 520)

#let segment(x, x0, x1, y0, y1) = {
  if x <= x0 {
    y0
  } else if x >= x1 {
    y1
  } else {
    y0 + (y1 - y0) * ((x - x0) / (x1 - x0))
  }
}

#let photopic-target(t) = {
  if t < 6.0 {
    0.02
  } else if t < 8.0 {
    segment(t, 6.0, 8.0, 0.02, 0.72)
  } else if t < 17.0 {
    0.84 + 0.08 * gauss(t, 13.0, 2.5)
  } else if t < 21.5 {
    segment(t, 17.0, 21.5, 0.72, 0.16)
  } else {
    0.04
  }
}

#let melanopic-target(t) = {
  if t < 6.0 {
    0.01
  } else if t < 8.0 {
    segment(t, 6.0, 8.0, 0.01, 0.88)
  } else if t < 15.5 {
    0.78 + 0.14 * gauss(t, 10.5, 2.4)
  } else if t < 19.0 {
    segment(t, 15.5, 19.0, 0.72, 0.10)
  } else {
    0.02
  }
}

#let warmth-target(t) = {
  if t < 7.0 {
    0.52
  } else if t < 11.0 {
    segment(t, 7.0, 11.0, 0.52, 0.16)
  } else if t < 16.0 {
    0.14
  } else if t < 20.0 {
    segment(t, 16.0, 20.0, 0.14, 0.84)
  } else {
    0.90
  }
}

#let sensitivity-band(t) = {
  gauss(t, 23.0, 2.2, amp: 0.86) + gauss(t, 2.0, 2.4, amp: 0.76) + gauss(t, 20.0, 1.8, amp: 0.28)
}

#let values-photopic = hours.map(photopic-target)
#let values-melanopic = hours.map(melanopic-target)
#let values-warmth = hours.map(warmth-target)
#let values-sensitivity = hours.map(sensitivity-band)

// -----------------------------------------------------------------------------
// Bar helpers
// -----------------------------------------------------------------------------

#let bar-row(name, value, max-value, accent, value-label) = grid(
  columns: (112pt, 1fr, 44pt),
  column-gutter: 8pt,
  align: horizon,
  [#text(size: 8pt, fill: ink)[#name]],
  [
    #box(width: 100%, height: 7pt, fill: rgb("#eeeeF5"))[
      #box(width: clamp(value / max-value) * 100%, height: 7pt, fill: accent)[]
    ]
  ],
  [#text(size: 7pt, fill: mute)[#value-label]],
)

#let metric-row(label-body, value-body, width, accent) = grid(
  columns: (78pt, 1fr, 46pt),
  column-gutter: 6pt,
  align: horizon,
  [#fine-label(label-body, fill: accent)],
  [
    #box(width: 100%, height: 4pt, fill: rgb("#eeeeF5"))[
      #box(width: width, height: 4pt, fill: accent)[]
    ]
  ],
  [#text(size: 6.8pt, fill: mute)[#value-body]],
)

#let state-panel(kicker, title, values, stroke, accent, photopic, medi, mp, sensitivity) = block(width: 100%)[
  #fine-label(kicker, fill: accent)
  #v(4pt)
  #text(size: 13pt, weight: "semibold", fill: ink)[#title]
  #v(5pt)
  #spectrum-plot(
    wl,
    title: [],
    height: 3.2cm,
    legend-position: "none",
    xlabel: text(size: 0pt)[],
    ylabel: text(size: 0pt)[],
    series: ((label: [], values: values, stroke: stroke, draw-area: true),),
  )
  #v(6pt)
  #metric-row([photopic], photopic.at(0), photopic.at(1), accent)
  #v(2pt)
  #metric-row([mel EDI], medi.at(0), medi.at(1), accent)
  #v(2pt)
  #metric-row([M/P], mp.at(0), mp.at(1), accent)
  #v(2pt)
  #metric-row([sensitivity], sensitivity.at(0), sensitivity.at(1), accent)
]

// -----------------------------------------------------------------------------
// COVER / MENU
// -----------------------------------------------------------------------------

#grid(
  columns: (0.58fr, 1fr),
  column-gutter: 22pt,
  align: top,
  [
    #fine-label[visual options sampler]
    #v(8pt)
    #headline[A light can be dimmer to the eye and louder to the clock.]
    #v(10pt)
    #lede[
      These pages are candidate visual arguments. The data is illustrative; the goal is to decide which graph forms belong in the final circadian section.
    ]
  ],
  [
    #rule()
    #v(8pt)
    #grid(
      columns: (0.28fr, 1fr),
      column-gutter: 10pt,
      row-gutter: 7pt,
      [#fine-label[01]], [#copy[Reference curves: visible spectrum, daylight, melanopic weighting.]],
      [#fine-label[02]], [#copy[Source SPDs: cheap blue-pump LED, violet-pump LED, incandescent, daylight.]],
      [#fine-label[03]], [#copy[Equal visual brightness: same lux, different melanopic EDI.]],
      [#fine-label[04]], [#copy[Photopic lux versus melanopic EDI: the two-axis version of “brightness.”]],
      [#fine-label[05]], [#copy[Dimming trajectories: dimming does not guarantee biological quiet.]],
      [#fine-label[06]], [#copy[Daily schedule: photopic target, melanopic target, warmth, sensitivity.]],
      [#fine-label[07]], [#copy[Three spectral states: day, evening, night with metric rows.]],
      [#fine-label[08]], [#copy[Melanopic overlap: source SPD beside the biological weighting curve.]],
      [#fine-label[09]], [#copy[Brightness inversion: visually dimmer source, biologically louder signal.]],
      [#fine-label[10]], [#copy[From source to clock: emitted spectrum, room delivery, eye exposure, clock signal.]],
      [#fine-label[11]], [#copy[Spectral leverage bands: which wavelengths buy visibility, warmth, and circadian signal.]],
      [#fine-label[12]], [#copy[Night-risk audit: practical ranking of common evening exposures.]],
      [#fine-label[13]], [#copy[Design levers: dim, warm-shift, shield, redirect, curfew.]],
    )
  ],
)

#pagebreak()

// -----------------------------------------------------------------------------
// OPTION 01
// -----------------------------------------------------------------------------

#grid(
  columns: (0.42fr, 1fr),
  column-gutter: 18pt,
  align: top,
  [
    #option-head(
      [01],
      [Reference curves],
      [Shows where the melanopic-sensitive region sits relative to daylight and the visible spectrum. This is the best opening graph if the reader needs spectral orientation.]
    )
  ],
  [
    #spectrum-plot(
      wl,
      title: [Reference curves],
      height: 6.4cm,
      legend-position: "bottom",
      legend-columns: (auto, auto),
      series: (
        (label: [daylight reference], values: daylight, stroke: 1.0pt + green, draw-area: true),
        (label: [melanopic weighting], values: melanopic-weight, stroke: 1.2pt + violet),
      ),
    )
  ],
)

#v(14pt)
#rule()
#v(10pt)
#grid(
  columns: (1fr, 1fr, 1fr),
  column-gutter: 14pt,
  align: top,
  [
    #fine-label[what it says]
    #v(4pt)
    #copy[The circadian-sensitive channel is not evenly distributed across the spectrum.]
  ],
  [
    #fine-label[why keep it]
    #v(4pt)
    #copy[It makes later melanopic metrics visually intelligible.]
  ],
  [
    #fine-label[weakness]
    #v(4pt)
    #copy[It does not yet show intensity, timing, or source comparison.]
  ],
)

#pagebreak()

// -----------------------------------------------------------------------------
// OPTION 02
// -----------------------------------------------------------------------------

#grid(
  columns: (0.38fr, 1fr),
  column-gutter: 18pt,
  align: top,
  [
    #option-head(
      [02],
      [Source SPDs],
      [Compares source families before reducing them to metrics. This is where cheap blue-pump LED, violet-pump LED, incandescent, and daylight become visibly different.]
    )
  ],
  [
    #spectrum-plot(
      wl,
      title: [Source-family spectra, normalized],
      height: 6.2cm,
      legend-position: "bottom",
      series: (
        (label: [incandescent], values: incandescent, stroke: 1.0pt + amber),
        (label: [cheap blue-pump LED], values: cheap-led, stroke: 1.0pt + blue),
        (label: [violet-pump LED], values: violet-led, stroke: 1.0pt + violet),
        (label: [daylight ref.], values: daylight, stroke: 1.0pt + green),
      ),
    )
  ],
)

#v(10pt)
#grid(
  columns: (1fr, 1fr),
  column-gutter: 14pt,
  align: top,
  [
    #spectrum-plot(
      wl,
      title: [Cheap blue-pump LED versus melanopic weighting],
      height: 3.8cm,
      legend-position: "bottom",
      legend-columns: (auto, auto),
      series: (
        (label: [blue-pump LED], values: cheap-led, stroke: 1.0pt + blue, draw-area: true),
        (label: [melanopic weighting], values: melanopic-weight, stroke: 1.0pt + violet),
      ),
    )
  ],
  [
    #spectrum-plot(
      wl,
      title: [Incandescent versus melanopic weighting],
      height: 3.8cm,
      legend-position: "bottom",
      legend-columns: (auto, auto),
      series: (
        (label: [incandescent], values: incandescent, stroke: 1.0pt + amber, draw-area: true),
        (label: [melanopic weighting], values: melanopic-weight, stroke: 1.0pt + violet),
      ),
    )
  ],
)

#pagebreak()

// -----------------------------------------------------------------------------
// OPTION 03
// -----------------------------------------------------------------------------

#grid(
  columns: (0.38fr, 1fr),
  column-gutter: 18pt,
  align: top,
  [
    #option-head(
      [03],
      [Equal visual brightness],
      [Holds photopic illuminance constant and asks: how much melanopic signal remains? This is the simplest way to show that “300 lux” is not one biological condition.]
    )
  ],
  [
    #fine-label[at equal photopic illuminance]
    #v(6pt)
    #headline([300 lux to the eye], size: 18pt)
    #v(10pt)
    #bar-row([Incandescent], 72, 330, amber, [72])
    #v(8pt)
    #bar-row([Cheap blue-pump LED], 276, 330, blue, [276])
    #v(8pt)
    #bar-row([Violet-pump LED], 222, 330, violet, [222])
    #v(8pt)
    #bar-row([Daylight reference], 312, 330, green, [312])
    #v(10pt)
    #copy[Illustrative melanopic EDI values at the same photopic illuminance. Replace with measured SPD-derived values later.]
  ],
)

#v(16pt)
#rule()
#v(10pt)

#grid(
  columns: (1fr, 1fr, 1fr),
  column-gutter: 14pt,
  align: top,
  [
    #fine-label[what it says]
    #v(4pt)
    #copy[The room can look equally bright while delivering different circadian signal strength.]
  ],
  [
    #fine-label[best use]
    #v(4pt)
    #copy[Good for a simple flyer or executive explanation.]
  ],
  [
    #fine-label[weakness]
    #v(4pt)
    #copy[It hides dimming behavior and does not show the SPD shape.]
  ],
)

#pagebreak()

// -----------------------------------------------------------------------------
// OPTION 04
// -----------------------------------------------------------------------------

#grid(
  columns: (0.34fr, 1fr),
  column-gutter: 18pt,
  align: top,
  [
    #option-head(
      [04],
      [Photopic lux vs melanopic EDI],
      [Uses two axes instead of one word: brightness. Farther right means visually brighter; higher up means biologically louder.]
    )
  ],
  [
    #xy-plot(
      lux-axis,
      title: [Two meanings of intensity],
      height: 6.8cm,
      xlim: (0, 500),
      ylim: (0, 520),
      series: (
        (label: [M/P 0.25 guide], values: diagonal-025, stroke: 0.65pt + hair),
        (label: [M/P 0.50 guide], values: diagonal-050, stroke: 0.65pt + hair),
        (label: [M/P 1.00 guide], values: diagonal-100, stroke: 0.65pt + hair),
        (label: [example source line], values: lux-axis.map(x => x * 0.82), stroke: 1.2pt + blue),
      ),
    )
  ],
)

#v(12pt)
#copy[
This is a conceptual axis diagram. The strongest final version would plot measured source points or measured dimming trajectories. The diagonal guides represent melanopic/photopic ratio bands.
]

#pagebreak()

// -----------------------------------------------------------------------------
// OPTION 05
// -----------------------------------------------------------------------------

#grid(
  columns: (0.36fr, 1fr),
  column-gutter: 18pt,
  align: top,
  [
    #option-head(
      [05],
      [Dimming trajectories],
      [Shows how a source moves as it dims. This is the visual form for the claim: dimmer to the eye does not always mean equally quiet to the clock.]
    )
  ],
  [
    #xy-plot(
      dim-lux,
      title: [Dimming trajectory: visual brightness versus melanopic signal],
      height: 6.6cm,
      xlim: (0, 520),
      ylim: (0, 540),
      series: (
        (label: [incandescent], values: incandescent-dim, stroke: 1.2pt + amber),
        (label: [cheap blue-pump LED], values: cheap-dim, stroke: 1.2pt + blue),
        (label: [violet-pump LED], values: violet-dim, stroke: 1.2pt + violet),
        (label: [daylight reference], values: daylight-dim, stroke: 1.2pt + green),
      ),
    )
  ],
)

#v(12pt)
#grid(
  columns: (1fr, 1fr),
  column-gutter: 14pt,
  align: top,
  [
    #fine-label[what it says]
    #v(4pt)
    #copy[Each line is a dimming path. The x-axis falls as the source gets visually dimmer. The y-axis shows how much melanopic signal remains.]
  ],
  [
    #fine-label[why it matters]
    #v(4pt)
    #copy[Two lights can be at the same lux and still sit at very different melanopic levels.]
  ],
)

#pagebreak()

// -----------------------------------------------------------------------------
// OPTION 06
// -----------------------------------------------------------------------------

#grid(
  columns: (0.34fr, 1fr),
  column-gutter: 18pt,
  align: top,
  [
    #option-head(
      [06],
      [Daily lighting schedule],
      [One time graph is still useful if the labels are concrete: photopic target, melanopic EDI target, visual warmth, and circadian sensitivity.]
    )
  ],
  [
    #time-plot(
      title: [Daily lighting schedule],
      height: 6.4cm,
      legend-columns: (auto, auto, auto, auto),
      series: (
        (label: [photopic target], values: values-photopic, stroke: 1.1pt + amber),
        (label: [melanopic target], values: values-melanopic, stroke: 1.1pt + cyan),
        (label: [visual warmth], values: values-warmth, stroke: 1.1pt + red),
        (label: [circadian sensitivity], values: values-sensitivity, stroke: 1.1pt + violet),
      ),
    )
  ],
)

#v(12pt)
#copy[
This version keeps the time-based idea, but removes abstract labels like “phase direction.” The curves now name design quantities directly.
]

#pagebreak()

// -----------------------------------------------------------------------------
// OPTION 07
// -----------------------------------------------------------------------------

#grid(
  columns: (0.36fr, 1fr),
  column-gutter: 18pt,
  align: top,
  [
    #option-head(
      [07],
      [Three spectral states],
      [This is the likely replacement for the four-window page. Morning and day collapse into one state; the three states are day, evening, and night.]
    )
  ],
  [
    #grid(
      columns: (1fr, 1fr, 1fr),
      column-gutter: 12pt,
      align: top,
      [
        #state-panel(
          [state 01],
          [Day signal],
          day-state,
          1.0pt + blue,
          blue,
          ([high], 92%),
          ([high], 88%),
          ([medium-high], 74%),
          ([low], 18%),
        )
      ],
      [
        #state-panel(
          [state 02],
          [Evening transition],
          evening-state,
          1.0pt + amber,
          amber,
          ([medium-low], 34%),
          ([low], 18%),
          ([low], 20%),
          ([rising], 58%),
        )
      ],
      [
        #state-panel(
          [state 03],
          [Night protection],
          night-state,
          1.0pt + red,
          red,
          ([very low], 8%),
          ([near zero], 3%),
          ([very low], 4%),
          ([high], 88%),
        )
      ],
    )
  ],
)

#v(12pt)
#rule()
#v(10pt)
#grid(
  columns: (1fr, 1fr, 1fr, 1fr),
  column-gutter: 12pt,
  align: top,
  [
    #fine-label[photopic]
    #v(4pt)
    #copy[Visual brightness: lux, lumens, illuminance.]
  ],
  [
    #fine-label[mel EDI]
    #v(4pt)
    #copy[Melanopic equivalent daylight illuminance: biological signal strength at the eye.]
  ],
  [
    #fine-label[M/P]
    #v(4pt)
    #copy[Melanopic per photopic: how biologically loud the light is per unit visual brightness.]
  ],
  [
    #fine-label[sensitivity]
    #v(4pt)
    #copy[Timing context: whether the body is more vulnerable to disruption.]
  ],
)

#pagebreak()


// -----------------------------------------------------------------------------
// Additional brainstorm helpers
// -----------------------------------------------------------------------------

#let idea-card(kicker, title, body, accent: blue) = block(
  width: 100%,
  fill: faint,
  stroke: 0.65pt + hair,
  radius: 3pt,
  inset: 10pt,
)[
  #fine-label(kicker, fill: accent)
  #v(5pt)
  #text(size: 13.5pt, weight: "semibold", fill: ink)[#title]
  #v(6pt)
  #copy(body, size: 8.1pt)
]

#let chip(label, accent: blue, fill: rgb("#f2f4fb")) = box(
  fill: fill,
  stroke: 0.55pt + accent,
  radius: 2pt,
  inset: (x: 5pt, y: 2.4pt),
)[#text(size: 6.6pt, weight: "semibold", fill: accent)[#label]]

#let comparison-tile(kicker, title, lux, medi, accent) = block(
  width: 100%,
  fill: white,
  stroke: 0.7pt + hair,
  radius: 3pt,
  inset: 10pt,
)[
  #fine-label(kicker, fill: accent)
  #v(5pt)
  #text(size: 12.5pt, weight: "semibold", fill: ink)[#title]
  #v(8pt)
  #metric-row([visual lux], lux.at(0), lux.at(1), accent)
  #v(3pt)
  #metric-row([mel EDI], medi.at(0), medi.at(1), accent)
]

#let lever-row(action, photopic, melanopic, timing, note, accent) = grid(
  columns: (100pt, 70pt, 70pt, 70pt, 1fr),
  column-gutter: 7pt,
  align: horizon,
  [#text(size: 8pt, weight: "semibold", fill: ink)[#action]],
  [#chip(photopic, accent: accent)],
  [#chip(melanopic, accent: accent)],
  [#chip(timing, accent: accent)],
  [#copy(note, size: 7.3pt)],
)

#let band-label(title, body, accent) = block(
  width: 100%,
  fill: white,
  stroke: 0.65pt + hair,
  radius: 2pt,
  inset: 8pt,
)[
  #fine-label(title, fill: accent)
  #v(4pt)
  #copy(body, size: 7.6pt)
]

// -----------------------------------------------------------------------------
// OPTION 08
// -----------------------------------------------------------------------------

#grid(
  columns: (0.34fr, 1fr),
  column-gutter: 18pt,
  align: top,
  [
    #option-head(
      [08],
      [Melanopic overlap],
      [A stronger expansion of Source SPDs: put each source beside the melanopic weighting curve and make the overlap the story. The reader sees why some white-looking sources are biologically louder.]
    )
  ],
  [
    #grid(
      columns: (1fr, 1fr),
      column-gutter: 12pt,
      row-gutter: 10pt,
      align: top,
      [
        #spectrum-plot(
          wl,
          title: [Cheap blue-pump LED: strong overlap],
          height: 3.8cm,
          legend-position: "bottom",
          legend-columns: (auto, auto),
          series: (
            (label: [source SPD], values: cheap-led, stroke: 1.0pt + blue, draw-area: true),
            (label: [melanopic weighting], values: melanopic-weight, stroke: 1.35pt + violet),
          ),
        )
      ],
      [
        #spectrum-plot(
          wl,
          title: [Incandescent: weak overlap],
          height: 3.8cm,
          legend-position: "bottom",
          legend-columns: (auto, auto),
          series: (
            (label: [source SPD], values: incandescent, stroke: 1.0pt + amber, draw-area: true),
            (label: [melanopic weighting], values: melanopic-weight, stroke: 1.35pt + violet),
          ),
        )
      ],
      [
        #spectrum-plot(
          wl,
          title: [Violet-pump LED: broader fill],
          height: 3.8cm,
          legend-position: "bottom",
          legend-columns: (auto, auto),
          series: (
            (label: [source SPD], values: violet-led, stroke: 1.0pt + violet, draw-area: true),
            (label: [melanopic weighting], values: melanopic-weight, stroke: 1.35pt + blackish),
          ),
        )
      ],
      [
        #spectrum-plot(
          wl,
          title: [Daylight reference: full daytime signal],
          height: 3.8cm,
          legend-position: "bottom",
          legend-columns: (auto, auto),
          series: (
            (label: [source SPD], values: daylight, stroke: 1.0pt + green, draw-area: true),
            (label: [melanopic weighting], values: melanopic-weight, stroke: 1.35pt + violet),
          ),
        )
      ],
    )
  ],
)

#v(10pt)
#grid(
  columns: (1fr, 1fr, 1fr),
  column-gutter: 12pt,
  align: top,
  [#idea-card([why it works], [The metric becomes visible], [Instead of asking the reader to trust a melanopic number, the page shows where that number comes from.], accent: violet)],
  [#idea-card([source-spd expansion], [Use this after Option 02], [Option 02 introduces source families. This page explains the biological consequence of those shapes.], accent: blue)],
  [#idea-card([editorial note], [Make overlap explicit], [Final version could tint only the overlapping area, not the whole SPD. That would make the argument sharper.], accent: amber)],
)

#pagebreak()

// -----------------------------------------------------------------------------
// OPTION 09
// -----------------------------------------------------------------------------

#grid(
  columns: (0.38fr, 1fr),
  column-gutter: 18pt,
  align: top,
  [
    #option-head(
      [09],
      [The brightness inversion],
      [A replacement direction for Equal visual brightness: show the surprising inversion directly. The visually dimmer source can still be the stronger clock signal.]
    )
  ],
  [
    #grid(
      columns: (1fr, 0.18fr, 1fr),
      column-gutter: 10pt,
      align: horizon,
      [
        #comparison-tile(
          [source a],
          [Warm incandescent task light],
          ([brighter], 82%),
          ([quieter], 28%),
          amber,
        )
      ],
      [#align(center)[#text(size: 24pt, fill: mute)[≠]]],
      [
        #comparison-tile(
          [source b],
          [Dim blue-pump LED],
          ([dimmer], 46%),
          ([louder], 72%),
          blue,
        )
      ],
    )
    #v(14pt)
    #block(width: 100%, fill: faint, stroke: 0.7pt + hair, radius: 3pt, inset: 12pt)[
      #fine-label[caption idea]
      #v(5pt)
      #headline([Lower lux does not guarantee lower circadian signal.], size: 18pt)
      #v(7pt)
      #copy[This page should feel like a paradox card. It is not trying to be a complete graph; it is trying to make the core claim memorable.]
    ]
  ],
)

#v(12pt)
#grid(
  columns: (1fr, 1fr, 1fr),
  column-gutter: 12pt,
  align: top,
  [#idea-card([use case], [Best flyer visual], [This is probably the clearest public-facing version of “dimmer to the eye, louder to the clock.”], accent: blue)],
  [#idea-card([data need], [Use measured pairs], [Final values should come from real SPD integrations at the eye, not fixture marketing specs.], accent: violet)],
  [#idea-card([layout note], [Do not over-graph it], [The power is the inversion. Keep two large tiles, two metric bars, and one strong caption.], accent: amber)],
)

#pagebreak()

// -----------------------------------------------------------------------------
// OPTION 10
// -----------------------------------------------------------------------------

#grid(
  columns: (0.32fr, 1fr),
  column-gutter: 18pt,
  align: top,
  [
    #option-head(
      [10],
      [From source to clock],
      [A systems diagram instead of another chart. It separates what the fixture emits, what the room delivers, what reaches the eye, and what the circadian system receives.]
    )
  ],
  [
    #grid(
      columns: (1fr, 20pt, 1fr, 20pt, 1fr, 20pt, 1fr),
      column-gutter: 4pt,
      align: horizon,
      [#idea-card([01], [Source SPD], [Emitter spectrum, phosphor mix, driver behavior, optical losses.], accent: blue)],
      [#align(center)[#text(size: 17pt, fill: mute)[→]]],
      [#idea-card([02], [Room delivery], [Beam angle, surface reflectance, distance, view direction.], accent: cyan)],
      [#align(center)[#text(size: 17pt, fill: mute)[→]]],
      [#idea-card([03], [At the eye], [Vertical illuminance and spectral composition at the retina.], accent: violet)],
      [#align(center)[#text(size: 17pt, fill: mute)[→]]],
      [#idea-card([04], [Clock signal], [Melanopic EDI interpreted through timing and sensitivity.], accent: red)],
    )
    #v(12pt)
    #block(width: 100%, stroke: 0.7pt + hair, radius: 3pt, inset: 10pt)[
      #fine-label[point]
      #v(5pt)
      #copy[This makes “intensity” less ambiguous. Lumens are not retinal melanopic exposure. Fixture output is not what the eye receives. The same lamp can mean different things depending on placement and time.]
    ]
  ],
)

#pagebreak()

// -----------------------------------------------------------------------------
// OPTION 11
// -----------------------------------------------------------------------------

#grid(
  columns: (0.36fr, 1fr),
  column-gutter: 18pt,
  align: top,
  [
    #option-head(
      [11],
      [Spectral leverage bands],
      [A wavelength-band explainer. Instead of another full SPD, divide the visible spectrum into regions and show which regions mostly buy visibility, warmth, color rendering, or clock signal.]
    )
  ],
  [
    #grid(
      columns: (0.9fr, 1.2fr, 1fr, 1fr),
      column-gutter: 8pt,
      row-gutter: 8pt,
      align: top,
      [#band-label([violet / deep blue], [Often source-pump energy. Can matter optically, but is not the main melanopic peak.], violet)],
      [#band-label([blue-cyan], [High melanopic leverage. Small changes here can strongly affect biological signal.], blue)],
      [#band-label([green-yellow], [Strong visual contribution. Often carries brightness impression efficiently.], green)],
      [#band-label([amber-red], [Warm appearance and low melanopic leverage per photopic lux.], amber)],
    )
    #v(14pt)
    #spectrum-plot(
      wl,
      title: [Where the biological leverage lives],
      height: 4.4cm,
      legend-position: "bottom",
      legend-columns: (auto, auto, auto),
      series: (
        (label: [melanopic weighting], values: melanopic-weight, stroke: 1.4pt + violet),
        (label: [cheap blue-pump LED], values: cheap-led, stroke: 0.9pt + blue),
        (label: [incandescent], values: incandescent, stroke: 0.9pt + amber),
      ),
    )
  ],
)

#v(10pt)
#copy[
This could become an annotated teaching page: not all nanometers are equal. The blue-cyan band is where “dim” sources can remain biologically potent.
]

#pagebreak()

// -----------------------------------------------------------------------------
// OPTION 12
// -----------------------------------------------------------------------------

#grid(
  columns: (0.35fr, 1fr),
  column-gutter: 18pt,
  align: top,
  [
    #option-head(
      [12],
      [Night-risk audit],
      [A practical page rather than a physics page. It ranks common night exposures by timing, direction, spectrum, and duration. This could replace the abstract daily schedule.]
    )
  ],
  [
    #grid(
      columns: (1fr, 1fr, 1fr, 1fr),
      column-gutter: 10pt,
      align: top,
      [#comparison-tile([low risk], [Low amber path light], ([very low], 12%), ([near zero], 5%), amber)],
      [#comparison-tile([medium risk], [Warm table lamp], ([medium], 42%), ([low], 24%), red)],
      [#comparison-tile([high risk], [Cool downlight], ([medium], 46%), ([high], 70%), blue)],
      [#comparison-tile([high risk], [Phone near face], ([low area], 28%), ([high at eye], 76%), violet)],
    )
    #v(12pt)
    #block(width: 100%, fill: faint, stroke: 0.7pt + hair, radius: 3pt, inset: 10pt)[
      #fine-label[why this may work]
      #v(5pt)
      #copy[The schedule graph says “time matters,” but this audit says what to do with that fact. It ties source, direction, distance, and time into a usable night-design vocabulary.]
    ]
  ],
)

#pagebreak()

// -----------------------------------------------------------------------------
// OPTION 13
// -----------------------------------------------------------------------------

#grid(
  columns: (0.34fr, 1fr),
  column-gutter: 18pt,
  align: top,
  [
    #option-head(
      [13],
      [Design levers],
      [A control-panel page for the final section. It separates four interventions that are often collapsed into “make it warmer” or “make it dimmer.”]
    )
  ],
  [
    #grid(
      columns: (100pt, 70pt, 70pt, 70pt, 1fr),
      column-gutter: 7pt,
      align: horizon,
      [#fine-label[action]],
      [#fine-label[photopic]],
      [#fine-label[melanopic]],
      [#fine-label[timing]],
      [#fine-label[design meaning]],
    )
    #v(6pt)
    #rule()
    #v(7pt)
    #lever-row([Dim], [down], [down-ish], [same], [Reduces total light, but the spectrum can still remain melanopically efficient.], blue)
    #v(7pt)
    #lever-row([Warm shift], [similar], [down], [same], [Changes spectral distribution; strongest when blue-cyan energy is actually reduced.], amber)
    #v(7pt)
    #lever-row([Shield / redirect], [task kept], [eye down], [same], [Preserves useful work light while reducing direct retinal exposure.], cyan)
    #v(7pt)
    #lever-row([Curfew], [off], [off], [changed], [The cleanest night intervention: remove the signal during sensitive hours.], red)
    #v(12pt)
    #block(width: 100%, fill: faint, stroke: 0.7pt + hair, radius: 3pt, inset: 10pt)[
      #fine-label[section role]
      #v(5pt)
      #copy[This is a good bridge out of the circadian explanation and into lighting-design recommendations. It turns the science into a design grammar.]
    ]
  ],
)

#pagebreak()

// -----------------------------------------------------------------------------
// SELECTION PAGE
// -----------------------------------------------------------------------------

#grid(
  columns: (0.44fr, 1fr),
  column-gutter: 18pt,
  align: top,
  [
    #fine-label[selection notes]
    #v(6pt)
    #headline[Possible final structure]
    #v(8pt)
    #lede[
      The final section probably should not include all of this. The point is to select the few visuals that make the argument without extra explanation.
    ]
  ],
  [
    #grid(
      columns: (0.30fr, 1fr),
      column-gutter: 10pt,
      row-gutter: 7pt,
      [#fine-label[keep]], [#copy[Reference curves — if the reader needs spectral orientation.]],
      [#fine-label[strong]], [#copy[Equal visual brightness — simplest way to show that lux is not melanopic signal.]],
      [#fine-label[strong]], [#copy[Dimming trajectories — best way to show “dimmer to the eye, louder to the clock.”]],
      [#fine-label[maybe]], [#copy[Daily lighting schedule — useful only if labels stay concrete and metric-based.]],
      [#fine-label[keep]], [#copy[Three spectral states — likely the main final page.]],
      [#fine-label[add]], [#copy[Melanopic overlap — best expansion of Source SPDs because it shows where the metric comes from.]],
      [#fine-label[add]], [#copy[Brightness inversion — strongest compact statement of the thesis.]],
      [#fine-label[maybe]], [#copy[From source to clock — useful if the section needs a systems boundary before recommendations.]],
      [#fine-label[maybe]], [#copy[Night-risk audit — better practical replacement for the abstract daily schedule.]],
      [#fine-label[bridge]], [#copy[Design levers — good exit page from science into design guidance.]],
      [#fine-label[cut]], [#copy[Static neutral / static warm block — only bring it back if the section needs a “bad implementations” comparison.]],
    )
  ],
)

