#import "../styles/theme.typ": *

#set document(
  title: "Document Title",
  author: "Author Name",
)

#set page(
  paper: "us-letter",
  margin: (
    top: 0.5in,
    bottom: 0.5in,
    left: 0.5in,
    right: 0.5in,
  ),
  fill: white,
)

// ---- Colors ----

#let primary-color-text = rgb("#444446")
#let primary-color-text-lighter = rgb("#68686f")
#let primary-color-border = rgb("#acacb5")

// ---- Font families ----
#let font-display-alt = "Bodoni 72"
#let font-display-smallcaps = "Bodoni 72 Smallcaps"
#let font-display-editorial = "Didot"
#let font-display-literary = "Hoefler Text"
#let font-display-modern-serif = "New York"
#let font-meta = "Avenir Next"
#let font-mono = "Menlo"

// ---- Macros ----
#let spread-row(transform: x => x, ..items) = {
  let children = items.pos()
  let count = children.len()

  let cols = ()
  let cells = ()

  for i in range(count) {
    cols.push(auto)
    cells.push(transform(children.at(i)))

    if i < count - 1 {
      cols.push(1fr)
      cells.push([])
    }
  }

  block(width: 100%)[
    #grid(
      columns: cols,
      gutter: 0pt,
      ..cells,
    )
  ]
}

// ---- Body ----


#box[
  #set par(spacing: 8pt)
  #spread-row(
    transform: x => [
      #text(
        font: font-meta,
        size: 20pt,
        weight: 100,
        fill: primary-color-text
      )[#x]
    ]
  )[
    #align(left)[Salt Lake City, UT]
  ][
    #align(right)[Relocatable]
  ]
  #box(
    width: 100%,
    stroke: (
      top: 0.25pt + primary-color-border,
      bottom: 0.25pt + primary-color-border,
    ),
    inset: (x: 0.0in, y: 0.5in),
  )[
    #align(center)[
      #grid(
        columns: (1fr,),
        row-gutter: 30pt,
        align: center,

        text(
          font: font-display-smallcaps,
          size: 0.9in,
          weight: 900,
          fill: primary-color-text,
        )[Colbyn Wadman],
      )
    ]
  ]

  #spread-row(
    transform: x => [
      #box(
        stroke: 0.25pt + primary-color-border,
        inset: ( x: 0.2in, y: 0.2in ),
      )[
        #text(
          font: font-meta,
          size: 10pt,
          weight: 400,
          fill: primary-color-text
        )[#x]
      ]
    ]
  )[
    #link("mailto:colbyn@example.com")[colbyn\@example.com]
  ][
    #link("tel:+18015551212")[(801) 555-1212]
  ][
    #link("https://example.com")[example.com]
  ]
]


