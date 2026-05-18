#import "@preview/lilaq:0.6.0" as lq

/*
Circadian lighting — spectral overview, v4.

Argument:
  1. Spectrum is read by more than one system. The non-visual reader is ipRGC-mediated
     melanopsin response — the biology is named and explained, not assumed.
  2. Common white sources feed those readers differently. The comparison is normalized
     by visual output and reported as an approximate melanopic weighted integral,
     not as a relative percent scale.
  3. A good lighting system changes spectral job across the day.
  4. Specifying the lamp is not enough. Specify the signal and the sequence.

Section flow:
  - Two reading systems: visual / ipRGC.
  - White light has different engines: source comparison, allowed to flow across pages.
  - Three spectral states: day anchor / evening transition / night protection.
  - Specification habit: what to ask for in product and project documents.
*/

#set page(
  paper: "us-letter",
  flipped: true,
  margin: (x: 0.2in, y: 0.2in),
)

#set text(font: "Avenir Next", size: 8.45pt, fill: rgb("#23242a"))
#set par(justify: false, leading: 0.62em, spacing: 7pt)

// =============================================================================
// Tokens
// =============================================================================

#let ink     = rgb("#23242a")
#let soft    = rgb("#50525d")
#let mute    = rgb("#777985")
#let hair    = rgb("#ddddE8")
#let faint   = rgb("#f6f7fb")
#let white   = rgb("#ffffff")

#let blue    = rgb("#005eff")
#let cyan    = rgb("#0097a7")
#let green   = rgb("#3a9a00")
#let violet  = rgb("#7a3cff")
#let amber   = rgb("#bd6a00")
#let red     = rgb("#b03a3a")
#let blackish = rgb("#111111")

// Reference curve accent colors — kept distinct from the source palette
#let ref-day    = rgb("#75a85f")
#let ref-visual = rgb("#70727c")
#let ref-clock  = rgb("#8d62d5")

// =============================================================================
// Typography helpers
// =============================================================================

#let label(body, fill: mute) = text(
  size: 6.5pt, weight: "bold", tracking: 0.10em, fill: fill,
)[#upper(body)]

#let headline(body, size: 29pt) = text(
  size: size, weight: "medium", fill: ink,
)[#body]

#let lede(body, size: 13pt) = block(width: 100%)[
  #set par(leading: 0.74em)
  #text(size: size, fill: soft)[#body]
]

#let note(body, size: 8.2pt, fill: soft) = block(width: 100%)[
  #set par(leading: 0.68em)
  #text(size: size, fill: fill)[#body]
]

#let rule(stroke: hair + 0.6pt) = line(length: 100%, stroke: stroke)

// =============================================================================
// Math helpers
// =============================================================================

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
  if max-val == 0 { values } else { values.map(v => v / max-val) }
}

#let integrate-product(a, b) = {
  let total = 0.0
  for i in range(a.len()) { total += a.at(i) * b.at(i) }
  total
}

#let visual-normalize(values, visual-weight) = {
  let visual = integrate-product(values, visual-weight)
  if visual == 0 { values } else { values.map(v => v / visual) }
}

#let metric-bar(value, max-value, fill: violet) = {
  let pct = if max-value == 0 { 0% } else { clamp(value / max-value) * 100% }
  box(width: 100%, height: 4pt, fill: rgb("#ececf4"))[
    #box(width: pct, height: 4pt, fill: fill)[]
  ]
}

// =============================================================================
// Wavelength → sRGB helpers
// =============================================================================

#let cie-x(l) = (
  asymmetric-gaussian(l, 442.0, 0.0624, 0.0374, amp: 0.362) +
  asymmetric-gaussian(l, 599.8, 0.0264, 0.0323, amp: 1.056) -
  asymmetric-gaussian(l, 501.1, 0.0490, 0.0382, amp: 0.065)
)
#let cie-y(l) = (
  asymmetric-gaussian(l, 568.8, 0.0213, 0.0247, amp: 0.821) +
  asymmetric-gaussian(l, 530.9, 0.0613, 0.0322, amp: 0.286)
)
#let cie-z(l) = (
  asymmetric-gaussian(l, 437.0, 0.0845, 0.0278, amp: 1.217) +
  asymmetric-gaussian(l, 459.0, 0.0385, 0.0725, amp: 0.681)
)
#let srgb-encode(u) = {
  let u = clamp(u)
  if u <= 0.0031308 { 12.92 * u } else { 1.055 * calc.pow(u, 1.0 / 2.4) - 0.055 }
}
#let wavelength-rgb(l) = {
  if l < 380 or l > 780 {
    rgb(0, 0, 0)
  } else {
    let x = cie-x(l); let y = cie-y(l); let z = cie-z(l)
    let r = srgb-encode( 3.2406 * x - 1.5372 * y - 0.4986 * z)
    let g = srgb-encode(-0.9689 * x + 1.8758 * y + 0.0415 * z)
    let b = srgb-encode( 0.0557 * x - 0.2040 * y + 1.0570 * z)
    rgb(int(calc.round(r * 255)), int(calc.round(g * 255)), int(calc.round(b * 255)))
  }
}

