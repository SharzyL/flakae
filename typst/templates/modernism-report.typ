#let mathv(amount) = box(baseline: 100%, height: amount, width: 0pt)

#let theme(c) = strong(text(c, fill: blue))
#let alert(c) = text(c, fill: red)

#let make-title(title, authors) = {
  set document(title: title)
  align(center, text(1.5em, title))
  align(center, {
    for author in authors {
      text(1em, author, style: "italic")
    }
  })
}

#let modernism-report(
  aspect-ratio: "16-9",
  font: "New Computer Modern",
  font-size: 12pt,
  lang: "en",
  monofont: "Cascadia Code",
  primary-color: olive,
  ..args,
) = {
  body => {
    set text(font: font, size: font-size, lang: lang)
    show math.equation: set text(features: ("cv01",))
    set page("a4", margin: 0.6in)
    set par(justify: true)

    show heading.where(level: 1): c => {
      v(1em, weak: false)
      h(-1.2em)
      text("#", fill: olive, baseline: -0.1em)
      h(0.3em)
      c.body
    }

    show heading.where(level: 2): c => {
      v(0.6em, weak: false)
      h(-1.2em)
      text("+", fill: olive, baseline: -0.1em)
      h(0.3em)
      c.body
    }

    show heading.where(level: 3): c => {
      v(0.4em, weak: false)
      h(-1em)
      text("*", fill: olive, baseline: 0.2em)
      h(0.3em)
      c.body
    }

    body
  }
}
