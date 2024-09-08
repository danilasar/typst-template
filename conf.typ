#let header() = {
  set align(center)
  set text(font: "Cambria")
  text("МИНОБРНАУКИ РОССИИ\nФедеральное государственное бюджетное образовательное учреждение\nвысшего образования\n")
  v(0.2em)
  text(weight: "bold", "«САРАТОВСКИЙ НАЦИОНАЛЬНЫЙ ИССЛЕДОВАТЕЛЬСКИЙ
  ГОСУДАРСТВЕННЫЙ УНИВЕРСИТЕТ
  ИМЕНИ Н. Г. ЧЕРНЫШЕВСКОГО»\n")
  set align(left)
}

#let signature(post, name) = {
  grid(
    columns: (1fr,) * 3,
    align: (left, center, right),
    row-gutter: 5pt,
    post, block(inset: (y: 13pt), line(length: 3cm, stroke: .4pt)), name
  )
}

#let get_student_word(sex) = {
  if sex == "male" {
    return "студента"
  } else if sex == "female" {
    return "студентки"
  } else if sex == "plural" {
    return "студентов"
  }
}

#let get_speciality(group) = {
  let specialities = (
    [02.03.02 --- Фундаментальная информатика и информационные технологии],
    [09.03.01 --- Информатика и вычислительная техника],
    [10.05.01 --- Компьютерная безопасность],
    [02.03.03 --- Математическое обеспечение и администрирование информационных систем],
    [09.03.04 --- Программная инженерия],
    [44.03.01 --- Педагогическое образование],
    [09.04.01 --- Информатика и вычислительная техника],
    [02.04.03 --- Математическое обеспечение и администрирование информационных систем]
    [27.03.03 --- Системный анализ и управление],
  )
  
  if group.at(1) == "7" { // x7x
    if group.at(2) == "1" { // x71
      return specialities.at(6) // ивт
    } else if group.at(2) == "3" {  // x73
      return specialities.at(7) // моаис
    }
    return []
  }
  let id = int(group.at(1)) - 1;
  
  if id < 0 or id > 8 {
    return []
  }
  return specialities.at(id)
}

#let referat_title(info) = {
  let author = info.at("author", default: (:))
  set align(center)
  v(3cm)
  text(weight: "bold", upper(info.at("title", default: [Тема работы])))
  par[РЕФЕРАТ]
  v(1.5cm)
  set align(left)
  let author_string = get_student_word(author.at("sex", default: "male"))
  author_string = author_string + " " + author.group.at(0) + " курса " + author.group + " группы\n"
  if author.faculty == [КНиИТ] {
    author_string = author_string + "направления " + get_speciality(author.group) + "\n"
  } else if author.at("speciality", default: []) != [] {
    author_string = author_string + "направления " + author.speciality + "\n"
  }

  text(author_string + "факультета " + author.faculty + "\n" + author.name)
  v(1fr)
  text("Проверено:\n")
  signature(info.inspector.degree, info.inspector.name)
}

#let make_title(
  type: "referat",
  info: ()
) = {
  set page(
    paper: "a4",
    margin: (
      top: 2cm,
      bottom: 2cm,
      left: 2.5cm,
      right: 1.5cm
    )
  )
  
  header()
  if type == "referat" {
    referat_title(info)
  }
  
  v(1fr)
  set align(center)
  text("Саратов 2024")
}

#let make_toc(
  info: ()
) = {

  outline(indent: 2%, title: [Содержание])
  pagebreak(weak: true)
}

#let aboba(settings: ()) = {
  
}

#let conf(
  title: none,
  info: (),
  type: "referat",
  settings: (),
  doc
) = {
  info.title = title
  settings.title_page = settings.at("title_page", default: (:))


  set text(
    size: 14pt
  )

  if settings.title_page.at("enabled", default: true) {
    make_title(type: type, info: info)
  }
  set align(left)

  set page(footer: context [
    #h(1fr)
    #counter(page).display(
      "1"
    )
  ])
  
  
  let caps_headings = (
    [Содержание],
    [Введение],
    [Заключение],
    [Список использованных источников]
  )
  show heading: it => {
    set text(size: 14pt)
    if it.depth == 1 {
      pagebreak(weak: true)
    }
    if caps_headings.contains(it.body) {
      set align(center)
      counter(heading).update(i => i - 1)
      upper(it.body)
    } else {
      it
    }
  }
  set heading(numbering: "1.1")
  set page(numbering: "1")
  if settings.contents_page.enabled {
    make_toc(info: info)
  }

  doc

  /*let count = authors.len()
  let ncols = calc.min(count, 3)
  grid(
    columns: (1fr,) * ncols,
    row-gutter: 24pt,
    ..authors.map(author => [
      #author.name \
      #author.affiliation \
      #link("mailto:" + author.email)
    ]),
  )

  par(justify: false)[
    *Abstract* \
    #abstract
  ]*/
}