// =============================================================================
// Plot helpers
// =============================================================================

#let wl = lq.linspace(380, 780, num: 401)

#let spectral-area-strips(wavelengths, values, z-index: 1) = {
  let strips = ()
  for i in range(values.len() - 1) {
    let x1 = wavelengths.at(i); let x2 = wavelengths.at(i + 1)
    let y1 = values.at(i);     let y2 = values.at(i + 1)
    strips.push(lq.fill-between(
      (x1, x2), (y1, y2),
      fill: wavelength-rgb((x1 + x2) / 2), stroke: none, smooth: false, z-index: z-index,
    ))
  }
  strips
}

#let legend-item(s) = grid(
  columns: (14pt, auto), column-gutter: 4pt, align: horizon,
  [#line(length: 14pt, stroke: s.stroke)],
  [#text(size: 6.5pt, fill: soft)[#s.label]],
)

#let series-legend(series, columns: (auto, auto, auto, auto)) = {
  let items = series.map(s => legend-item(s))
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
      plots.push(lq.plot(wavelengths, s.values,
        label: none, mark: none, smooth: true, stroke: 3.4pt + white, z-index: 3))
    }
    plots.push(lq.plot(wavelengths, s.values,
      label: none, mark: none, smooth: true,
      stroke: s.stroke, z-index: s.at("z", default: 4)))
  }
  let diagram = lq.diagram(
    width: 100%, height: height,
    title: title, xlabel: xlabel, ylabel: ylabel,
    xlim: (wavelengths.first(), wavelengths.last()),
    ylim: ylim, legend: none,
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


// =============================================================================
// SPD functions (spd- prefix) and computed series (plain names)
// =============================================================================

#let sub-dip(x, center, width, depth: 0.1) = 1.0 - depth * gauss(x, center, width)
#let blackbody(x, temp) = {
  let c2 = 14387768.0; let xr = x / 560.0
  let e = calc.exp(c2 / (x * temp))
  1.0 / (calc.pow(xr, 5.0) * (e - 1.0))
}

#let daylight-reference(x) = (
  blackbody(x, 5778) *
  sub-dip(x, 430,  8, depth: 0.030) * sub-dip(x, 486,  6, depth: 0.035) *
  sub-dip(x, 517,  8, depth: 0.025) * sub-dip(x, 589,  5, depth: 0.045) *
  sub-dip(x, 656,  7, depth: 0.035) * sub-dip(x, 690,  9, depth: 0.030) *
  sub-dip(x, 760, 12, depth: 0.090)
)

// Photopic (V'λ) — standard luminosity function via CIE-Y
#let photopic-weight(x) = cie-y(x)

// Melanopic action spectrum — melanopsin (ipRGC), peak ≈ 490 nm
#let melanopic-weight(x) = gauss(x, 490, 36, amp: 1.0) * sub-dip(x, 610, 90, depth: 0.40)

// Source SPDs
#let spd-incandescent(x)    = blackbody(x, 2700)
#let spd-cheap-blue-led(x)  = gauss(x, 451, 12, amp: 1.16) + gauss(x, 545, 60, amp: 0.58) + gauss(x, 610, 86, amp: 0.50)
#let spd-neutral-led(x)     = gauss(x, 452, 15, amp: 0.62) + gauss(x, 505, 48, amp: 0.36) + gauss(x, 575, 78, amp: 0.84) + gauss(x, 640, 70, amp: 0.34)
#let spd-warm-led(x)        = gauss(x, 452, 18, amp: 0.20) + gauss(x, 525, 55, amp: 0.30) + gauss(x, 600, 86, amp: 0.94) + gauss(x, 665, 64, amp: 0.58)
#let spd-violet-pump-led(x) = gauss(x, 415, 12, amp: 0.46) + gauss(x, 470, 38, amp: 0.46) + gauss(x, 535, 62, amp: 0.76) + gauss(x, 610, 78, amp: 0.76) + gauss(x, 670, 66, amp: 0.40)
#let spd-cool-daylight-led(x) = gauss(x, 450, 13, amp: 1.05) + gauss(x, 505, 48, amp: 0.48) + gauss(x, 565, 70, amp: 0.78) + gauss(x, 635, 82, amp: 0.28)
#let spd-rgb-white(x) = gauss(x, 455, 18, amp: 0.52) + gauss(x, 530, 25, amp: 0.78) + gauss(x, 625, 30, amp: 0.86)
#let spd-high-cri-warm-led(x) = gauss(x, 450, 18, amp: 0.16) + gauss(x, 510, 65, amp: 0.40) + gauss(x, 585, 78, amp: 0.85) + gauss(x, 650, 72, amp: 0.60) + gauss(x, 705, 45, amp: 0.22)
#let spd-candle(x) = blackbody(x, 1850)
#let spd-amber-night(x) = gauss(x, 590, 32, amp: 0.62) + gauss(x, 630, 35, amp: 0.75) + gauss(x, 675, 34, amp: 0.38)
#let spd-red-night(x) = gauss(x, 630, 28, amp: 0.18) + gauss(x, 665, 28, amp: 0.88)

