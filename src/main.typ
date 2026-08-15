#import "lib/common.typ": page-margin

#set document(
  title: "On Lighting",
  author: "The Lighting Nerd",
)

// #set page(
//   paper: "us-letter",
//   margin: (
//     x: 0.25in,
//     y: 0.25in,
//   ),
//   flipped: true,
//   fill: rgb("#222222"),
// )

#set page(
  // paper: "us-letter",
  paper: "a4",
  margin: (
    x: page-margin.x,
    y: page-margin.y,
  ),
  flipped: true,
  fill: rgb("#222222"),
)

// #set text(
//   font: "Avenir Next",
//   size: 8.45pt,
//   fill: rgb("#fff"),
// )

// #set par(
//   justify: false,
//   leading: 0.62em,
//   spacing: 7pt,
// )

// =============================================================================
// Shared document tokens
// =============================================================================

#import "spectra/components.typ": ink

// =============================================================================
// Document setup
// =============================================================================

// #set page(
//   paper: "us-letter",
//   flipped: true,
//   margin: (x: 0.2in, y: 0.2in),
// )

#set text(
  font: "Avenir Next",
  size: 8.45pt,
  fill: ink,
)

#set par(
  justify: false,
  leading: 0.62em,
  spacing: 7pt,
)

// #{ include "cover/page.typ" }

// #{ include "content/playground.typ" }

// #{ include "concepts/spectrum-white-light.typ" }
// #{ include "concepts/spectrum-example-gallery.typ" }
#{ include "spectra.typ" }
// #{ include "concepts/leds-dimming.typ" }

// #{ include "led-basics/optics.typ" }
