#let dim_ink = rgb("#171717")
#let dim_soft_ink = rgb("#2a2927")
#let dim_muted = rgb("#68635c")
#let dim_faint = rgb("#9a9288")

#let dim_paper = rgb("#fbfaf7")
#let dim_panel = rgb("#f6f1ea")
#let dim_panel_2 = rgb("#fff7ef")
#let dim_rule = rgb("#d8d0c4")
#let dim_hairline = rgb("#eee7dd")

#let dim_copper = rgb("#b9552d")
#let dim_copper_dark = rgb("#7e321d")
#let dim_copper_soft = rgb("#fff0e7")

#let dim_driver = rgb("#fff5f8")
#let dim_driver_rule = rgb("#ff6c6c")

#let dim_label(body) = text(
  size: 7pt,
  weight: "semibold",
  fill: dim_copper,
  tracking: 0.09em,
  upper(body),
)

#let dim_small(body) = text(
  size: 8.2pt,
  fill: dim_muted,
  body,
)

#let dim_deck(body) = text(
  size: 8.7pt,
  fill: dim_muted,
  body,
)

#let dim_rule_block() = line(length: 100%, stroke: 0.65pt + dim_rule)

#let dim_arrow = text(size: 13pt, fill: dim_copper)[→]

#let dim_chain_item(num, title, deck: none) = block(width: 100%)[
  #dim_label(num)
  #v(2pt)
  #text(size: 10.8pt, weight: "semibold", fill: dim_ink)[#title]
  #if deck != none [
    #v(2pt)
    #text(size: 7.9pt, fill: dim_muted)[#deck]
  ]
]

#let dim_editorial_card(title, deck, body) = block(width: 100%)[
  #line(length: 100%, stroke: 0.85pt + dim_rule)
  #v(5pt)
  #dim_label(deck)
  #v(3pt)
  #text(size: 10pt, weight: "semibold", fill: dim_ink)[#title]
  #v(4pt)
  #text(size: 8.35pt, fill: dim_soft_ink)[#body]
]

#let dim_compact_card(title, deck, body) = box(
  width: 100%,
  fill: white,
  stroke: (left: 1.2pt + dim_copper, rest: 0.45pt + dim_hairline),
  inset: (x: 8pt, y: 6pt),
)[
  #text(size: 9.3pt, weight: "semibold", fill: dim_ink)[#title]
  #h(5pt)
  #text(size: 7.1pt, weight: "semibold", tracking: 0.06em, fill: dim_copper)[#upper(deck)]
  #v(3pt)
  #text(size: 8pt, fill: dim_soft_ink)[#body]
]

#let dim_panel_shell(
  body,
  fill: none,
  stroke: 0.7pt + rgb("#ffffff00"),
  radius: 2pt,
  inset: 12pt,
) = box(
  width: 100%,
  fill: fill,
  stroke: stroke,
  radius: radius,
  inset: inset,
)[#body]

#let dim_side_panel(kicker, title, body) = dim_panel_shell[
  #dim_label(kicker)
  #v(1pt)
  #text(size: 13pt, weight: "semibold", fill: dim_ink)[#title]
  #v(7pt)
  #line(length: 100%, stroke: 0.7pt + dim_rule)
  #v(7pt)
  #text(size: 8.3pt, fill: dim_soft_ink)[#body]
]

#let dim_driver_panel(body) = dim_panel_shell(
  fill: dim_copper_soft,
  stroke: 0.5pt + dim_copper,
  radius: 2pt,
  inset: 12pt,
)[
  #text(size: 7pt, weight: "semibold", tracking: 0.12em, fill: dim_copper_dark)[TRANSLATION POINT]
  #v(1pt)
  #text(size: 18pt, weight: "semibold", fill: dim_ink)[Driver]
  #v(1pt)
  #line(length: 100%, stroke: 0.65pt + dim_copper)
  #v(7pt)
  #text(size: 8.4pt, fill: dim_soft_ink)[#body]
]

#let dim_note(title, body) = block(
  width: 100%,
  fill: dim_copper_soft,
  stroke: (left: 2pt + dim_copper, rest: 0pt),
  inset: (x: 9pt, y: 7pt),
)[
  #text(size: 8.7pt, weight: "semibold", fill: dim_copper_dark)[#title]
  #h(4pt)
  #text(size: 8.7pt, fill: dim_soft_ink)[#body]
]