// Circadian state SPDs
#let spd-day-state(x)     = gauss(x, 455, 38, amp: 0.86) + gauss(x, 505, 62, amp: 0.80) + gauss(x, 570, 82, amp: 0.88) + gauss(x, 650, 92, amp: 0.46)
#let spd-evening-state(x) = gauss(x, 455, 30, amp: 0.10) + gauss(x, 520, 70, amp: 0.28) + gauss(x, 595, 88, amp: 0.86) + gauss(x, 660, 78, amp: 0.64)
#let spd-night-state(x)   = gauss(x, 455, 26, amp: 0.012) + gauss(x, 525, 55, amp: 0.040) + gauss(x, 610, 48, amp: 0.42) + gauss(x, 660, 38, amp: 0.82)


#let make-series(f) = normalize(wl.map(f))

#let daylight      = make-series(daylight-reference)
#let photopic      = make-series(photopic-weight)
#let melanopic     = make-series(melanopic-weight)
#let incandescent  = make-series(spd-incandescent)
#let cheap-blue-led   = make-series(spd-cheap-blue-led)
#let neutral-led      = make-series(spd-neutral-led)
#let warm-led         = make-series(spd-warm-led)
#let violet-pump-led  = make-series(spd-violet-pump-led)
#let cool-daylight-led = make-series(spd-cool-daylight-led)
#let rgb-white = make-series(spd-rgb-white)
#let high-cri-warm-led = make-series(spd-high-cri-warm-led)
#let candle = make-series(spd-candle)
#let amber-night = make-series(spd-amber-night)
#let red-night = make-series(spd-red-night)
#let day-state     = make-series(spd-day-state)
#let evening-state = make-series(spd-evening-state)
#let night-state   = make-series(spd-night-state)

// Source definitions — ordered by approximate melanopic weighted integral
#let source-catalog = (
  cool_daylight_led: (
    name: [Cool daylight LED],
    values: cool-daylight-led,
    stroke: 1.0pt + cyan,
    accent: cyan,
    note: [high-CCT blue-pump white, strong cyan region],
    detail: [This is the classic office-daylight source: visually bright, cool in appearance, and heavy in the short-wavelength band that the ipRGC reader weights strongly. It is useful for daytime alerting, but it is the wrong default for evening interiors.],
  ),
  cheap_blue_pump_led: (
    name: [Cheap blue-pump LED],
    values: cheap-blue-led,
    stroke: 1.0pt + blue,
    accent: blue,
    note: [narrow blue spike at ~450 nm + broad phosphor],
    detail: [
      The pump peak sits close enough to the blue-cyan band read by melanopsin that ordinary white light can carry a strong clock signal.
    ],
  ),
  neutral_phosphor_led: (
    name: [Neutral phosphor LED],
    values: neutral-led,
    stroke: 1.0pt + blackish,
    accent: blackish,
    note: [common balanced white],
    detail: [A visually balanced white still carries blue-cyan energy from the phosphor pump. Visual adequacy is not circadian neutrality: the same spectrum that makes the room feel naturally lit also feeds melanopic response.],
  ),
  violet_pump_full_spectrum_led: (
    name: [Violet-pump / full-spectrum LED],
    values: violet-pump-led,
    stroke: 1.0pt + violet,
    accent: violet,
    note: [pump at ~415 nm, engineered broad spectrum],
    detail: [A violet pump shifts the primary excitation below the melanopic peak and spreads more energy through the visible range. That can improve color quality while reducing the worst blue-pump spike, but it is still a daytime-capable spectrum unless output and timing are controlled.],
  ),
  rgb_mixed_white: (
    name: [RGB mixed white],
    values: rgb-white,
    stroke: 1.0pt + green,
    accent: green,
    note: [three narrow emitters mixed to appear white],
    detail: [An RGB white can hit a white appearance with narrow bands rather than a continuous phosphor. Its biological behavior depends on the blue channel contribution: color mixing can hide a strong clock signal inside a visually ordinary white.],
  ),
  high_cri_warm_led: (
    name: [High-CRI warm LED],
    values: high-cri-warm-led,
    stroke: 1.0pt + red,
    accent: red,
    note: [warm phosphor blend with added red content],
    detail: [Better color rendering often means filling spectral gaps, including longer wavelengths. The warm appearance and richer red content lower melanopic efficiency compared with cool sources, but the blue pump is still present.],
  ),
  warm_phosphor_led: (
    name: [Warm phosphor LED],
    values: warm-led,
    stroke: 1.0pt + amber,
    accent: amber,
    note: [shifted toward amber and red, pump reduced],
    detail: [Warm phosphor LEDs reduce melanopic overlap by moving more visual work into longer wavelengths. They are better evening candidates than cool sources, but warm-white is not the same as biological night protection.],
  ),
  incandescent_2700k: (
    name: [Incandescent 2700 K],
    values: incandescent,
    stroke: 1.0pt + blackish,
    accent: blackish,
    note: [continuous thermal spectrum, red-heavy],
    detail: [A thermal continuum has less blue-cyan energy per unit of visual output than phosphor LEDs. It is visually inefficient, but biologically less clock-active than most white LEDs at the same photopic level.],
  ),
  candle_very_warm_flame: (
    name: [Candle / very warm flame],
    values: candle,
    stroke: 1.0pt + amber,
    accent: amber,
    note: [low-temperature thermal spectrum],
    detail: [A flame sits far down the warm thermal curve. It still emits visible light, but its photopic-normalized melanopic overlap is much smaller because very little energy lands in the blue-cyan window.],
  ),
  amber_night_source: (
    name: [Amber night source],
    values: amber-night,
    stroke: 1.0pt + red,
    accent: red,
    note: [narrow amber/red task and path lighting],
    detail: [Amber night lighting is not merely warm-looking white. It deliberately avoids the blue-cyan channel and uses the long-wavelength region for orientation, pathfinding, and minimal tasks.],
  ),
  deep_red_night_source: (
    name: [Deep red night source],
    values: red-night,
    stroke: 1.0pt + red,
    accent: red,
    note: [long-wavelength protection state],
    detail: [Deep red is the extreme case: little useful color rendering, low general visibility, but minimal melanopic overlap. It belongs to night protection, not ordinary room lighting.],
  ),
)

