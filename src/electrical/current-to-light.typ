// =============================================================================
// Electrical section: Current Is Not the Same Thing as Light
// =============================================================================
//
// Shared electrical presentation components live in components.typ.
// Global page geometry / typography come from main.typ.

#import "../spectra/components.typ": amber, section-intro
#import "components.typ": energy-split-card, current-response-card, same-average-card, photon-dose-card

#pagebreak()

#section-intro(
  [current → light],
  [Current is the control signal. Light is the result.],
  [
    LED dimming begins electrically, but electrical current, optical output, heat,
    and time structure are not interchangeable quantities. The driver determines
    the current waveform; the LED package determines what that waveform becomes.
  ],
  accent: amber,
  title-size: 25pt,
)

#v(8pt)

#energy-split-card()

#v(7pt)

#current-response-card()

#v(7pt)

#same-average-card()

#v(7pt)

#photon-dose-card()