#let dim_micro_list(items) = grid(
  columns: 1,
  row-gutter: 3pt,
  ..items.map(item => [
    #text(fill: dim_copper, weight: "semibold")[—]
    #h(4pt)
    #text(size: 8.1pt, fill: dim_soft_ink)[#item]
  ]),
)

#let dim_symptom(symptom, layer, implication) = (
  [#text(size: 8.2pt, weight: "semibold", fill: dim_ink)[#symptom]],
  [#text(size: 7.9pt, fill: dim_copper_dark)[#layer]],
  [#text(size: 7.9pt, fill: dim_soft_ink)[#implication]],
)

=== Dimming Is a Driver Behavior, Not Just a Control Protocol

A lighting control system does not dim an LED directly. It expresses an intent: lower this zone to 30 percent, recall this scene, warm this pendant row, fade the cove over five seconds. That intent must then pass through a driver interface, be translated by the driver into a power-stage behavior, and finally appear as a change in light output.

#v(7pt)

#block(
  width: 100%,
  fill: dim_paper,
  stroke: (top: 1pt + dim_ink, bottom: 0.6pt + dim_rule),
  inset: (x: 8pt, y: 8pt),
)[
  #grid(
    columns: (1fr, auto, 1fr, auto, 1.15fr, auto, 1fr),
    gutter: 7pt,
    align: horizon,

    dim_chain_item([01], [Intent], deck: [what the system asks for]),
    dim_arrow,
    dim_chain_item([02], [Interface], deck: [how the command arrives]),
    dim_arrow,
    dim_chain_item([03], [Driver modulation], deck: [how current is changed]),
    dim_arrow,
    dim_chain_item([04], [Optical result], deck: [what occupants see]),
  )
]

#v(7pt)

That sequence matters because the named control system is only one layer. DALI-2, 0--10V, DMX, wireless mesh, and phase-cut dimming describe how a command reaches the driver or luminaire. CCR and PWM describe how the driver changes LED current. The occupant only sees the final result: smoothness, flicker, color shift, low-end stability, shimmer, pop-on, drop-out, or audible noise.

"Dimmable" is therefore not a complete specification. It says the fixture has some way to reduce output. It does not say which interface it accepts, how low it can regulate, how it behaves near the bottom of the range, whether it reports faults, whether it is compatible with the installed dimmer, or whether two fixtures in the same zone will fade together.

#v(11pt)

#grid(
  columns: (0.95fr, 1.25fr, 0.95fr),
  gutter: 12pt,
  align: top,

  dim_side_panel(
    [command side],
    [Interface],
    [
      How intent reaches the luminaire or driver.

      #v(5pt)
      #dim_micro_list((
        [0--10V],
        [DALI-2],
        [DMX512],
        [wireless or network layer],
        [phase-cut input],
      ))
    ],
  ),

  dim_driver_panel[
    Where the command becomes regulated LED current.

    #v(5pt)
    #dim_micro_list((
      [interprets the interface],
      [applies the dimming curve],
      [enforces minimum output],
      [determines low-end behavior],
      [creates or suppresses temporal light modulation],
      [protects the LED load and driver electronics],
    ))
  ],

  dim_side_panel(
    [light side],
    [Power / optical result],
    [
      How output is actually changed and perceived.

      #v(5pt)
      #dim_micro_list((
        [CCR],
        [PWM],
        [hybrid CCR/PWM],
        [dim-to-warm response],
        [visible flicker, color shift, shimmer, or smooth fade],
      ))
    ],
  ),
)

#v(6pt)

#dim_note(
  [The governing distinction:],
  [
    The interface says what level is requested. The driver decides how that request becomes current through the LED array. That is why two fixtures using the same control protocol can dim differently.
  ],
)

==== Driver Interfaces: How the Command Reaches the Driver

The driver interface is the electrical or digital path by which a dimming command arrives at the driver. It is not the same thing as the driver’s internal dimming method. A DALI driver may use CCR, PWM, or a hybrid strategy at the LED output. A 0--10V driver may do the same. The interface defines the language of the command; the driver defines the power behavior.

#v(8pt)

