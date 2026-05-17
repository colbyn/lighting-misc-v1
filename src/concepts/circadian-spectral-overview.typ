#import "@preview/lilaq:0.6.0" as lq

/*
Circadian spectral paper — focused edition.

Built from the selected sampler exhibits only:
- OPTION 01 — Reference curves
- OPTION 02 — Source SPDs
- OPTION 07 — Three spectral states
- OPTION 08 — Melanopic overlap

Editorial intent:
This is no longer a gallery of possible diagrams. It is a single argument:
1. The eye has more than one spectral meaning curve.
2. Common white-looking sources are not spectrally equivalent.
3. A good lighting system changes spectral state across the day.
4. Melanopic overlap must be compared against real consumer source classes,
   not just explained abstractly.
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
// Editorial tokens
// -----------------------------------------------------------------------------

#let ink = rgb("#23242a")
#let soft = rgb("#50525d")
#let mute = rgb("#777985")
#let hair = rgb("#ddddE8")
#let faint = rgb("#f6f7fb")
#let white = rgb("#ffffff")

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
#let note(body, size: 8.2pt, fill: soft) = block(width: 100%)[
  #set par(leading: 0.66em)
  #text(size: size, fill: fill)[#body]
]
#let rule(stroke: hair + 0.6pt) = line(length: 100%, stroke: stroke)

// -----------------------------------------------------------------------------
// Generic helpers
// -----------------------------------------------------------------------------

#let clamp(x, lo: 0.0, hi: 1.0) = calc.min(hi, calc.max(lo, x))
#let mix(a, b, t) = a + (b - a) * t
#let gauss(x, center, width, amp: 1.0) = amp * calc.exp(-0.5 * calc.pow((x - center) / width, 2))
#let asymmetric-gaussian(x, center, left-scale, right-scale, amp: 1.0) = {
  let t = if x < center {
    (x - center) * left-scale
  } else {
    (x - center) * right-scale
  }
  amp * calc.exp(-0.5 * t * t)
}
#let normalize(values) = {
  let max-val = calc.max(..values)
  if max-val == 0 {
    values
  } else {
    values.map(v => v / max-val)
  }
}
#let integrate(values) = {
  let total = 0.0
  for v in values {
    total += v
  }
  total
}
#let integrate-product(a, b) = {
  let total = 0.0
  for i in range(a.len()) {
    total += a.at(i) * b.at(i)
  }
  total
}
#let visual-normalize(values, visual-weight) = {
  let visual = integrate-product(values, visual-weight)
  if visual == 0 {
    values
  } else {
    values.map(v => v / visual)
  }
}
#let metric-bar(value, max-value, fill: violet) = {
  let pct = if max-value == 0 { 0% } else { clamp(value / max-value) * 100% }
  box(width: 100%, height: 4pt, fill: rgb("#ececf4"))[
    #box(width: pct, height: 4pt, fill: fill)[]
  ]
}

// -----------------------------------------------------------------------------
// Wavelength color helpers
// -----------------------------------------------------------------------------

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

// -----------------------------------------------------------------------------
// Plot helpers
// -----------------------------------------------------------------------------

#let wl = lq.linspace(380, 780, num: 401)

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
#let series-legend(series, columns: (auto, auto, auto, auto)) = {
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
  height: 3.2cm,
  legend-position: "none",
  legend-columns: (auto, auto, auto, auto),
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
    if s.at("halo", default: false) {
      plots.push(lq.plot(wavelengths, s.values, label: none, mark: none, smooth: true, stroke: 3.4pt + white, z-index: 3))
    }
    plots.push(lq.plot(wavelengths, s.values, label: none, mark: none, smooth: true, stroke: s.stroke, z-index: s.at("z", default: 4)))
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
      #align(center)[#series-legend(series, columns: legend-columns)]
    ]
  } else {
    diagram
  }
}

// -----------------------------------------------------------------------------
// Reference curves and source spectra
// -----------------------------------------------------------------------------

#let sub-dip(x, center, width, depth: 0.1) = 1.0 - depth * gauss(x, center, width)
#let blackbody(x, temp) = {
  let c2 = 14387768.0
  let xr = x / 560.0
  let e = calc.exp(c2 / (x * temp))
  1.0 / (calc.pow(xr, 5.0) * (e - 1.0))
}
#let daylight-reference(x) = {
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
#let melanopic-weight(x) = gauss(x, 490, 36, amp: 1.0) * sub-dip(x, 610, 90, depth: 0.40)
#let photopic-weight(x) = cie-y(x)

#let spd-incandescent(x) = blackbody(x, 2700)
#let spd-cheap-blue-led(x) = gauss(x, 451, 12, amp: 1.16) + gauss(x, 545, 60, amp: 0.58) + gauss(x, 610, 86, amp: 0.50)
#let spd-neutral-led(x) = gauss(x, 452, 15, amp: 0.62) + gauss(x, 505, 48, amp: 0.36) + gauss(x, 575, 78, amp: 0.84) + gauss(x, 640, 70, amp: 0.34)
#let spd-warm-led(x) = gauss(x, 452, 18, amp: 0.20) + gauss(x, 525, 55, amp: 0.30) + gauss(x, 600, 86, amp: 0.94) + gauss(x, 665, 64, amp: 0.58)
#let spd-violet-pump-led(x) = gauss(x, 415, 12, amp: 0.46) + gauss(x, 470, 38, amp: 0.46) + gauss(x, 535, 62, amp: 0.76) + gauss(x, 610, 78, amp: 0.76) + gauss(x, 670, 66, amp: 0.40)

#let spd-day-state(x) = gauss(x, 455, 38, amp: 0.86) + gauss(x, 505, 62, amp: 0.80) + gauss(x, 570, 82, amp: 0.88) + gauss(x, 650, 92, amp: 0.46)
#let spd-evening-state(x) = gauss(x, 455, 30, amp: 0.10) + gauss(x, 520, 70, amp: 0.28) + gauss(x, 595, 88, amp: 0.86) + gauss(x, 660, 78, amp: 0.64)
#let spd-night-state(x) = gauss(x, 455, 26, amp: 0.012) + gauss(x, 525, 55, amp: 0.040) + gauss(x, 610, 48, amp: 0.42) + gauss(x, 660, 38, amp: 0.82)

#let make-series(f) = normalize(wl.map(f))
#let daylight = make-series(daylight-reference)
#let melanopic = make-series(melanopic-weight)
#let photopic = make-series(photopic-weight)
#let incandescent = make-series(spd-incandescent)
#let cheap-blue-led = make-series(spd-cheap-blue-led)
#let neutral-led = make-series(spd-neutral-led)
#let warm-led = make-series(spd-warm-led)
#let violet-pump-led = make-series(spd-violet-pump-led)
#let day-state = make-series(spd-day-state)
#let evening-state = make-series(spd-evening-state)
#let night-state = make-series(spd-night-state)

#let source-defs = (
  (name: [Incandescent 2700 K], values: incandescent, stroke: 1.0pt + amber, accent: amber, note: [continuous, warm-heavy]),
  (name: [Cheap blue-pump LED], values: cheap-blue-led, stroke: 1.0pt + blue, accent: blue, note: [narrow blue spike + phosphor]),
  (name: [Neutral phosphor LED], values: neutral-led, stroke: 1.0pt + blackish, accent: blackish, note: [common fixed white]),
  (name: [Warm phosphor LED], values: warm-led, stroke: 1.0pt + red, accent: red, note: [blue reduced, not erased]),
  (name: [Violet-pump / full-spectrum LED], values: violet-pump-led, stroke: 1.0pt + violet, accent: violet, note: [broader engineered white]),
)
#let overlap-values = source-defs.map(s => integrate-product(visual-normalize(s.values, photopic), melanopic))
#let overlap-max = calc.max(..overlap-values)

// -----------------------------------------------------------------------------
// Components
// -----------------------------------------------------------------------------

#let caption-line(left, right) = grid(
  columns: (1fr, auto),
  column-gutter: 10pt,
  align: horizon,
  [#note(left, size: 8.1pt)],
  [#text(size: 7pt, fill: mute)[#right]],
)

#let source-card(src, height: 3.05cm) = block(width: 100%)[
  #label(src.name, fill: src.accent)
  #v(4pt)
  #spectrum-plot(
    wl,
    title: [],
    height: height,
    legend-position: "none",
    xlabel: text(size: 0pt)[],
    ylabel: text(size: 0pt)[],
    series: ((label: [], values: src.values, stroke: src.stroke, draw-area: true),),
  )
  #v(4pt)
  #note(src.note, size: 7.6pt)
]

#let state-card(kicker, title, values, stroke, accent, visual-body, clock-body) = block(width: 100%)[
  #label(kicker, fill: accent)
  #v(4pt)
  #text(size: 13pt, weight: "semibold", fill: ink)[#title]
  #v(5pt)
  #spectrum-plot(
    wl,
    title: [],
    height: 3.7cm,
    legend-position: "none",
    xlabel: text(size: 0pt)[],
    ylabel: text(size: 0pt)[],
    series: ((label: [], values: values, stroke: stroke, draw-area: true),),
  )
  #v(6pt)
  #grid(
    columns: (48pt, 1fr),
    column-gutter: 7pt,
    align: top,
    [#label[visual]],
    [#note(visual-body, size: 7.9pt)],
    [#label[clock]],
    [#note(clock-body, size: 7.9pt)],
  )
]

#let overlap-card(src, value) = block(width: 100%, inset: 0pt)[
  #grid(
    columns: (1fr, 82pt),
    column-gutter: 8pt,
    align: top,
    [
      #label(src.name, fill: src.accent)
      #v(4pt)
      #spectrum-plot(
        wl,
        title: [],
        height: 2.75cm,
        legend-position: "none",
        xlabel: text(size: 0pt)[],
        ylabel: text(size: 0pt)[],
        series: (
          (label: [], values: src.values, stroke: src.stroke, draw-area: true, z: 2),
          (label: [], values: melanopic, stroke: 1.55pt + violet, halo: true, z: 5),
        ),
      )
    ],
    [
      #label[melanopic overlap, fill: violet]
      #v(8pt)
      #metric-bar(value, overlap-max, fill: violet)
      #v(5pt)
      #{
        let pct-label = str(int(calc.round(100 * value / overlap-max))) + "%"
        text(size: 13pt, weight: "semibold", fill: ink)[#pct-label]
      }
      #v(4pt)
      #note([relative to the highest source here, normalized to equal visual output], size: 6.9pt)
    ],
  )
]

// -----------------------------------------------------------------------------
// PAGE 1 — Reference curves
// -----------------------------------------------------------------------------

#grid(
  columns: (0.46fr, 1fr),
  column-gutter: 18pt,
  align: top,
  [
    #label[option 01 / reference curves]
    #v(6pt)
    #headline[Spectrum is read by more than one system.]
    #v(8pt)
    #lede[
      A lamp can look visually adequate while landing very differently on the biological sensitivity curve.
    ]
    #v(12pt)
    #note[
      Photopic vision and melanopic response do not weight wavelengths the same way. The design problem starts here: “white” is a visual appearance, not a circadian specification.
    ]
  ],
  [
    #spectrum-plot(
      wl,
      title: [Reference curves: daylight, visual weighting, melanopic weighting],
      height: 6.35cm,
      legend-position: "bottom",
      legend-columns: (auto, auto, auto),
      series: (
        (label: [idealized daylight], values: daylight, stroke: 1.0pt + green),
        (label: [photopic visual weight], values: photopic, stroke: 1.15pt + blackish),
        (label: [melanopic weight], values: melanopic, stroke: 1.8pt + violet, halo: true),
      ),
    )
  ],
)

#v(10pt)
#rule()
#v(9pt)

#grid(
  columns: (1fr, 1fr, 1fr),
  column-gutter: 14pt,
  align: top,
  [
    #label[visual layer]
    #v(4pt)
    #text(size: 12.5pt, weight: "semibold", fill: ink)[Photopic weighting]
    #v(4pt)
    #note[This is the conventional visual brightness layer. It explains much of what looks bright to the eye.]
  ],
  [
    #label[clock layer, fill: violet]
    #v(4pt)
    #text(size: 12.5pt, weight: "semibold", fill: ink)[Melanopic weighting]
    #v(4pt)
    #note[This curve is centered in the blue–cyan region. It is easy to hide in prose and essential in design.]
  ],
  [
    #label[design consequence, fill: blue]
    #v(4pt)
    #text(size: 12.5pt, weight: "semibold", fill: ink)[Equal white is not equal signal]
    #v(4pt)
    #note[Two sources can share CCT, CRI, or visual brightness and still produce different circadian signal.]
  ],
)

#pagebreak()

// -----------------------------------------------------------------------------
// PAGE 2 — Source SPDs
// -----------------------------------------------------------------------------

#grid(
  columns: (0.42fr, 1fr),
  column-gutter: 18pt,
  align: top,
  [
    #label[option 02 / source spds]
    #v(6pt)
    #headline[White light has different engines.]
    #v(8pt)
    #lede[
      The source matters. Consumer lamps that all look “white” can have radically different spectral construction.
    ]
  ],
  [
    #spectrum-plot(
      wl,
      title: [Common source classes, normalized by peak spectral power],
      height: 5.5cm,
      legend-position: "bottom",
      legend-columns: (auto, auto, auto),
      series: (
        (label: [incandescent], values: incandescent, stroke: 1.15pt + amber),
        (label: [cheap blue-pump LED], values: cheap-blue-led, stroke: 1.15pt + blue),
        (label: [warm LED], values: warm-led, stroke: 1.15pt + red),
        (label: [neutral LED], values: neutral-led, stroke: 1.15pt + blackish),
        (label: [violet-pump LED], values: violet-pump-led, stroke: 1.15pt + violet),
      ),
    )
  ],
)

#v(10pt)
#grid(
  columns: (1fr, 1fr, 1fr, 1fr, 1fr),
  column-gutter: 9pt,
  align: top,
  ..source-defs.map(src => source-card(src, height: 3.0cm)),
)

#v(9pt)
#caption-line(
  [This page is the comparison anchor. The argument is not “LED bad” or “warm good.” It is: inspect the actual spectral engine before making claims about visual quality or biological signal.],
  [source comparison]
)

#pagebreak()

// -----------------------------------------------------------------------------
// PAGE 3 — Three spectral states
// -----------------------------------------------------------------------------

#grid(
  columns: (0.45fr, 1fr),
  column-gutter: 18pt,
  align: top,
  [
    #label[option 07 / three spectral states]
    #v(6pt)
    #headline[Good lighting is a sequence, not a setting.]
    #v(8pt)
    #lede[
      The idealized system changes spectral job across the day: anchor, soften, protect.
    ]
    #v(12pt)
    #note[
      This is the cleanest way to explain the design target. Do not ask one static spectrum to behave like morning daylight, evening comfort light, and biological night protection.
    ]
  ],
  [
    #grid(
      columns: (1fr, 1fr, 1fr),
      column-gutter: 14pt,
      align: top,
      [#state-card([state 01], [Day anchor], day-state, 1.0pt + blue, blue, [high visual output with broad white appearance], [intentional blue–cyan presence])],
      [#state-card([state 02], [Evening transition], evening-state, 1.0pt + amber, amber, [comfortable, warm, still usable], [reduced clock signal])],
      [#state-card([state 03], [Night protection], night-state, 1.0pt + red, red, [very low task-light role], [melanopic channel minimized])],
    )
  ],
)

#v(12pt)
#rule()
#v(10pt)

#grid(
  columns: (1fr, 1fr, 1fr),
  column-gutter: 14pt,
  align: top,
  [
    #label[anchor, fill: blue]
    #v(4pt)
    #text(size: 12.5pt, weight: "semibold", fill: ink)[Morning / daytime]
    #v(4pt)
    #note[The system is allowed to be biologically loud when the day calls for anchoring and alertness.]
  ],
  [
    #label[soften, fill: amber]
    #v(4pt)
    #text(size: 12.5pt, weight: "semibold", fill: ink)[Late day]
    #v(4pt)
    #note[The system separates visual comfort from biological activation instead of merely dimming the same spectrum.]
  ],
  [
    #label[protect, fill: red]
    #v(4pt)
    #text(size: 12.5pt, weight: "semibold", fill: ink)[Biological night]
    #v(4pt)
    #note[The design target becomes absence of blue–cyan signal, not a prettier warm-white marketing label.]
  ],
)

#pagebreak()

// -----------------------------------------------------------------------------
// PAGE 4 — Melanopic overlap against consumer options
// -----------------------------------------------------------------------------

#grid(
  columns: (0.42fr, 1fr),
  column-gutter: 18pt,
  align: top,
  [
    #label[option 08 / melanopic overlap]
    #v(6pt)
    #headline[The clock sees overlap.]
    #v(8pt)
    #lede[
      Melanopic impact is not a vibe. It is the overlap between the source spectrum and the blue–cyan sensitivity region.
    ]
    #v(12pt)
    #note[
      The violet curve is the same on every card. What changes is how much each consumer source feeds that region when compared at equal visual output.
    ]
  ],
  [
    #overlap-card(source-defs.at(1), overlap-values.at(1))
    #v(6pt)
    #overlap-card(source-defs.at(2), overlap-values.at(2))
  ],
)

#v(8pt)
#grid(
  columns: (1fr, 1fr, 1fr),
  column-gutter: 10pt,
  align: top,
  [#overlap-card(source-defs.at(0), overlap-values.at(0))],
  [#overlap-card(source-defs.at(3), overlap-values.at(3))],
  [#overlap-card(source-defs.at(4), overlap-values.at(4))],
)

#v(9pt)
#caption-line(
  [This is the page that drives the practical point home: the consumer comparison must be made spectrally. “Dimmer,” “warmer,” and “white” do not describe the clock signal by themselves.],
  [melanopic overlap]
)
