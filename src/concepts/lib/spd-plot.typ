#import "@preview/lilaq:0.6.0" as lq

// ---------------------------------------------
// Color science helpers
// ---------------------------------------------

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


// ---------------------------------------------
// Spectral fill construction
// ---------------------------------------------

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


// ---------------------------------------------
// Legend helpers
// ---------------------------------------------

#let legend-item(s) = grid(
  columns: (18pt, auto),
  column-gutter: 6pt,
  align: horizon,
  [
    #line(length: 18pt, stroke: s.stroke)
  ],
  [
    #text(size: 8.5pt)[#s.label]
  ],
)

#let series-legend(series, direction: "horizontal") = {
  let cells = ()

  for s in series {
    cells.push(legend-item(s))
  }

  if direction == "vertical" {
    grid(
      columns: (auto,),
      row-gutter: 4pt,
      ..cells,
    )
  } else {
    grid(
      columns: (auto, auto),
      column-gutter: 14pt,
      row-gutter: 4pt,
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


// ---------------------------------------------
// Public plot wrapper
// ---------------------------------------------

#let spectrum-plot(
  title: [Relative spectral power distribution],
  wavelengths,
  series: (),
  width: 100%,
  height: 6cm,
  legend-position: auto,
  xlabel: text(size: 7pt)[Wavelength / nm],
  ylabel: text(size: 7pt)[Relative radiant power],
  xlim: none,
  ylim: (0, 1.08),
) = {
  
  let plots = ()

  let resolved-xlim = if xlim == none {
    (
      wavelengths.first(),
      wavelengths.last(),
    )
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
        column-gutter: 12pt,
        align: top,

        diagram,

        box(
          inset: (top: 24pt),
        )[
          #series-legend(series, direction: "vertical")
        ],
      )
    ]
  } else if placement == "bottom" {
    block(width: width)[
      #diagram

      #v(6pt)

      #align(center)[
        #series-legend(series, direction: "horizontal")
      ]
    ]
  } else if placement == "top" {
    block(width: width)[
      #align(center)[
        #series-legend(series, direction: "horizontal")
      ]

      #v(6pt)

      #diagram
    ]
  } else {
    diagram
  }
}


