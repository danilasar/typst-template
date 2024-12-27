#set text(font: "PT Serif")
#import "conf.typ" : conf
#import "conf.typ" : turn-on-first-line-indentation
// Для таблиц и тд
#import "@preview/plotst:0.2.0": *
#import "@preview/fletcher:0.4.5" as fletcher: diagram, node, edge

#show: conf.with(
  title: [Применение шаблона для typst],
  type: "referat",
  info: (
      author: (
        name: [Григорьева Данилы (danilasar), Смирнова Егора (aragami3070), Толстова Роберта (tolstovrob)],
        faculty: [КНиИТ],
        group: "251",
        sex: "plural"
      ),
      inspector: (
        degree: "",
        name: ""
      )
  ),
  settings: (
    title_page: (
      enabled: true
    ),
    contents_page: (
      enabled: true
    )
  )
)

// Функция добавления красных строк
#show: turn-on-first-line-indentation


= Test bib

Some cite #cite(<search_8>)

Some cite #cite(<search_11>)

Some cite #cite(<eichten1984supercollider>)

= Список использованных источников
#bibliography("test.bib", style: "gost-7-1-2003.csl", title: none, full: false)
