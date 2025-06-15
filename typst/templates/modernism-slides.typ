#import "@preview/touying:0.6.1": *

#let slide(title: auto, ..args) = touying-slide-wrapper(self => {
  if title != auto {
    self.store.title = title
  }
  let header(self) = {
    let slide-title = if self.store.title != none {
      self.store.title
    } else {
      utils.display-current-heading(level: 2)
    }
    h(1cm)
    box(width: 100% - 2cm, {
      text(size: 1.4em, slide-title)
      box(height: 1pt, width: 100%, fill: black)
    })
  }
  let footer(self) = {
    set text(size: 0.8em, fill: self.colors.dim)
    place(right, dx: -1em, context utils.slide-counter.display()
      + [#h(0.1em)/#h(0.1em)]
      + context utils.last-slide-number)
  }
  touying-slide(
    self: utils.merge-dicts(self, config-page(header: header, footer: footer)),
    ..args,
  )
})

#let empty-slide(body) = touying-slide-wrapper(self => {
  touying-slide(
    self: utils.merge-dicts(self, config-common(freeze-slide-counter: true)),
    body,
  )
})

#let new-section-slide(self: none, body) = touying-slide-wrapper(self => {
  let main-body = {
    set align(center + horizon)
    set text(
      size: 2em,
      fill: self.colors.primary,
      weight: "bold",
      style: "italic",
    )
    utils.display-current-heading(level: 1)
    v(1.5em)
  }
  touying-slide(
    self: utils.merge-dicts(self, config-common(freeze-slide-counter: true)),
    main-body,
  )
})

#let title-slide() = touying-slide-wrapper(self => {
  let info = self.info
  touying-slide(
    self: utils.merge-dicts(self, config-common(freeze-slide-counter: true)),
    {
      align(horizon + center, {
        pad(left: 1cm, right: 1cm, text(
          fill: self.colors.primary,
          size: 28pt,
          weight: "bold",
          info.title,
        ))
        v(0.5em)

        par(info.authors.join(", "))

        par(info.date.display("[month repr:short] [day padding:none], [year]"))
      })
    },
  )
})

#let ending-slide() = touying-slide-wrapper(self => {
  touying-slide(
    self: utils.merge-dicts(self, config-common(freeze-slide-counter: true)),
    {
      align(horizon + center, {
        text(
          fill: self.colors.primary,
          size: 30pt,
          weight: "bold",
          [Thanks & Questions],
        )
      })

      place(right + bottom, text(size: 10pt, fill: self.colors.dim)[
        Created with Typst, #self.info.font and #self.info.monofont
      ])
    },
  )
})

#let modernism-slides(
  aspect-ratio: "16-9",
  font: "Avenir Next",
  monofont: "Cascadia Code",
  primary-color: olive,
  ..args,
  body,
) = {
  show: touying-slides.with(
    config-page(
      paper: "presentation-" + aspect-ratio,
      margin: (
        top: 2.6cm,
        bottom: 1cm,
        left: 1cm,
        right: 1cm,
      ),
      header-ascent: 0.8em,
    ),
    config-common(
      slide-fn: slide,
      new-section-slide-fn: new-section-slide,
      show-strong-with-alert: false,
    ),
    config-colors(primary: primary-color, dim: luma(150)),
    config-methods(
      title-slide: title-slide,
      ending-slide: ending-slide,
      alert: (self: none, it) => text(
        fill: self.colors.primary,
        weight: "regular",
        it,
      ),
      dim: (self: none, it) => text(
        fill: self.colors.dim,
        size: 0.8em,
        weight: "regular",
        it,
      ),
    ),
    config-info(font: font, monofont: monofont),
    config-store(title: none),
    ..args,
  )

  set text(size: 18pt, font: font)
  show raw: set text(font: monofont)
  show link: set text(fill: blue)
  show "“": text(font: "Inter", features: ("ss03",), "“")
  show "”": text(font: "Inter", features: ("ss03",), "”")

  body
}

#let dim(cont) = text(fill: luma(180), cont)
#let warn(cont) = text(fill: red, cont)
#let sepline = line(length: 100%, stroke: (
  paint: luma(160),
  thickness: 1pt,
  dash: "dashed",
))
#let split(portions, ..args) = grid(columns: portions, ..args)