#grid(
  columns: (1fr, 1fr),
  gutter: 13pt,
  row-gutter: 12pt,

  dim_editorial_card(
    [Phase-cut dimming],
    [legacy in architecture, current in the field],
    [
      Phase dimming modifies the AC supply waveform before it reaches the driver. The dimming command and the power feed occupy the same conductors, which is why phase-cut infrastructure remains common in existing residential, hospitality, and light commercial work.

      #v(4pt)
      Its practical weakness is compatibility. The dimmer, wiring conditions, load size, and driver input stage all affect behavior. A fixture labeled “phase dimmable” may still buzz, flicker, pop on, drop out, or stop fading smoothly below a certain level with a specific wall dimmer.

      #v(4pt)
      Phase-cut is conceptually a special case: it is both a power-feed condition and a control signal. That makes it harder to isolate problems in the field.
    ],
  ),

  dim_editorial_card(
    [0--10V control],
    [simple analog level command],
    [
      0--10V uses a separate low-voltage pair to communicate a requested dimming level. It is common, inexpensive, and adequate for many zone-based architectural systems.

      #v(4pt)
      Its limitation is that it usually provides no fixture-level feedback. The controller requests a level, but it does not know whether the driver reached it, failed, dropped out, or was substituted with a different response curve.
    ],
  ),

  dim_editorial_card(
    [DALI-2],
    [addressable digital control with feedback],
    [
      DALI-2 uses a two-wire digital bus to address drivers individually or by group. It supports commissioning, scene control, status reporting, fault information, and more precise device coordination than analog zone wiring.

      #v(4pt)
      DALI-2 does not remove the need to evaluate driver behavior. It improves communication and diagnostics, but the fade quality, minimum level, flicker performance, and LED current strategy still depend on the driver.
    ],
  ),

  dim_editorial_card(
    [DMX512],
    [high-channel, high-update control],
    [
      DMX512 is a digital protocol developed for entertainment lighting and remains useful for theatrical, façade, color-changing, and dynamic architectural applications.

      #v(4pt)
      It is not usually the best conceptual peer to DALI-2 for ordinary white-light architectural dimming. DMX is strong where channel count, timing, and show control matter; it is weaker where fixture feedback, routine diagnostics, and building-scale maintainability matter.
    ],
  ),

  dim_editorial_card(
    [Wireless and networked layers],
    [upstream communication, not automatic driver behavior],
    [
      Bluetooth mesh, Zigbee, proprietary RF systems, and IP-based control layers usually sit upstream of the driver interface. They may determine commissioning workflow, user experience, sensor behavior, and network topology.

      #v(4pt)
      They do not by themselves define the LED power-stage behavior. A wireless receiver may still output 0--10V, PWM, DALI commands, or another signal to the driver.
    ],
  ),

  dim_editorial_card(
    [Integral smart drivers],
    [interface and driver packaged together],
    [
      In some luminaires the network receiver, control logic, and LED driver are integrated into one assembly. That can improve coordination because the manufacturer controls more of the chain.

      #v(4pt)
      It can also make substitution harder. If the driver, radio, firmware, and dimming curve are a single product decision, replacement parts must preserve the whole behavior, not merely the wattage and output current.
    ],
  ),
)

==== Driver Modulation: How the Driver Changes LED Output

After the command reaches the driver, the driver must change the electrical conditions at the LED array. This is the actual power-stage dimming method. It is where many visible performance differences originate.

#v(8pt)

#grid(
  columns: (1fr, 1fr),
  gutter: 10pt,
  row-gutter: 8pt,

  dim_compact_card(
    [CCR / analog dimming],
    [reduces LED current directly],
    [
      Constant-current reduction lowers output by reducing the regulated LED current. Because the LED is not being switched fully on and off as the dimming mechanism, CCR avoids the temporal modulation associated with PWM.

      #v(3pt)
      The tradeoff is color behavior. LED chromaticity can shift as current changes, so low-end appearance may not match full-output appearance unless the driver and LED package are designed to compensate.
    ],
  ),

  dim_compact_card(
    [PWM],
    [changes the duty cycle of LED current],
    [
      Pulse-width modulation switches LED current on and off rapidly. The perceived output depends on the ratio of on-time to off-time.

      #v(3pt)
      PWM can preserve LED color during the on portion of the cycle, but poor frequency selection or low duty-cycle behavior can create flicker, stroboscopic effects, camera artifacts, or discomfort for sensitive occupants.
    ],
  ),

  dim_compact_card(
    [Hybrid CCR/PWM],
    [different strategies across the range],
    [
      Some drivers combine CCR and PWM. CCR may be used through the upper and middle dimming range, with PWM introduced near the low end to preserve controllability or extend the dimming range.

      #v(3pt)
      The advantage is flexibility. The risk is that the transition between methods can become visible if the curve, frequency, or control resolution is poorly implemented.
    ],
  ),

  dim_compact_card(
    [Dim-to-warm behavior],
    [controlled optical response, not just less power],
    [
      Dim-to-warm luminaires intentionally change color temperature as output falls. The driver may coordinate multiple LED channels rather than simply reducing one current path.

      #v(3pt)
      The specification issue is not only minimum dim level. It is the shape of the warm-dimming curve, consistency between fixtures, and whether the low-end color matches the design intent.
    ],
  ),
)

