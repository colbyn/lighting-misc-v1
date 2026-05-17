#import "@preview/lilaq:0.6.0" as lq

// ============================================================================
// Circadian systems concept sheet: Light Is a Clock Signal
// -----------------------------------------------------------------------------
// Editorial direction:
// - Treat circadian lighting as a feedback-loop / systems problem.
// - SPD is one channel of the signal, not the whole story.
// - Build a multi-page client-facing explainer that can later be tightened into
//   a brochure, handout, or slide-like printed piece.
//
// Requires Typst package:
//   @preview/lilaq:0.6.0
// ============================================================================

#set page(
  paper: "us-letter",
  margin: (
    x: 0.30in,
    y: 0.30in,
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
  leading: 0.65em,
)

// ============================================================================
// Plot helpers
// ============================================================================

#let clamp(x, lo: 0.0, hi: 1.0) = calc.min(hi, calc.max(lo, x))

#let asymmetric-gaussian(x, center, left-scale, right-scale, amp: 1.0) = {
  let t = if x < center { (x - center) * left-scale } else { (x - center) * right-scale }
  amp * calc.exp(-0.5 * t * t)
}

#let cie-x(l) = {
  (
    asymmetric-gaussian(l, 442.0, 0.0624, 0.0374, amp: 0.362) +
    asymmetric-gaussian(l, 599.8, 0.0264, 0.0323, amp: 1.056) -
    asymmetric-gaussian(l, 501.1, 0.0490, 0.0382, amp: 0.065)
  )
}

#let cie-y(l) = {
  (
    asymmetric-gaussian(l, 568.8, 0.0213, 0.0247, amp: 0.821) +
    asymmetric-gaussian(l, 530.9, 0.0613, 0.0322, amp: 0.286)
  )
}

#let cie-z(l) = {
  (
    asymmetric-gaussian(l, 437.0, 0.0845, 0.0278, amp: 1.217) +
    asymmetric-gaussian(l, 459.0, 0.0385, 0.0725, amp: 0.681)
  )
}

#let srgb-encode(u) = {
  let u = clamp(u)
  if u <= 0.0031308 { 12.92 * u } else { 1.055 * calc.pow(u, 1.0 / 2.4) - 0.055 }
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
    rgb(int(calc.round(r * 255)), int(calc.round(g * 255)), int(calc.round(b * 255)))
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
    strips.push(lq.fill-between((x1, x2), (y1, y2), fill: wavelength-rgb(mid), stroke: none, smooth: false, z-index: z-index))
  }
  strips
}

#let legend-item(s) = grid(
  columns: (15pt, auto),
  column-gutter: 5pt,
  align: horizon,
  [#line(length: 15pt, stroke: s.stroke)],
  [#text(size: 6.4pt)[#s.label]],
)

#let series-legend(series, direction: "horizontal") = {
  let cells = ()
  for s in series { cells.push(legend-item(s)) }
  if direction == "vertical" {
    grid(columns: (auto,), row-gutter: 3pt, ..cells)
  } else {
    grid(columns: (auto, auto, auto, auto), column-gutter: 9pt, row-gutter: 3pt, ..cells)
  }
}