// The catalog is keyed for safe lookup; this separate list is the editorial order.
#let source-order = (
  "cool_daylight_led",
  "cheap_blue_pump_led",
  "neutral_phosphor_led",
  "violet_pump_full_spectrum_led",
  "rgb_mixed_white",
  "high_cri_warm_led",
  "warm_phosphor_led",
  "incandescent_2700k",
  "candle_very_warm_flame",
  "amber_night_source",
  "deep_red_night_source",
)

#let source-defs = source-order.map(key => source-catalog.at(key))
#let overlap-values = source-defs.map(s =>
  integrate-product(visual-normalize(s.values, photopic), melanopic))
#let overlap-max = calc.max(..overlap-values)
#let approx-integral(value) = str(calc.round(value * 100.0) / 100.0)

// =============================================================================
// Reference overlay infrastructure
// (thin reference curves drawn on top of every source spectrum)
// =============================================================================

#let reference-overlay-series = (
  (label: [idealized daylight],     values: daylight,  stroke: 0.62pt + ref-day,    z: 6),
  (label: [photopic weight (V′λ)],  values: photopic,  stroke: 0.70pt + ref-visual,  z: 7),
  (label: [melanopic weight (ipRGC)], values: melanopic, stroke: 1.10pt + ref-clock, halo: true, z: 8),
)

#let with-reference-overlays(base) = {
  base + reference-overlay-series
}

#let reference-overlay-key() = align(center)[
  #grid(
    columns: (auto, auto, auto),
    column-gutter: 12pt,
    align: horizon,
    ..reference-overlay-series.map(s => legend-item(s)),
  )
]



// =============================================================================
// Components — landscape editorial layout
// =============================================================================

#let page-kicker(body, accent: mute) = block(width: 100%)[
  #grid(
    columns: (auto, 1fr),
    column-gutter: 8pt,
    align: horizon,
    [#label(body, fill: accent)],
    [#line(length: 100%, stroke: hair + 0.55pt)],
  )
]

#let section-intro(kicker, title, body, accent: blackish, title-size: 25pt) = block(width: 100%)[
  #page-kicker(kicker, accent: accent)
  #v(5pt)
  #headline(size: title-size)[#title]
  #v(5pt)
  #lede(size: 10.2pt)[#body]
]

#let small-rule-note(kicker, body, accent: blackish) = block(width: 100%)[
  #label(kicker, fill: accent)
  #v(3pt)
  #note(body, size: 7.2pt)
]

