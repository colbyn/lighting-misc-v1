// Spectral computation, plotting, source definitions, and reference overlays.
//
// This fragment is intentionally independent of the document content. It
// provides the spectral API consumed by components and content fragments.
//
// Components / fragments can import this file directly rather than reaching
// back into circadian-lighting.typ.

#import "@preview/lilaq:0.6.0" as lq
#import "components.typ": *

// =============================================================================
// Math helpers
// =============================================================================

#let clamp(x, lo: 0.0, hi: 1.0) = calc.min(hi, calc.max(lo, x))

#let mix(a, b, t) = a + (b - a) * t

#let gauss(x, center, width, amp: 1.0) = amp * calc.exp(-0.5 * calc.pow((x - center) / width, 2))

#let asymmetric-gaussian(
  x,
  center,
  left-scale,
  right-scale,
  amp: 1.0,
) = {
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

// =============================================================================
// Wavelength → sRGB helpers
// =============================================================================

#let cie-x(l) = (
  asymmetric-gaussian(
    l,
    442.0,
    0.0624,
    0.0374,
    amp: 0.362,
  ) +
  asymmetric-gaussian(
    l,
    599.8,
    0.0264,
    0.0323,
    amp: 1.056,
  ) -
  asymmetric-gaussian(
    l,
    501.1,
    0.0490,
    0.0382,
    amp: 0.065,
  )
)

#let cie-y(l) = (
  asymmetric-gaussian(
    l,
    568.8,
    0.0213,
    0.0247,
    amp: 0.821,
  ) +
  asymmetric-gaussian(
    l,
    530.9,
    0.0613,
    0.0322,
    amp: 0.286,
  )
)

#let cie-z(l) = (
  asymmetric-gaussian(
    l,
    437.0,
    0.0845,
    0.0278,
    amp: 1.217,
  ) +
  asymmetric-gaussian(
    l,
    459.0,
    0.0385,
    0.0725,
    amp: 0.681,
  )
)

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

    let r = srgb-encode(
      3.2406 * x -
      1.5372 * y -
      0.4986 * z
    )

    let g = srgb-encode(
      -0.9689 * x +
      1.8758 * y +
      0.0415 * z
    )

    let b = srgb-encode(
      0.0557 * x -
      0.2040 * y +
      1.0570 * z
    )

    rgb(
      int(calc.round(r * 255)),
      int(calc.round(g * 255)),
      int(calc.round(b * 255)),
    )
  }
}

// =============================================================================
// Plot helpers
// =============================================================================

#let wl = lq.linspace(380, 780, num: 401)

#let spectral-area-strips(
  wavelengths,
  values,
  z-index: 1,
) = {
  let strips = ()

  for i in range(values.len() - 1) {
    let x1 = wavelengths.at(i)
    let x2 = wavelengths.at(i + 1)
    let y1 = values.at(i)
    let y2 = values.at(i + 1)

    strips.push(
      lq.fill-between(
        (x1, x2),
        (y1, y2),
        fill: wavelength-rgb((x1 + x2) / 2),
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

#let series-legend(
  series,
  columns: (auto, auto, auto, auto),
) = {
  let items = series.map(s => legend-item(s))

  grid(
    columns: columns,
    column-gutter: 8pt,
    row-gutter: 3pt,
    ..items,
  )
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
      for strip in spectral-area-strips(
        wavelengths,
        s.values,
        z-index: 1,
      ) {
        plots.push(strip)
      }
    }

    if s.at("halo", default: false) {
      plots.push(
        lq.plot(
          wavelengths,
          s.values,
          label: none,
          mark: none,
          smooth: true,
          stroke: 3.4pt + white,
          z-index: 3,
        )
      )
    }

    plots.push(
      lq.plot(
        wavelengths,
        s.values,
        label: none,
        mark: none,
        smooth: true,
        stroke: s.stroke,
        z-index: s.at("z", default: 4),
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
      #align(center)[
        #series-legend(
          series,
          columns: legend-columns,
        )
      ]
    ]
  } else {
    diagram
  }
}