#let spectrum-plot(
  wavelengths,
  title: [Relative spectral power distribution],
  series: (),
  height: 4cm,
  legend-position: "bottom",
  xlabel: text(size: 5.6pt)[Wavelength / nm],
  ylabel: text(size: 5.6pt)[Relative power],
  ylim: (0, 1.08),
) = {
  let plots = ()
  for s in series {
    if s.at("draw-area", default: false) {
      for strip in spectral-area-strips(wavelengths, s.values, z-index: 1) { plots.push(strip) }
    }
    plots.push(lq.plot(wavelengths, s.values, label: none, mark: none, smooth: true, stroke: s.stroke, z-index: 2))
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

  if legend-position == "right" {
    grid(columns: (1fr, auto), column-gutter: 9pt, align: top, diagram, box(inset: (top: 18pt))[#series-legend(series, direction: "vertical")])
  } else if legend-position == "none" {
    diagram
  } else {
    block(width: 100%)[#diagram #v(4pt) #align(center)[#series-legend(series)]]
  }
}

// ============================================================================
// SPD data
// ============================================================================

#let wl = lq.linspace(380, 780, num: 401)

#let gauss(x, center, width, amp: 1.0) = amp * calc.exp(-0.5 * calc.pow((x - center) / width, 2))
#let skewed-gauss(x, center, left-width, right-width, amp: 1.0) = if x < center { gauss(x, center, left-width, amp: amp) } else { gauss(x, center, right-width, amp: amp) }
#let normalize(values) = {
  let max-val = calc.max(..values)
  if max-val == 0 { values } else { values.map(v => v / max-val) }
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
  let atmosphere = sub-dip(x, 430, 8, depth: 0.030) * sub-dip(x, 486, 6, depth: 0.035) * sub-dip(x, 517, 8, depth: 0.025) * sub-dip(x, 589, 5, depth: 0.045) * sub-dip(x, 656, 7, depth: 0.035) * sub-dip(x, 690, 9, depth: 0.030) * sub-dip(x, 760, 12, depth: 0.090)
  base * atmosphere
}

#let spd-morning(x) = gauss(x, 455, 36, amp: 0.72) + gauss(x, 505, 58, amp: 0.72) + gauss(x, 570, 82, amp: 0.84) + gauss(x, 650, 88, amp: 0.42)
#let spd-day(x) = gauss(x, 455, 38, amp: 0.82) + gauss(x, 505, 62, amp: 0.78) + gauss(x, 570, 82, amp: 0.88) + gauss(x, 650, 92, amp: 0.46)
#let spd-evening(x) = gauss(x, 455, 30, amp: 0.10) + gauss(x, 520, 70, amp: 0.28) + gauss(x, 595, 88, amp: 0.86) + gauss(x, 660, 78, amp: 0.64)
#let spd-night(x) = gauss(x, 455, 26, amp: 0.015) + gauss(x, 525, 55, amp: 0.045) + gauss(x, 610, 48, amp: 0.42) + gauss(x, 660, 38, amp: 0.82)

#let spd-static-neutral(x) = gauss(x, 450, 15, amp: 0.54) + gauss(x, 505, 46, amp: 0.34) + gauss(x, 575, 78, amp: 0.82) + gauss(x, 638, 70, amp: 0.34)
#let spd-static-warm(x) = gauss(x, 452, 18, amp: 0.18) + gauss(x, 525, 55, amp: 0.28) + gauss(x, 600, 86, amp: 0.92) + gauss(x, 665, 64, amp: 0.58)
#let spd-basic-tunable-day(x) = gauss(x, 452, 16, amp: 0.45) + gauss(x, 510, 50, amp: 0.32) + gauss(x, 582, 82, amp: 0.80) + gauss(x, 642, 72, amp: 0.36)
#let spd-basic-tunable-evening(x) = gauss(x, 452, 18, amp: 0.16) + gauss(x, 525, 58, amp: 0.26) + gauss(x, 600, 88, amp: 0.88) + gauss(x, 665, 68, amp: 0.58)
#let spd-melanopic-weight(x) = gauss(x, 490, 36, amp: 1.0) * sub-dip(x, 610, 90, depth: 0.40)

#let daylight = make-series(spd-daylight-reference)
#let morning = make-series(spd-morning)
#let day = make-series(spd-day)
#let evening = make-series(spd-evening)
#let night = make-series(spd-night)
#let static-neutral = make-series(spd-static-neutral)
#let static-warm = make-series(spd-static-warm)
#let tunable-day = make-series(spd-basic-tunable-day)
#let tunable-evening = make-series(spd-basic-tunable-evening)
#let melanopic = make-series(spd-melanopic-weight)

// ============================================================================
// Design tokens and components
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
#let warm-fill = rgb("#fff8ef")
#let violet-fill = rgb("#f8f3ff")

#let fine-label(body, fill: mute) = [#text(size: 6.5pt, weight: "bold", tracking: 0.09em, fill: fill)[#upper(body)]]
#let headline(body, size: 25pt, weight: "medium", fill: ink) = [#text(size: size, weight: weight, fill: fill)[#body]]
#let deck(body, size: 13pt, fill: soft-ink) = [
  #block(width: 100%)[
    #set par(leading: 0.72em)
    #text(size: size, fill: fill)[#body]
  ]
]
#let copy(body, size: 8.5pt, fill: soft-ink) = [
  #block(width: 100%)[
    #set par(leading: 0.63em)
    #text(size: size, fill: fill)[#body]
  ]
]