#let callout-card(kicker, title, body, accent: blackish, fill: white, inset-x: 7pt, inset-y: 6pt) = block(
  width: 100%,
  inset: (x: inset-x, y: inset-y),
  radius: 3pt,
  fill: fill,
  stroke: hair + 0.55pt,
  breakable: false,
)[
  #label(kicker, fill: accent)
  #v(3pt)
  #text(size: 10.4pt, weight: "semibold", fill: ink)[#title]
  #v(3pt)
  #note(body, size: 7.15pt)
]

#let metric-pill(value, max-value, fill: violet) = block(width: 100%)[
  #metric-bar(value, max-value, fill: fill)
  #v(2pt)
  #grid(
    columns: (auto, 1fr),
    column-gutter: 5pt,
    align: horizon,
    [#text(size: 10.6pt, weight: "semibold", fill: ink)[#("≈ " + approx-integral(value))]],
    [#text(size: 5.8pt, fill: mute)[melanopic weighted area]],
  )
]

#let source-card(src, value, plot-height: 3.2cm, detail-size: 6.7pt) = block(
  width: 100%,
  inset: (x: 6pt, y: 5pt),
  radius: 3pt,
  fill: white,
  stroke: hair + 0.55pt,
  breakable: false,
)[
  #grid(
    columns: (1fr, 0.52fr),
    column-gutter: 7pt,
    align: top,
    [
      #label(src.name, fill: src.accent)
      #v(2pt)
      #note(src.note, size: 6.2pt, fill: mute)
      #v(4pt)
      #metric-pill(value, overlap-max, fill: violet)
    ],
    [
      #spectrum-plot(
        wl,
        height: plot-height,
        legend-position: "none",
        xlabel: text(size: 0pt)[],
        ylabel: text(size: 0pt)[],
        series: with-reference-overlays(((
          label: [], values: src.values,
          stroke: src.stroke, draw-area: true, z: 2,
        ),)),
      )
    ],
  )
  #v(3pt)
  #note(src.detail, size: detail-size)
]

#let compact-source(src, value) = block(
  width: 100%,
  inset: (x: 5pt, y: 4.5pt),
  radius: 3pt,
  fill: white,
  stroke: hair + 0.55pt,
  breakable: false,
)[
  #label(src.name, fill: src.accent)
  #v(2pt)
  #spectrum-plot(
    wl,
    height: 1.85cm,
    legend-position: "none",
    xlabel: text(size: 0pt)[],
    ylabel: text(size: 0pt)[],
    series: with-reference-overlays(((
      label: [], values: src.values,
      stroke: src.stroke, draw-area: true, z: 2,
    ),)),
  )
  #v(3pt)
  #metric-pill(value, overlap-max, fill: violet)
  #v(2pt)
  #note(src.note, size: 5.9pt, fill: mute)
]

#let sequence-chip(kicker, title, body, accent: blackish) = block(
  width: 100%,
  inset: (x: 7pt, y: 6pt),
  radius: 4pt,
  fill: faint,
  stroke: accent + 0.55pt,
  breakable: false,
)[
  #label(kicker, fill: accent)
  #v(3pt)
  #text(size: 10.8pt, weight: "semibold", fill: ink)[#title]
  #v(3pt)
  #note(body, size: 6.85pt)
]

#let state-wide-card(kicker, title, values, stroke, accent, principle, visual-body, clock-body) = block(
  width: 100%,
  inset: (x: 7pt, y: 6pt),
  radius: 4pt,
  fill: white,
  stroke: hair + 0.55pt,
  breakable: false,
)[
  #grid(
    columns: (0.32fr, 0.68fr),
    column-gutter: 8pt,
    align: top,
    [
      #label(kicker, fill: accent)
      #v(3pt)
      #text(size: 13.5pt, weight: "semibold", fill: ink)[#title]
      #v(4pt)
      #note(principle, size: 7.0pt)
    ],
    [
      #spectrum-plot(
        wl,
        height: 2.55cm,
        legend-position: "none",
        xlabel: text(size: 0pt)[],
        ylabel: text(size: 0pt)[],
        series: with-reference-overlays(((
          label: [], values: values, stroke: stroke, draw-area: true, z: 2,
        ),)),
      )
    ],
  )
  #v(4pt)
  #grid(
    columns: (1fr, 1fr),
    column-gutter: 7pt,
    align: top,
    [#small-rule-note([visual], visual-body, accent: ref-visual)],
    [#small-rule-note([clock], clock-body, accent: violet)],
  )
]

#let spec-panel(kicker, title, body, accent: blackish) = callout-card(kicker, title, body, accent: accent)

