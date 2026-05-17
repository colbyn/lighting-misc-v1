#import "@preview/lilaq:0.6.0" as lq

/*
Circadian concept sheet — redesigned from the supplied drafts.

Editorial intent:
- Preserve the opening thesis: light is a clock signal.
- Remove the box-heavy product-comparison feel.
- Make the argument legible through page architecture: hero, signal grammar,
  schedule, and specification consequences.
- Treat SPD as one layer of the biological signal, not as the whole system.
- Keep this file standalone so it can be included, copied, or split later.
*/

#set page(
  paper: "us-letter",
  flipped: true,
  margin: (x: 0.34in, y: 0.32in),
  fill: white,
)

#set text(font: "Avenir Next", size: 9pt, fill: rgb("#24242a"))
#set par(justify: false, leading: 0.66em)

// -----------------------------------------------------------------------------
// Spectral plotting helpers
// -----------------------------------------------------------------------------

#let clamp(x, lo: 0.0, hi: 1.0) = calc.min(hi, calc.max(lo, x))

#let asymmetric-gaussian(x, center, left-scale, right-scale, amp: 1.0) = {
  let t = if x < center { (x - center) * left-scale } else { (x - center) * right-scale }
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
  columns: (14pt, auto),
  column-gutter: 4pt,
  align: horizon,
  [#line(length: 14pt, stroke: s.stroke)],
  [#text(size: 6.2pt, fill: rgb("#4d4d58"))[#s.label]],
)

#let series-legend(series, direction: "horizontal") = {
  let cells = ()
  for s in series { cells.push(legend-item(s)) }
  if direction == "vertical" {
    grid(columns: (auto,), row-gutter: 3pt, ..cells)
  } else {
    grid(columns: (auto, auto, auto, auto), column-gutter: 8pt, row-gutter: 3pt, ..cells)
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
    grid(columns: (1fr, auto), column-gutter: 8pt, align: top, diagram, box(inset: (top: 18pt))[#series-legend(series, direction: "vertical")])
  } else if legend-position == "none" {
    diagram
  } else {
    block(width: 100%)[#diagram #v(4pt) #align(center)[#series-legend(series)]]
  }
}

// -----------------------------------------------------------------------------
// Idealized SPD data
// -----------------------------------------------------------------------------

#let wl = lq.linspace(380, 780, num: 401)
#let gauss(x, center, width, amp: 1.0) = amp * calc.exp(-0.5 * calc.pow((x - center) / width, 2))
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

// -----------------------------------------------------------------------------
// Editorial components
// -----------------------------------------------------------------------------

#let ink = rgb("#24242a")
#let soft-ink = rgb("#4d4d58")
#let mute = rgb("#737480")
#let hairline = rgb("#d9d9e6")
#let faint = rgb("#f7f7fa")
#let blue = rgb("#005eff")
#let cyan = rgb("#008f9a")
#let violet = rgb("#7a3cff")
#let amber = rgb("#bd6a00")
#let red = rgb("#a83232")
#let green = rgb("#3a9a00")

#let fine-label(body, fill: mute) = text(size: 6.4pt, weight: "bold", tracking: 0.095em, fill: fill)[#upper(body)]
#let head(body, size: 28pt) = text(size: size, weight: "medium", fill: ink)[#body]
#let lede(body, size: 12.2pt, fill: soft-ink) = [
  #block(width: 100%)[#set par(leading: 0.76em)
  #text(size: size, fill: fill)[#body]]
]
#let body-copy(body, size: 8.4pt, fill: soft-ink) = [
  #block(width: 100%)[#set par(leading: 0.66em)
  #text(size: size, fill: fill)[#body]]
]
#let rule(stroke: hairline + 0.55pt) = line(length: 100%, stroke: stroke)

#let band(label, title, body, accent: ink) = block(width: 100%)[
  #grid(
    columns: (62pt, 0.58fr, 1fr),
    column-gutter: 10pt,
    align: top,
    [#fine-label(label, fill: accent)],
    [#text(size: 12.4pt, weight: "semibold", fill: ink)[#title]],
    [#body-copy(body, size: 8.1pt)],
  )
  #v(6pt)
  #rule(stroke: hairline + 0.45pt)
]

#let measure-row(label, value, width, accent: ink) = grid(
  columns: (58pt, 1fr, 46pt),
  column-gutter: 7pt,
  align: horizon,
  [#fine-label(label, fill: accent)],
  [#box(width: 100%, height: 4pt, fill: rgb("#eeeeF4"))[#box(width: width, height: 4pt, fill: accent)]],
  [#text(size: 6.8pt, fill: mute)[#value]],
)

#let phase-column(label, title, values, stroke, body, accent: ink, bright: 50%, bluebar: 50%, clock: 50%, clock-label: [medium]) = block(width: 100%)[
  #fine-label(label, fill: accent)
  #v(4pt)
  #text(size: 13.5pt, weight: "semibold", fill: ink)[#title]
  #v(5pt)
  #spectrum-plot(
    wl,
    title: [],
    height: 2.55cm,
    legend-position: "none",
    ylabel: text(size: 0pt)[],
    xlabel: text(size: 0pt)[],
    series: ((label: [], values: values, stroke: stroke, draw-area: true),),
  )
  #v(5pt)
  #measure-row([level], [], bright, accent: accent)
  #v(3pt)
  #measure-row([blue-cyan], [], bluebar, accent: accent)
  #v(3pt)
  #measure-row([clock], clock-label, clock, accent: accent)
  #v(7pt)
  #body-copy(body, size: 7.65pt)
]

#let compare-row(label, body, morning-note, day-note, evening-note, night-note, accent: ink) = block(width: 100%)[
  #grid(
    columns: (1.05fr, 1fr, 1fr, 1fr, 1fr),
    column-gutter: 8pt,
    align: top,
    [
      #fine-label(label, fill: accent)
      #v(3pt)
      #body-copy(body, size: 7.6pt)
    ],
    [#body-copy(morning-note, size: 7.4pt)],
    [#body-copy(day-note, size: 7.4pt)],
    [#body-copy(evening-note, size: 7.4pt)],
    [#body-copy(night-note, size: 7.4pt)],
  )
  #v(7pt)
  #rule(stroke: hairline + 0.45pt)
]

// -----------------------------------------------------------------------------
// Page 1 — Thesis
// -----------------------------------------------------------------------------

= Light Is a Clock Signal

#grid(
  columns: (0.38fr, 1fr),
  column-gutter: 18pt,
  align: top,
  [
    #fine-label[systems view]
    #v(8pt)
    #head(size: 31pt)[Light is not only for seeing.]
    #v(9pt)
    #lede(size: 13.2pt)[
      Light is a clock signal.
    ]
    #v(4pt)
    #lede(size: 12.3pt)[
      The same spectrum can support wakefulness by day and disturb rest at night.
    ]
    #v(12pt)
    #rule(stroke: violet + 0.9pt)
    #v(8pt)
    #body-copy[
      Circadian lighting is not a decorative color-temperature feature. It is a scheduled exposure strategy: the building decides what biological message the eye receives at each part of the day.
    ]
  ],
  [
    TODO
  ],
)