// =============================================================================
// SPD functions
// =============================================================================

#let sub-dip(
  x,
  center,
  width,
  depth: 0.1,
) = 1.0 - depth * gauss(x, center, width)

#let blackbody(x, temp) = {
  let c2 = 14387768.0
  let xr = x / 560.0
  let e = calc.exp(c2 / (x * temp))

  1.0 / (
    calc.pow(xr, 5.0) *
    (e - 1.0)
  )
}

#let daylight-reference(x) = (
  blackbody(x, 5778) *
  sub-dip(x, 430, 8, depth: 0.030) *
  sub-dip(x, 486, 6, depth: 0.035) *
  sub-dip(x, 517, 8, depth: 0.025) *
  sub-dip(x, 589, 5, depth: 0.045) *
  sub-dip(x, 656, 7, depth: 0.035) *
  sub-dip(x, 690, 9, depth: 0.030) *
  sub-dip(x, 760, 12, depth: 0.090)
)

// Photopic V(λ) — standard luminosity function via CIE-Y.
#let photopic-weight(x) = cie-y(x)

// Melanopic action spectrum — melanopsin (ipRGC), peak ≈ 490 nm.
//
// Modeled as an asymmetric peak with steeper short-wavelength falloff and
// longer shallow tail toward red. The shape is intended as an illustrative
// approximation rather than a certified CIE S 026 calculation.
#let melanopic-weight(x) = asymmetric-gaussian(
    x,
    490,
    0.0295,
    0.0175,
    amp: 1.0,
  )

// =============================================================================
// Source SPDs
// =============================================================================

#let spd-incandescent(x) = blackbody(x, 2700)

#let spd-cheap-blue-led(x) = (
  gauss(x, 451, 12, amp: 1.16) +
  gauss(x, 545, 60, amp: 0.58) +
  gauss(x, 610, 86, amp: 0.50)
)

#let spd-neutral-led(x) = (
  gauss(x, 452, 15, amp: 0.62) +
  gauss(x, 505, 48, amp: 0.36) +
  gauss(x, 575, 78, amp: 0.84) +
  gauss(x, 640, 70, amp: 0.34)
)

#let spd-warm-led(x) = (
  gauss(x, 452, 18, amp: 0.20) +
  gauss(x, 525, 55, amp: 0.30) +
  gauss(x, 600, 86, amp: 0.94) +
  gauss(x, 665, 64, amp: 0.58)
)

#let spd-violet-pump-led(x) = (
  gauss(x, 415, 12, amp: 0.46) +
  gauss(x, 470, 38, amp: 0.46) +
  gauss(x, 535, 62, amp: 0.76) +
  gauss(x, 610, 78, amp: 0.76) +
  gauss(x, 670, 66, amp: 0.40)
)

#let spd-cool-daylight-led(x) = (
  gauss(x, 450, 13, amp: 1.05) +
  gauss(x, 505, 48, amp: 0.48) +
  gauss(x, 565, 70, amp: 0.78) +
  gauss(x, 635, 82, amp: 0.28)
)

#let spd-rgb-white(x) = (
  gauss(x, 455, 18, amp: 0.52) +
  gauss(x, 530, 25, amp: 0.78) +
  gauss(x, 625, 30, amp: 0.86)
)

#let spd-high-cri-warm-led(x) = (
  gauss(x, 450, 18, amp: 0.16) +
  gauss(x, 510, 65, amp: 0.40) +
  gauss(x, 585, 78, amp: 0.85) +
  gauss(x, 650, 72, amp: 0.60) +
  gauss(x, 705, 45, amp: 0.22)
)

#let spd-candle(x) = blackbody(x, 1850)

#let spd-amber-night(x) = (
  gauss(x, 590, 32, amp: 0.62) +
  gauss(x, 630, 35, amp: 0.75) +
  gauss(x, 675, 34, amp: 0.38)
)