#let bottom-takeaway(kicker, body, accent: blackish) = block(width: 100%)[
  #v(4pt)
  #line(length: 100%, stroke: hair + 0.55pt)
  #v(5pt)
  #grid(
    columns: (0.16fr, 1fr),
    column-gutter: 8pt,
    align: top,
    [#label(kicker, fill: accent)],
    [#note(body, size: 7.45pt)],
  )
]


#let night-source-feature(src, value) = block(
  width: 100%,
  inset: (x: 8pt, y: 7pt),
  radius: 4pt,
  fill: white,
  stroke: hair + 0.55pt,
  breakable: false,
)[
  #grid(
    columns: (0.26fr, 0.74fr),
    column-gutter: 10pt,
    align: top,
    [
      #label(src.name, fill: src.accent)
      #v(3pt)
      #note(src.note, size: 6.8pt, fill: mute)
      #v(6pt)
      #label[melanopic integral, fill: violet]
      #v(4pt)
      #metric-pill(value, overlap-max, fill: violet)
      #v(5pt)
      #note(src.detail, size: 6.85pt)
    ],
    [
      #spectrum-plot(
        wl,
        height: 4.15cm,
        legend-position: "none",
        xlabel: text(size: 5.2pt)[Wavelength / nm],
        ylabel: text(size: 5.2pt)[Relative power],
        series: with-reference-overlays(((
          label: [], values: src.values,
          stroke: src.stroke, draw-area: true, z: 2,
        ),)),
      )
    ],
  )
]

#let state-row(kicker, title, values, stroke, accent, principle, visual-body, clock-body) = block(
  width: 100%,
  inset: (x: 8pt, y: 6pt),
  radius: 4pt,
  fill: white,
  stroke: hair + 0.55pt,
  breakable: false,
)[
  #grid(
    columns: (0.20fr, 0.49fr, 0.155fr, 0.155fr),
    column-gutter: 9pt,
    align: top,
    [
      #label(kicker, fill: accent)
      #v(3pt)
      #text(size: 15pt, weight: "semibold", fill: ink)[#title]
      #v(5pt)
      #note(principle, size: 7.1pt)
    ],
    [
      #spectrum-plot(
        wl,
        height: 3.15cm,
        legend-position: "none",
        xlabel: text(size: 5.2pt)[Wavelength / nm],
        ylabel: text(size: 5.2pt)[Relative power],
        series: with-reference-overlays(((
          label: [], values: values, stroke: stroke, draw-area: true, z: 2,
        ),)),
      )
    ],
    [#small-rule-note([visual], visual-body, accent: ref-visual)],
    [#small-rule-note([clock], clock-body, accent: violet)],
  )
]

#let hierarchy-ribbon() = block(width: 100%, inset: (x: 8pt, y: 7pt), radius: 4pt, fill: faint, stroke: hair + 0.55pt)[
  #grid(
    columns: (1fr, auto, 1fr, auto, 1fr),
    column-gutter: 8pt,
    align: horizon,
    [#sequence-chip([day], [broad white], [Feed the clock when the body needs a daytime anchor.], accent: blue)],
    [#text(size: 15pt, fill: mute)[→]],
    [#sequence-chip([evening], [reduced-blue white], [Taper the signal while preserving social and task visibility.], accent: amber)],
    [#text(size: 15pt, fill: mute)[→]],
    [#sequence-chip([night], [low-blue layer], [Use constrained long-wavelength light for safe movement only.], accent: red)],
  )
]

// =============================================================================
// LANDSCAPE SECTION — Two reading systems
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
      [#callout-card(
        [visual system],
        [Photopic — V′λ],
        [Peaks near 555 nm. It is the basis for lux, footcandles, and luminous efficacy — the quantities that tell a lighting designer how bright the room appears.],
        accent: ref-visual,
        inset-y: 7pt,
      )],
      [#callout-card(
        [non-visual system],
        [Melanopic — ipRGC],
        [Peaks near 480–490 nm. It is produced by melanopsin in intrinsically photosensitive retinal ganglion cells and is quantified in melanopic EDI.],
        accent: violet,
        inset-y: 7pt,
      )],
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
        (label: [idealized daylight],               values: daylight,  stroke: 1.0pt + ref-day),
        (label: [photopic weight — V′λ / visual],   values: photopic,  stroke: 1.15pt + ref-visual),
        (label: [melanopic weight — ipRGC / clock], values: melanopic, stroke: 1.8pt + violet, halo: true),
      ),
    )
    #v(10pt)
    #grid(
      columns: (1fr, 1fr, 1fr),
      column-gutter: 8pt,
      align: top,
      [#sequence-chip([01 visual], [How bright does the room look?], [Visual adequacy is measured by photopic output and ordinary design targets.], accent: ref-visual)],
      [#sequence-chip([02 clock], [What time does the body think it is?], [Circadian drive depends on blue-cyan weighted area, not just apparent brightness.], accent: violet)],
      [#sequence-chip([03 design], [Separate the two readings.], [A lamp can pass lux, CCT, and CRI checks while still delivering the wrong biological signal.], accent: blue)],
    )
  ],
)