#let card(title, body, accent: black, fill: panel, title-size: 8pt) = [
  #block(width: 100%, inset: (x: 10pt, y: 9pt), radius: 8pt, fill: fill, stroke: hairline + 0.55pt)[
    #fine-label(title, fill: accent)
    #v(4pt)
    #copy(body, size: title-size)
  ]
]

#let signal-tile(label, value, body, accent: black, fill: panel) = [
  #block(width: 100%, inset: (x: 10pt, y: 9pt), radius: 8pt, fill: fill, stroke: hairline + 0.55pt)[
    #fine-label(label, fill: accent)
    #v(5pt)
    #text(size: 17pt, weight: "semibold", fill: ink)[#value]
    #v(4pt)
    #copy(body, size: 7.6pt)
  ]
]

#let arrow() = [#align(center + horizon)[#text(size: 16pt, fill: mute)[→]]]

#let loop-node(kicker, title, body, accent: black, fill: white) = [
  #block(width: 100%, inset: (x: 11pt, y: 10pt), radius: 10pt, fill: fill, stroke: hairline + 0.65pt)[
    #fine-label(kicker, fill: accent)
    #v(4pt)
    #text(size: 11pt, weight: "semibold", fill: ink)[#title]
    #v(5pt)
    #copy(body, size: 7.8pt)
  ]
]

#let big-equation() = [
  #block(width: 100%, inset: (x: 13pt, y: 12pt), radius: 12pt, fill: rgb("#fbfbff"), stroke: hairline + 0.65pt)[
    #align(center)[
      #text(size: 13pt, fill: mute)[LIGHT SIGNAL]
      #h(8pt)
      #text(size: 18pt, weight: "semibold", fill: ink)[=]
      #h(8pt)
      #text(size: 13pt, fill: blue)[spectrum]
      #h(5pt)
      #text(size: 13pt, fill: mute)[×]
      #h(5pt)
      #text(size: 13pt, fill: amber)[intensity]
      #h(5pt)
      #text(size: 13pt, fill: mute)[×]
      #h(5pt)
      #text(size: 13pt, fill: violet)[timing]
      #h(5pt)
      #text(size: 13pt, fill: mute)[×]
      #h(5pt)
      #text(size: 13pt, fill: cyan)[duration]
      #h(5pt)
      #text(size: 13pt, fill: mute)[×]
      #h(5pt)
      #text(size: 13pt, fill: red)[direction]
    ]
  ]
]

#let mini-spd(title, values, stroke, accent: black, fill: white) = [
  #block(width: 100%, inset: (x: 8pt, y: 7pt), radius: 8pt, fill: fill, stroke: hairline + 0.55pt)[
    #fine-label(title, fill: accent)
    #v(5pt)
    #spectrum-plot(
      wl,
      title: [#text(size: 7.7pt)[Relative SPD]],
      height: 2.5cm,
      legend-position: "none",
      xlabel: text(size: 5pt)[nm],
      ylabel: text(size: 5pt)[p],
      series: ((label: title, values: values, stroke: stroke, draw-area: true),)
    )
  ]
]

#let verdict(label, body, accent: black, fill: white) = [
  #block(width: 100%, inset: (x: 9pt, y: 8pt), radius: 7pt, fill: fill, stroke: hairline + 0.55pt)[
    #fine-label(label, fill: accent)
    #v(4pt)
    #copy(body, size: 7.45pt)
  ]
]

// ============================================================================
// Page 1 — Thesis
// ============================================================================

= Light Is a Clock Signal