#let spd-red-night(x) = (
  gauss(x, 630, 28, amp: 0.18) +
  gauss(x, 665, 28, amp: 0.88)
)

// =============================================================================
// Circadian state SPDs
// =============================================================================

#let spd-day-state(x) = (
  gauss(x, 455, 38, amp: 0.86) +
  gauss(x, 505, 62, amp: 0.80) +
  gauss(x, 570, 82, amp: 0.88) +
  gauss(x, 650, 92, amp: 0.46)
)

#let spd-evening-state(x) = (
  gauss(x, 455, 30, amp: 0.10) +
  gauss(x, 520, 70, amp: 0.28) +
  gauss(x, 595, 88, amp: 0.86) +
  gauss(x, 660, 78, amp: 0.64)
)

#let spd-night-state(x) = (
  gauss(x, 455, 26, amp: 0.012) +
  gauss(x, 525, 55, amp: 0.040) +
  gauss(x, 610, 48, amp: 0.42) +
  gauss(x, 660, 38, amp: 0.82)
)

// =============================================================================
// Computed spectral series
// =============================================================================

#let make-series(f) = normalize(wl.map(f))

#let daylight = make-series(daylight-reference)

#let photopic = make-series(photopic-weight)

#let melanopic = make-series(melanopic-weight)

#let incandescent = make-series(spd-incandescent)

#let cheap-blue-led = make-series(spd-cheap-blue-led)

#let neutral-led = make-series(spd-neutral-led)

#let warm-led = make-series(spd-warm-led)

#let violet-pump-led = make-series(spd-violet-pump-led)

#let cool-daylight-led = make-series(spd-cool-daylight-led)

#let rgb-white = make-series(spd-rgb-white)

#let high-cri-warm-led = make-series(spd-high-cri-warm-led)

#let candle = make-series(spd-candle)

#let amber-night = make-series(spd-amber-night)

#let red-night = make-series(spd-red-night)

#let day-state = make-series(spd-day-state)

#let evening-state = make-series(spd-evening-state)

#let night-state = make-series(spd-night-state)

// =============================================================================
// Source catalog
// =============================================================================

// The catalog is keyed for safe lookup; source-order below provides the
// editorial ordering used by the document.