// -----------------------------------------------------------------------------
// Next Page — Thesis Etc.
// -----------------------------------------------------------------------------

#pagebreak()

#grid(
  columns: (0.85fr, auto, 0.85fr, auto, 0.85fr),
  column-gutter: 9pt,
  align: horizon,
  [
    #fine-label([environment], fill: blue)
    #v(5pt)
    #text(size: 15pt, weight: "semibold")[The room emits a pattern]
    #v(5pt)
    #body-copy(size: 7.9pt)[Spectrum, level, timing, duration, direction, glare, and spatial distribution become the signal.]
  ],
  [#text(size: 18pt, fill: mute)[→]],
  [
    #fine-label([organism], fill: violet)
    #v(5pt)
    #text(size: 15pt, weight: "semibold")[The eye reads more than image]
    #v(5pt)
    #body-copy(size: 7.9pt)[Visual pathways support seeing. Non-visual pathways help interpret environmental time.]
  ],
  [#text(size: 18pt, fill: mute)[→]],
  [
    #fine-label([response], fill: amber)
    #v(5pt)
    #text(size: 15pt, weight: "semibold")[The body adjusts]
    #v(5pt)
    #body-copy(size: 7.9pt)[Alertness, sleep timing, hormone rhythm, body temperature, and behavior are pushed toward day or night.]
  ],
)
#v(16pt)
#grid(
  columns: (1fr, 1fr),
  column-gutter: 14pt,
  align: top,
  [
    #fine-label([the mistake], fill: red)
    #v(5pt)
    #head(size: 20pt)[Flatten the signal]
    #v(6pt)
    #band([day], [Too little biological day], [Dim interiors and weak vertical light fail to anchor the daytime cue.], accent: blue)
    #v(5pt)
    #band([evening], [Too much lingering day], [The same comfortable source now sends a stronger clock message than the hour deserves.], accent: amber)
    #v(5pt)
    #band([night], [No true night mode], [Room-filling white light treats orientation as if it were a daytime task.], accent: red)
  ],
  [
    #fine-label([the correction], fill: green)
    #v(5pt)
    #head(size: 20pt)[Schedule the exposure]
    #v(6pt)
    #band([day], [Build a credible day], [Enough light reaches the eye, with a spectrum and spatial field that support wakefulness.], accent: blue)
    #v(5pt)
    #band([evening], [Step down the clock load], [Keep hospitality and tasks usable while withdrawing the alerting part of the signal.], accent: amber)
    #v(5pt)
    #band([night], [Protect darkness], [Use local, shielded, minimal light only where orientation and safety require it.], accent: red)
  ],
)

