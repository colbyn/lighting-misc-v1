/*
Circadian lighting — spectral overview, v4.

Argument:
  1. Spectrum is read by more than one system. The non-visual reader is
     ipRGC-mediated melanopsin response — the biology is named and explained,
     not assumed.
  2. Common white sources feed those readers differently. The comparison is
     normalized by visual output and reported as an approximate melanopic
     weighted integral, not as a relative percent scale.
  3. A good lighting system changes spectral job across the day.
  4. Specifying the lamp is not enough. Specify the signal and the sequence.

Section flow:
  - Two reading systems: visual / ipRGC.
  - Industry metrics: translating spectral measurements into design metrics.
  - White light has different engines: source comparison.
  - Lower end / night products: biological-night lighting layer.
  - Three spectral states: day anchor / evening transition / night protection.
*/

// =============================================================================
// Shared document tokens
// =============================================================================

#import "spectra/components.typ": ink

// =============================================================================
// Document setup
// =============================================================================

#set page(
  paper: "us-letter",
  flipped: true,
  margin: (x: 0.2in, y: 0.2in),
)

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

// =============================================================================
// Two reading systems
// =============================================================================

#include "spectra/reading-systems.typ"

#pagebreak()

// =============================================================================
// Industry metrics
// =============================================================================

#include "spectra/industry-metrics.typ"

#pagebreak()

// =============================================================================
// Industry metrics
// =============================================================================

#include "spectra/industry-metrics-der-page.typ"

#pagebreak()

// =============================================================================
// Industry metrics
// =============================================================================

#include "spectra/industry-metrics-spectrum-strategy.typ"

#pagebreak()

// =============================================================================
// Industry metrics
// =============================================================================

#include "spectra/industry-metrics-source-reading.typ"

#pagebreak()

// =============================================================================
// Source comparison
// =============================================================================

#include "spectra/source-comparison.typ"

#pagebreak()

// =============================================================================
// Night products
// =============================================================================

#include "spectra/night-products.typ"

#pagebreak()

// =============================================================================
// Three spectral states
// =============================================================================

#include "spectra/spectral-states.typ"

// =============================================================================
// Specification habit
// =============================================================================

// Currently inactive. If this section is restored, factor it into:
//   spectra/specification-habit.typ
//
// #pagebreak()
// #include "spectra/specification-habit.typ"
// 