#grid(
  columns: (0.36fr, 1fr),
  column-gutter: 17pt,
  align: top,
  [
    #fine-label[systems view]
    #v(6pt)
    #headline(size: 31pt)[Not just illumination. Regulation.]
    #v(10pt)
    #deck[
      The body does not read light only as visibility. It reads light as environmental time.
    ]
    #v(11pt)
    #card([the pivot], [Circadian lighting is not a better bulb. It is a correction to a broken feedback loop between interior environments and human biology.], accent: violet, fill: violet-fill)
  ],
  [
    #big-equation()
    #v(11pt)
    #grid(
      columns: (1fr, auto, 1fr, auto, 1fr),
      column-gutter: 8pt,
      align: horizon,
      loop-node([environment], [Built space sends a signal], [Every fixture contributes a pattern of spectral power, brightness, timing, duration, direction, glare, and spatial distribution.], accent: blue, fill: day-fill),
      arrow(),
      loop-node([organism], [The body interprets it], [The visual system sees the room. The non-visual system also reads light as a timing cue for the biological day/night cycle.], accent: violet, fill: violet-fill),
      arrow(),
      loop-node([response], [The system adjusts], [Alertness, sleep timing, hormonal rhythm, body temperature, and behavior respond to the received light pattern.], accent: amber, fill: warm-fill),
    )
    #v(10pt)
    #grid(
      columns: (1fr, 1fr, 1fr, 1fr, 1fr),
      column-gutter: 7pt,
      align: top,
      signal-tile([spectrum], [what color energy], [Where the power sits across visible wavelengths.], accent: blue, fill: day-fill),
      signal-tile([intensity], [how much], [How much light reaches the eye, not only the workplane.], accent: amber, fill: warm-fill),
      signal-tile([timing], [when], [The same light means different things at different hours.], accent: violet, fill: violet-fill),
      signal-tile([duration], [how long], [Brief exposure is not the same biological event as hours of exposure.], accent: cyan, fill: rgb("#f1fbfb")),
      signal-tile([direction], [where from], [Vertical light, glare, shielding, and view direction shape the signal.], accent: red, fill: night-fill),
    )
  ],
)

#v(12pt)

#grid(
  columns: (1fr, 1fr, 1fr),
  column-gutter: 9pt,
  align: top,
  card([natural light], [Outside, the schedule is built in: dawn rises, midday anchors the day, dusk steps the signal down, and night protects darkness.], accent: blue, fill: day-fill),
  card([modern interiors], [Indoors, lighting often becomes spectrally flat and temporally careless: the same signal appears across the whole day.], accent: amber, fill: warm-fill),
  card([circadian correction], [The goal is not imitation sunlight everywhere. The goal is to restore a useful environmental timing signal inside the building.], accent: violet, fill: violet-fill),
)

// ============================================================================
// Page 2 — The signal schedule
// ============================================================================

#pagebreak()

= The Signal Has a Daily Shape

#grid(
  columns: (0.32fr, 1fr),
  column-gutter: 16pt,
  align: top,
  [
    #fine-label[time function]
    #v(6pt)
    #headline(size: 28pt)[The right SPD depends on the hour.]
    #v(9pt)
    #deck(size: 12.5pt)[
      Circadian lighting is a changing signal, not a static specification.
    ]
    #v(11pt)
    #card([read the plots], [The violet line is a simplified melanopic sensitivity band. Daytime keeps useful energy in that region. Evening and night progressively withdraw it.], accent: violet, fill: violet-fill)
  ],
  [
    #spectrum-plot(
      wl,
      title: [Idealized circadian spectrum schedule],
      height: 8.0cm,
      legend-position: "right",
      series: (
        (label: [morning rise], values: morning, stroke: cyan + 0.95pt, draw-area: false),
        (label: [day anchor], values: day, stroke: blue + 1.0pt, draw-area: false),
        (label: [evening step-down], values: evening, stroke: amber + 1.0pt, draw-area: false),
        (label: [night protection], values: night, stroke: red + 0.95pt, draw-area: false),
        (label: [melanopic band], values: melanopic, stroke: violet + 0.8pt, draw-area: false),
      ),
    )
  ],
)

#v(10pt)