#v(12pt)
#rule()
#v(7pt)
#grid(
  columns: (1fr, 1fr, 1fr, 1fr, 1fr),
  column-gutter: 12pt,
  align: top,
  band([spectrum], [what energy], [Where power sits across visible wavelengths.], accent: blue),
  band([intensity], [how much], [How much light reaches the eye, not only the workplane.], accent: amber),
  band([timing], [when], [The same light means different things at different hours.], accent: violet),
  band([duration], [how long], [Minutes, hours, and repeated exposure are different biological events.], accent: cyan),
  band([direction], [from where], [Vertical light, shielding, glare, and view direction change the received signal.], accent: red),
)

// -----------------------------------------------------------------------------
// Next Page — Schedule
// -----------------------------------------------------------------------------

#pagebreak()

= Spectrum Has a Schedule

#grid(
  columns: (0.34fr, 1fr),
  column-gutter: 17pt,
  align: top,
  [
    #fine-label[time function]
    #v(8pt)
    #head(size: 29pt)[The target changes because the biological job changes.]
    #v(10pt)
    #lede[
      Circadian lighting is not one SPD. It is a sequence: stronger by day, restrained by evening, and sparse by night.
    ]
    #v(12pt)
    #band([not cosmetic], [Warmth is not the design target], [A warm source can still be too bright, too persistent, or too room-filling. The real target is the exposure pattern at the eye.], accent: amber)
    #v(6pt)
    #band([not daylight cosplay], [The sun is not the fixture schedule], [The goal is not to imitate daylight at every hour. The goal is to restore a useful timing cue indoors.], accent: blue)
  ],
  [
    #spectrum-plot(
      wl,
      title: [Idealized daily movement of the clock signal],
      height: 7.6cm,
      legend-position: "right",
      series: (
        (label: [morning rise], values: morning, stroke: cyan + 0.95pt, draw-area: false),
        (label: [day anchor], values: day, stroke: blue + 1.0pt, draw-area: false),
        (label: [evening step-down], values: evening, stroke: amber + 1.0pt, draw-area: false),
        (label: [night protection], values: night, stroke: red + 0.95pt, draw-area: false),
        (label: [melanopic band], values: melanopic, stroke: violet + 0.75pt, draw-area: false),
      ),
    )
  ],
)

#v(12pt)
#rule()
#v(8pt)
#grid(
  columns: (1fr, 1fr, 1fr, 1fr),
  column-gutter: 14pt,
  align: top,
  phase-column([morning], [Start the day], morning, cyan + 0.95pt, [Begin rebuilding the daytime cue without making the room harsh.], accent: cyan, bright: 72%, bluebar: 74%, clock: 76%, clock-label: [high]),
  phase-column([day], [Anchor the clock], day, blue + 1pt, [Provide a credible biological day: broad enough, bright enough, and present at the eye.], accent: blue, bright: 92%, bluebar: 86%, clock: 90%, clock-label: [strong]),
  phase-column([evening], [Step down], evening, amber + 1pt, [Preserve visual comfort while reducing clock-strength short-wavelength content.], accent: amber, bright: 48%, bluebar: 22%, clock: 26%, clock-label: [low]),
  phase-column([night], [Protect darkness], night, red + 0.95pt, [Support orientation and safety without pretending the night is day.], accent: red, bright: 14%, bluebar: 4%, clock: 6%, clock-label: [near zero]),
)

// -----------------------------------------------------------------------------
// Next Page — Consequences
// -----------------------------------------------------------------------------

#pagebreak()

= Specify the Sequence, Not the Bulb Claim

#grid(
  columns: (0.5fr, 1fr),
  column-gutter: 16pt,
  align: top,
  [
    #fine-label[design consequence]
    #v(8pt)
    #head(size: 27pt)[A circadian system has scenes, not just sources.]
    #v(10pt)
    #lede[
      Product data is only the emitter layer. The actual biological signal is the scene delivered to the eye over time.
    ]
    #v(12pt)
    #band([ask first], [What is the day scene?], [Where does vertical and ambient light come from, and how does the room become convincingly daytime?], accent: blue)
    #v(6pt)
    #band([ask next], [What is the evening scene?], [How does the system lower clock load without making the space unusable?], accent: amber)
    #v(6pt)
    #band([ask last], [What is the night scene?], [Does the design have a true minimal, local, shielded mode, or only dimmed white light?], accent: red)
  ],
  [
    TODO
  ],
)