#pagebreak()

// =============================================================================
// LANDSCAPE SECTION — Source comparison matrix
// =============================================================================

#grid(
  columns: (0.28fr, 0.72fr),
  column-gutter: 12pt,
  align: top,
  [
    #section-intro(
      [source comparison],
      [White light has different engines.],
      [Common sources that all appear white do not feed the visual and melanopic readers the same way.],
      accent: violet,
      title-size: 25pt,
    )
    #v(7pt)
    #callout-card(
      [reading the number],
      [Equal visual output first.],
      [Each source is normalized to equal photopic visual output before its melanopic weighted integral is estimated. The number is an approximate area-under-the-curve value in arbitrary units, not a percentage scale.],
      accent: violet,
      fill: faint,
    )
    #v(7pt)
    #reference-overlay-key()
    #v(8pt)
    #callout-card(
      [design consequence],
      [The same visual target can be reached by different spectral engines.],
      [Future interior lighting should specify which engine is active in each scene: broad alerting white by day, warm reduced-blue white in the evening, and narrow long-wavelength light only when biological night must be protected.],
      accent: red,
    )
  ],
  [
    #grid(
      columns: (1fr, 1fr, 1fr),
      column-gutter: 6pt,
      row-gutter: 6pt,
      align: top,
      [#compact-source(source-defs.at(0), overlap-values.at(0))],
      [#compact-source(source-defs.at(1), overlap-values.at(1))],
      [#compact-source(source-defs.at(2), overlap-values.at(2))],
      [#compact-source(source-defs.at(3), overlap-values.at(3))],
      [#compact-source(source-defs.at(4), overlap-values.at(4))],
      [#compact-source(source-defs.at(5), overlap-values.at(5))],
      [#compact-source(source-defs.at(6), overlap-values.at(6))],
      [#compact-source(source-defs.at(7), overlap-values.at(7))],
      [#compact-source(source-defs.at(8), overlap-values.at(8))],
      [#compact-source(source-defs.at(9), overlap-values.at(9))],
      [#compact-source(source-defs.at(10), overlap-values.at(10))],
      [#callout-card(
        [matrix reading],
        [Lower is not automatically better. Later is different.],
        [Daytime needs alerting light. Evening needs a taper. Biological night needs protection. The matrix is not a universal ranking; it is a schedule argument.],
        accent: blue,
        fill: faint,
      )],
    )
  ],
)

#pagebreak()

// =============================================================================
// LANDSCAPE SECTION — Lower end / night products
// =============================================================================

#grid(
  columns: (0.38fr, 0.62fr),
  column-gutter: 13pt,
  align: top,
  [
    #section-intro(
      [night products],
      [Low-blue lamps are a night layer, not a mood.],
      [The night layer should not depend on ordinary warm-white lamps dimmed low. It needs fixtures whose emitted light is spectrally constrained before it enters the room.],
      accent: red,
      title-size: 27pt,
    )
  ],
  [
    #callout-card(
      [lower end],
      [The lower end matters more at night.],
      [The argument is not that every nighttime interior should become red. It is that nighttime scenes need sources whose emitted light avoids the blue-cyan band most strongly read by the circadian system.],
      accent: violet,
      fill: faint,
      inset-y: 8pt,
    )
  ],
)

#v(8pt)
#grid(
  columns: (1fr, 1fr),
  column-gutter: 9pt,
  align: top,
  [#night-source-feature(source-defs.at(9), overlap-values.at(9))],
  [#night-source-feature(source-defs.at(10), overlap-values.at(10))],
)

#v(8pt)
#grid(
  columns: (1fr, 1fr, 1fr, 1fr),
  column-gutter: 7pt,
  align: top,
  [#spec-panel(
    [blue-blocking lamp],
    [The source does the filtering.],
    [A blue-blocking lamp is not eyewear, software, or a habit correction. It is a fixture, bulb, tape channel, or path light whose emitted spectrum removes the blue-cyan band that overlaps the melanopic reader.],
    accent: amber,
  )],
  [#spec-panel(
    [not warm-white],
    [Warm appearance is not enough.],
    [A 2200–2700 K lamp can still be a phosphor LED with a blue pump hidden under an amber-looking output. “Warm,” “cozy,” and “soft white” are visual descriptions; low-blue is a spectral requirement.],
    accent: blue,
  )],
  [#spec-panel(
    [where it belongs],
    [Use it in the late-night circulation layer.],
    [The best applications are bedrooms, bathrooms, nurseries, corridors, stair paths, toe-kick lighting, bedside lamps, closet edges, and kitchen night paths: small-area, low-output orientation light.],
    accent: red,
  )],
  [#spec-panel(
    [product warning],
    [Low-blue does not authorize high output.],
    [A blue-blocking lamp reduces melanopic efficiency; it does not make unlimited light harmless. The target is enough light to move safely without restarting the day signal.],
    accent: violet,
  )],
)

#v(7pt)
#bottom-takeaway(
  [product translation],
  [For interior lighting, blue blocking means source-side spectral control: lamps and luminaires that avoid the blue-cyan band during biological night. Treat them as a layer below ordinary warm-white lighting — not as daytime white, not as decorative amber ambience, and not as permission to brighten the night.],
  accent: violet,
)