#grid(
  columns: (1fr, 1fr, 1fr, 1fr),
  column-gutter: 9pt,
  align: top,
  [#mini-spd([morning / rise], morning, cyan + 0.95pt, accent: cyan, fill: rgb("#f1fbfb")) #v(6pt) #verdict([signal job], [Begin rebuilding the daytime cue without making the room harsh.], accent: cyan)],
  [#mini-spd([day / anchor], day, blue + 1.0pt, accent: blue, fill: day-fill) #v(6pt) #verdict([signal job], [Provide a credible biological day: bright enough, broad enough, and present at the eye.], accent: blue)],
  [#mini-spd([evening / step down], evening, amber + 1.0pt, accent: amber, fill: evening-fill) #v(6pt) #verdict([signal job], [Preserve visual comfort while reducing clock-strength short-wavelength content.], accent: amber)],
  [#mini-spd([night / protect], night, red + 0.95pt, accent: red, fill: night-fill) #v(6pt) #verdict([signal job], [Keep orientation and safety, but stop pretending the night is day.], accent: red)],
)

// ============================================================================
// Page 3 — Broken loop vs corrected loop
// ============================================================================

#pagebreak()

= The Failure Is a Flat Signal

#grid(
  columns: (1fr, 1fr),
  column-gutter: 16pt,
  align: top,
  [
    #fine-label[broken feedback]
    #v(5pt)
    #headline(size: 24pt)[Static light keeps sending the wrong message.]
    #v(9pt)
    #grid(
      columns: (1fr,),
      row-gutter: 8pt,
      loop-node([1 / interior], [Same light all day], [The system provides a visually convenient but biologically flattened signal.], accent: amber, fill: warm-fill),
      loop-node([2 / exposure], [Timing becomes accidental], [The body receives too little useful daytime signal and too much persistent evening signal.], accent: violet, fill: violet-fill),
      loop-node([3 / drift], [The rhythm loses alignment], [The built environment no longer reinforces the external day/night cycle.], accent: red, fill: night-fill),
    )
  ],
  [
    #fine-label[restored feedback]
    #v(5pt)
    #headline(size: 24pt)[Scheduled light restores the missing signal.]
    #v(9pt)
    #grid(
      columns: (1fr,),
      row-gutter: 8pt,
      loop-node([1 / architecture], [Scenes change with the day], [The building has a morning, day, evening, and night mode.], accent: blue, fill: day-fill),
      loop-node([2 / exposure], [The signal matches the hour], [Spectrum, brightness, duration, and direction are controlled together.], accent: cyan, fill: rgb("#f1fbfb")),
      loop-node([3 / alignment], [The loop becomes legible again], [The interior environment stops fighting the biological day/night cycle.], accent: green, fill: rgb("#f4fbf1")),
    )
  ],
)

#v(13pt)

#grid(
  columns: (1fr, 1fr, 1fr),
  column-gutter: 9pt,
  align: top,
  card([not product magic], [A circadian claim attached to a bulb is weak. A scheduled lighting system is stronger because it controls the exposure pattern.], accent: violet, fill: violet-fill),
  card([not daylight cosplay], [The goal is not to blast blue light or imitate the sun indoors. The goal is to send the right biological timing cue for the actual hour.], accent: blue, fill: day-fill),
  card([not just dimming], [Dimming matters, but the full signal also includes spectral content, duration, placement, glare, and direction.], accent: amber, fill: warm-fill),
)

// ============================================================================
// Page 4 — Comparison to common options
// ============================================================================

#pagebreak()

= Common Options Are Usually Incomplete