==== What Goes Wrong in the Field

Most dimming complaints are not solved by naming the protocol. They are solved by locating the weak layer in the chain. The same symptom can have more than one cause, but the layer map narrows the investigation.

#v(7pt)

#table(
  columns: (0.95fr, 0.9fr, 1.8fr),
  inset: (x: 5.5pt, y: 4.8pt),
  stroke: (_, y) => if y == 0 { 0pt } else { 0.45pt + dim_hairline },
  table.header(
    [#dim_label[Symptom]],
    [#dim_label[Likely layer]],
    [#dim_label[Field implication]],
  ),

  ..dim_symptom(
    [Visible flicker or shimmer],
    [Driver modulation / power quality],
    [Check PWM frequency, driver design, low-end behavior, and supply-side conditions. The control protocol may be innocent if the driver is producing unstable LED current.],
  ),

  ..dim_symptom(
    [Camera banding or stroboscopic artifacts],
    [Driver modulation],
    [A space may look acceptable to occupants but fail under cameras, rotating equipment, or fast motion. Specify temporal light modulation expectations where this matters.],
  ),

  ..dim_symptom(
    [Phase-cut flicker at certain dimmer positions],
    [Phase-cut interface and driver input stage],
    [The dimmer and driver are interacting poorly at specific phase angles or load conditions. Replace-by-label troubleshooting is unreliable; test the exact pairing.],
  ),

  ..dim_symptom(
    [Low-end pop-on with phase dimming],
    [Phase-cut interface / driver minimum regulation],
    [The driver cannot start or regulate at the requested low level, so output jumps above the command. Trim settings may help, but the real limit is driver-dimmer compatibility.],
  ),

  ..dim_symptom(
    [Drop-out before reaching zero],
    [Driver minimum output / interface behavior],
    [The fixture turns off before the control reaches its intended bottom level. The specified minimum dim level must be verified with the actual driver and control hardware.],
  ),

  ..dim_symptom(
    [Audible buzzing or ticking],
    [Phase-cut interface / driver magnetics],
    [Noise often appears only with certain dimmer-driver combinations or at certain levels. It is a compatibility and component-response problem, not an occupant preference problem.],
  ),

  ..dim_symptom(
    [Different fixtures fade differently in one zone],
    [Driver curve / product substitution],
    [Matching protocol and wattage is not enough. Drivers may use different dimming curves, minimum levels, or modulation strategies.],
  ),

  ..dim_symptom(
    [Low-end color shift],
    [LED package and driver modulation],
    [CCR, LED chromaticity behavior, thermal state, and channel mixing can all affect low-output appearance. Mock up hospitality, residential, gallery, and accent applications at actual low levels.],
  ),

  ..dim_symptom(
    [No fixture status or fault visibility],
    [Control interface],
    [Analog interfaces such as typical 0--10V cannot confirm driver state. Use a digital feedback-capable system where diagnostics, emergency reporting, or maintenance visibility matter.],
  ),

  ..dim_symptom(
    [Scene recalls but output does not match intent],
    [Commissioning / driver curve / interface translation],
    [The control system may be issuing the right command while the driver maps it to a different output curve. Commission scenes by observed output, not only by programmed percentage.],
  ),
)

==== Specification Consequence

The driver is the convergence point. It receives the command, interprets the interface, regulates LED current, applies the dimming curve, and determines whether the visible result feels smooth, stable, quiet, and consistent.

A complete dimming requirement should therefore name more than the protocol. It should define the accepted driver interface, the minimum stable dim level, expected fade behavior, low-end start and stop behavior, temporal light modulation limits where relevant, acoustic expectations, dim-to-warm or color behavior, reporting requirements, and the exact compatibility assumptions for dimmers, drivers, control modules, and luminaires.

#v(7pt)

#dim_note(
  [Specification rule:],
  [
    do not specify “dimmable” as a product attribute. Specify the interface, the driver behavior, the low-end performance, and the field condition under which that performance must be proven.
  ],
)

#v(7pt)

The control system and the power interface are not separable decisions. They are two sides of the same chain: the command side and the current side. If they are coordinated through the driver, dimming feels intentional. If they are selected independently, the project inherits the driver’s compromises.