#pagebreak()

// LANDSCAPE SECTION — Three spectral states
// =============================================================================

#grid(
  columns: (0.38fr, 0.62fr),
  column-gutter: 13pt,
  align: top,
  [
    #section-intro(
      [day structure],
      [Good lighting is a function.],
      [The design target is not one optimized white spectrum. It is a day that changes spectral job.],
      accent: blue,
      title-size: 28pt,
    )
  ],
  [
    #callout-card(
      [from dimming],
      [Quantity is not character.],
      [Dimming changes how much light the ipRGC receives. It does not change the spectral efficiency of what remains. A dimmed blue-pump LED is still a blue-pump LED.],
      accent: blackish,
      fill: faint,
      inset-y: 8pt,
    )
  ],
)

#v(8pt)
#state-row(
  [state 01],
  [Day anchor],
  day-state,
  1.0pt + blue,
  blue,
  [Drive the ipRGC signal when the body needs it.],
  [High visual output with broad white appearance for work, orientation, and task performance.],
  [Intentional blue-cyan presence activates melanopsin, suppresses melatonin, and anchors the SCN to daytime.],
)
#v(7pt)
#state-row(
  [state 02],
  [Evening transition],
  evening-state,
  1.0pt + amber,
  amber,
  [Separate visual comfort from circadian activation.],
  [Warm, usable, socially comfortable light — sufficient for faces, tasks, and hospitality.],
  [Short-wavelength content is reduced so ipRGC drive falls and melatonin can rise ahead of sleep.],
)
#v(7pt)
#state-row(
  [state 03],
  [Night protection],
  night-state,
  1.0pt + red,
  red,
  [Withdraw the ipRGC signal as completely as possible.],
  [Minimal task light: navigation, safety, and orientation only. Not a room-filling scene.],
  [Blue-cyan energy is minimized as the primary design goal, not as a cosmetic warmth decision.],
)

#v(7pt)
#grid(
  columns: (auto, 1fr),
  column-gutter: 12pt,
  align: horizon,
  [#reference-overlay-key()],
  [#note(size: 7.7pt)[The reference curves stay on every state so the reader sees the same rule repeated: visual brightness and clock activation are overlapping but different readings of the same spectrum.]],
)

// #pagebreak()

// =============================================================================
// LANDSCAPE SECTION — Specification habit
// =============================================================================

// #grid(
//   columns: (0.33fr, 0.67fr),
//   column-gutter: 13pt,
//   align: top,
//   [
//     #section-intro(
//       [specification habit],
//       [Specify the signal, not just the lamp.],
//       [Circadian lighting begins when visual output and ipRGC signal are treated as related but distinct design quantities.],
//       accent: violet,
//       title-size: 28pt,
//     )
//     #v(9pt)
//     #reference-overlay-key()
//   ],
//   [
//     #grid(
//       columns: (1fr, 1fr),
//       column-gutter: 8pt,
//       row-gutter: 8pt,
//       align: top,
//       [#spec-panel(
//         [ask for SPD],
//         [Read the distribution.],
//         [A spectral power distribution shows where the energy is. CCT describes color appearance; CRI describes color rendering. Neither shows how the spectrum sits against the photopic or melanopic reader.],
//         accent: blue,
//       )],
//       [#spec-panel(
//         [separate metrics],
//         [Photopic and melanopic output are not the same output.],
//         [Visual brightness and ipRGC signal should be evaluated as distinct quantities. A single word — intensity — hides both. Design documents should show both for each scene.],
//         accent: violet,
//       )],
//       [#spec-panel(
//         [compare fairly],
//         [Normalize by visual output before comparing.],
//         [A source comparison is meaningful only when photopic output is held constant first. Otherwise brightness differences obscure spectral differences.],
//         accent: ref-visual,
//       )],
//       [#spec-panel(
//         [design states],
//         [Anchor, transition, protect.],
//         [The day needs three spectral jobs. Specify each as a scene with its own output level, spectral character, and schedule. A dimming curve is not a scene schedule.],
//         accent: red,
//       )],
//     )
//   ],
// )