#grid(
  columns: (0.30fr, 1fr),
  column-gutter: 15pt,
  align: top,
  [
    #fine-label[comparison]
    #v(6pt)
    #headline(size: 25pt)[The problem is not that common lighting is ugly.]
    #v(9pt)
    #deck(size: 12.4pt)[
      The problem is that most lighting keeps one biological message too long.
    ]
    #v(11pt)
    #card([client-facing test], [Ask whether the system has a real day scene, evening scene, and night scene. If every hour uses the same spectral logic, it is not a circadian strategy.], accent: violet, fill: violet-fill)
  ],
  [
    #grid(
      columns: (1fr, 1fr, 1fr, 1fr),
      column-gutter: 9pt,
      align: top,
      [#mini-spd([ideal / day], day, blue + 1.0pt, accent: blue, fill: day-fill) #v(6pt) #mini-spd([ideal / evening], evening, amber + 1.0pt, accent: amber, fill: evening-fill) #v(6pt) #mini-spd([ideal / night], night, red + 0.95pt, accent: red, fill: night-fill)],
      [#mini-spd([static neutral], static-neutral, cyan + 0.95pt, accent: cyan, fill: rgb("#f1fbfb")) #v(6pt) #verdict([failure mode], [Serviceable in the middle of the day, but overactive in the evening and wrong for night.], accent: cyan)],
      [#mini-spd([static warm], static-warm, amber + 0.95pt, accent: amber, fill: warm-fill) #v(6pt) #verdict([failure mode], [Comfortable later in the day, but usually too weak as a daytime biological anchor.], accent: amber)],
      [#mini-spd([basic tunable], tunable-day, blue + 0.9pt, accent: blue, fill: day-fill) #v(6pt) #mini-spd([basic tunable evening], tunable-evening, amber + 0.9pt, accent: amber, fill: evening-fill) #v(6pt) #verdict([failure mode], [Better, but often still just a color-temperature schedule unless intensity, duration, direction, and night behavior are also designed.], accent: violet)],
    )
  ],
)

#v(12pt)

#grid(
  columns: (1fr, 1fr, 1fr, 1fr),
  column-gutter: 8pt,
  align: top,
  signal-tile([ideal scheduled], [changes], [The biological job changes as the day changes.], accent: blue, fill: day-fill),
  signal-tile([static neutral], [lingers], [It keeps sending a daytime-ish message into the evening.], accent: cyan, fill: rgb("#f1fbfb")),
  signal-tile([static warm], [softens], [It improves comfort but often weakens the daytime cue.], accent: amber, fill: warm-fill),
  signal-tile([basic tunable], [helps], [It is a useful layer, but incomplete without exposure control.], accent: violet, fill: violet-fill),
)

// ============================================================================
// Page 5 — Design rule
// ============================================================================

#pagebreak()

= Circadian Lighting Is a Control Problem

#grid(
  columns: (0.40fr, 1fr),
  column-gutter: 16pt,
  align: top,
  [
    #fine-label[closing frame]
    #v(6pt)
    #headline(size: 28pt)[Do not buy a clock signal. Design one.]
    #v(9pt)
    #deck(size: 12.6pt)[
      The emitter matters, but the system matters more.
    ]
  ],
  [
    #big-equation()
    #v(12pt)
    #grid(
      columns: (1fr, 1fr, 1fr),
      column-gutter: 9pt,
      row-gutter: 9pt,
      align: top,
      card([day scene], [Broad, bright, comfortable light with enough vertical presence to support a real daytime signal.], accent: blue, fill: day-fill),
      card([evening scene], [Reduced intensity and reduced short-wavelength drive while preserving faces, hospitality, and visual comfort.], accent: amber, fill: evening-fill),
      card([night scene], [Local, brief, shielded, low-glare light for orientation and safety — not a smaller version of the day scene.], accent: red, fill: night-fill),
      card([controls], [Scenes must be easy enough to use that the building actually follows the intended schedule.], accent: violet, fill: violet-fill),
      card([architecture], [Vertical surfaces, indirect light, glare, and fixture placement shape the signal as much as the diode package.], accent: cyan, fill: rgb("#f1fbfb")),
      card([measurement], [The relevant exposure is at the eye over time. Workplane lux and CCT alone cannot describe the biological signal.], accent: black, fill: panel),
    )
  ],
)

#v(14pt)

#block(width: 100%, inset: (x: 16pt, y: 14pt), radius: 14pt, fill: rgb("#fbfbff"), stroke: hairline + 0.75pt)[
  #align(center)[
    #text(size: 18pt, weight: "semibold", fill: ink)[Circadian lighting restores a feedback loop the building accidentally erased.]
  ]
]