#let source-catalog = (
  cool_daylight_led: (
    name: [Cool daylight LED],
    values: cool-daylight-led,
    stroke: 1.0pt + cyan,
    accent: cyan,
    note: [high-CCT blue-pump white, strong cyan region],
    detail: [
      This is the classic office-daylight source: visually bright,
      cool in appearance, and heavy in the short-wavelength band that
      the ipRGC reader weights strongly. It is useful for daytime
      alerting, but it is the wrong default for evening interiors.
    ],
  ),

  cheap_blue_pump_led: (
    name: [Cheap blue-pump LED],
    values: cheap-blue-led,
    stroke: 1.0pt + blue,
    accent: blue,
    note: [narrow blue spike at ~450 nm + broad phosphor],
    detail: [
      The pump peak sits close enough to the blue-cyan band read by
      melanopsin that ordinary white light can carry a strong clock signal.
    ],
  ),

  neutral_phosphor_led: (
    name: [Neutral phosphor LED],
    values: neutral-led,
    stroke: 1.0pt + blackish,
    accent: blackish,
    note: [common balanced white],
    detail: [
      A visually balanced white still carries blue-cyan energy from
      the phosphor pump. Visual adequacy is not circadian neutrality:
      the same spectrum that makes the room feel naturally lit also
      feeds melanopic response.
    ],
  ),

  violet_pump_full_spectrum_led: (
    name: [Violet-pump / full-spectrum LED],
    values: violet-pump-led,
    stroke: 1.0pt + violet,
    accent: violet,
    note: [pump at ~415 nm, engineered broad spectrum],
    detail: [
      A violet pump shifts the primary excitation below the melanopic
      peak and spreads more energy through the visible range. That can
      improve color quality while reducing the worst blue-pump spike,
      but it is still a daytime-capable spectrum unless output and
      timing are controlled.
    ],
  ),

  rgb_mixed_white: (
    name: [RGB mixed white],
    values: rgb-white,
    stroke: 1.0pt + green,
    accent: green,
    note: [three narrow emitters mixed to appear white],
    detail: [
      An RGB white can hit a white appearance with narrow bands rather
      than a continuous phosphor. Its biological behavior depends on
      the blue channel contribution: color mixing can hide a strong
      clock signal inside a visually ordinary white.
    ],
  ),

  high_cri_warm_led: (
    name: [High-CRI warm LED],
    values: high-cri-warm-led,
    stroke: 1.0pt + red,
    accent: red,
    note: [warm phosphor blend with added red content],
    detail: [
      Better color rendering often means filling spectral gaps,
      including longer wavelengths. The warm appearance and richer
      red content lower melanopic efficiency compared with cool sources,
      but the blue pump is still present.
    ],
  ),

  warm_phosphor_led: (
    name: [Warm phosphor LED],
    values: warm-led,
    stroke: 1.0pt + amber,
    accent: amber,
    note: [shifted toward amber and red, pump reduced],
    detail: [
      Warm phosphor LEDs move more visual work into longer wavelengths,
      which trims melanopic overlap somewhat compared with cool sources —
      but the reduction is modest, not a large drop. Warm-white is a
      better evening candidate than daylight LEDs, but it is still far
      from biological night protection.
    ],
  ),

  incandescent_2700k: (
    name: [Incandescent 2700 K],
    values: incandescent,
    stroke: 1.0pt + blackish,
    accent: blackish,
    note: [continuous thermal spectrum, red-heavy],
    detail: [
      A thermal continuum has less blue-cyan energy per unit of visual
      output than phosphor LEDs. It is visually inefficient, but
      biologically less clock-active than most white LEDs at the same
      photopic level.
    ],
  ),

  candle_very_warm_flame: (
    name: [Candle / very warm flame],
    values: candle,
    stroke: 1.0pt + amber,
    accent: amber,
    note: [low-temperature thermal spectrum],
    detail: [
      A flame sits far down the warm thermal curve. It still emits
      visible light, but its photopic-normalized melanopic overlap is
      much smaller because very little energy lands in the blue-cyan window.
    ],
  ),

  amber_night_source: (
    name: [Amber night source],
    values: amber-night,
    stroke: 1.0pt + red,
    accent: red,
    note: [narrow amber/red task and path lighting],
    detail: [
      Amber night lighting is not merely warm-looking white. It
      deliberately avoids the blue-cyan channel and uses the
      long-wavelength region for orientation, pathfinding, and minimal tasks.
    ],
  ),

  deep_red_night_source: (
    name: [Deep red night source],
    values: red-night,
    stroke: 1.0pt + red,
    accent: red,
    note: [long-wavelength protection state],
    detail: [
      Deep red is the extreme case: little useful color rendering,
      low general visibility, but minimal melanopic overlap. It belongs
      to night protection, not ordinary room lighting.
    ],
  ),
)

// The catalog is keyed for safe lookup; this separate list is the
// editorial order.

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
    integrate-product(
      visual-normalize(s.values, photopic),
      melanopic,
    )
  )

#let overlap-max = calc.max(..overlap-values)

#let approx-integral(value) = str(calc.round(value * 100.0) / 100.0)

// =============================================================================
// Reference overlay infrastructure
//
// Thin reference curves drawn on top of source spectra.
// =============================================================================

#let reference-overlay-series = (
  (
    label: [idealized daylight],
    values: daylight,
    stroke: 0.62pt + ref-day,
    z: 6,
  ),
  (
    label: [photopic weight (V(λ))],
    values: photopic,
    stroke: 0.70pt + ref-visual,
    z: 7,
  ),
  (
    label: [melanopic weight (ipRGC)],
    values: melanopic,
    stroke: 1.10pt + ref-clock,
    halo: true,
    z: 8,
  ),
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
