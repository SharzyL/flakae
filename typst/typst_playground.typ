#import "templates/modernism-slides.typ": *
#import "@preview/codly:1.3.0": *

#set text(lang: "en")

#show: codly-init
#codly(lang-format: none)

#show: avenir-theme.with(
  config-info(
    title: [Introduction to Typst],
    authors: ("Alice",),
    date: datetime(year: 2025, month: 5, day: 30),
  ),
  config-common(handout: false),
)

#title-slide()

= Section

== Introduction

```cpp
#include <typeinfo>
```

#split((1fr, 1fr))[#lorem(10)][#lorem(10)]

#ending-slide()