#pagebreak()

#grid(
  columns: (1.05fr, 1fr, 1fr, 1fr, 1fr),
  column-gutter: 8pt,
  align: top,
  [#fine-label[approach]],
  [#fine-label([morning], fill: cyan)],
  [#fine-label([day], fill: blue)],
  [#fine-label([evening], fill: amber)],
  [#fine-label([night], fill: red)],
)
#v(7pt)
#rule(stroke: ink + 0.65pt)
#v(7pt)
#compare-row(
  [scheduled spectrum],
  [Purposeful sequence: rising signal, strong day anchor, evening reduction, protected darkness.],
  [Builds the signal early rather than waiting for accidental daylight.],
  [Broad and biologically active enough to establish daytime.],
  [Steps down without abandoning usability.],
  [Low, local, and almost empty in the blue-cyan region.],
  accent: blue,
)
#v(5pt)
#compare-row(
  [static neutral],
  [A common office-white condition. It feels serviceable because it keeps saying the same thing.],
  [Acceptable visually, but generic biologically.],
  [Often weaker than a deliberate daytime scene.],
  [Too active once the hour changes.],
  [Wrong condition for night.],
  accent: cyan,
)
#v(5pt)
#compare-row(
  [static warm],
  [Comfortable later in the day, but usually too weak as an all-day timing strategy.],
  [Soft start; compromised cue.],
  [Underpowered as a day anchor.],
  [Closer to evening need.],
  [Still not a real night mode if bright or room-filling.],
  accent: amber,
)
#v(5pt)
#compare-row(
  [basic tunable white],
  [Better control layer, but many systems only move CCT and leave exposure architecture untouched.],
  [Good direction.],
  [Often the closest common option.],
  [Depends on dimming range and scene discipline.],
  [Incomplete without local shielded night behavior.],
  accent: violet,
)

#v(13pt)
#rule()
#v(8pt)
#grid(
  columns: (1fr, 1fr, 1fr, 1fr),
  column-gutter: 12pt,
  align: top,
  band([controls], [Scenes must be scheduled], [Manual color tuning is not a circadian strategy. The building needs default behavior that changes by hour.], accent: violet),
  band([optics], [Direction matters], [A strong workplane number can be biologically weak if little reaches the eye. Glare can make the opposite problem worse.], accent: cyan),
  band([dimming], [Range matters], [Evening and night scenes need real low-end control, not just a slightly warmer version of day.], accent: amber),
  band([spec], [Ask for the exposure], [Request the SPD, the scene schedule, the vertical-light strategy, and the night operating mode together.], accent: green),
)











// #grid(
//   columns: (1.02fr, 1.02fr, 1.02fr),
//   column-gutter: 10pt,
//   align: top,

//   phase-panel(
//     [day mode],
//     [Anchor the biological day],
//     [day target],
//     circadian-day,
//     blue + 1.0pt,
//     [This is broad, bright, visually comfortable light with real blue-cyan presence at the eye. The goal is not a theatrical blue spike. The goal is a credible daytime signal that fills the room and reaches the observer.],
//     accent: blue,
//     fill: day-fill,
//     brightness-width: 92%,
//     brightness-value: [high],
//     blue-width: 86%,
//     blue-value: [high],
//     clock-width: 90%,
//     clock-value: [strong],
//   ),

//   phase-panel(
//     [evening mode],
//     [Step the signal down],
//     [evening target],
//     circadian-evening,
//     amber + 1.0pt,
//     [Evening light still supports faces, tasks, and hospitality, but the blue-cyan region is intentionally thinned. This is where dimming range, vertical light control, and scene scheduling start to matter.],
//     accent: amber,
//     fill: evening-fill,
//     brightness-width: 54%,
//     brightness-value: [moderate],
//     blue-width: 24%,
//     blue-value: [reduced],
//     clock-width: 28%,
//     clock-value: [low],
//   ),

//   phase-panel(
//     [night mode],
//     [Protect darkness],
//     [night target],
//     circadian-night,
//     red + 0.95pt,
//     [Night light is a special case. It should be brief, local, shielded, and low glare—good enough for orientation and safety, but poor at pretending that the night is still day.],
//     accent: red,
//     fill: night-fill,
//     brightness-width: 16%,
//     brightness-value: [minimal],
//     blue-width: 4%,
//     blue-value: [near zero],
//     clock-width: 6%,
//     clock-value: [near zero],
//   ),
// )

