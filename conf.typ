#import "@preview/ctheorems:1.1.3": *

/*
 * Примечания:
 * - Код разбит по модулям, каждый из которых объявляется и инициализируется
 *   в переменной modules. Методы именуются в змеином стиле, при этом
 *   приватные начинаются с подчёркивания.
 *
 *   В силу отсутствия адекватной реализации приватных методов в Typst
 *   приватность --- лишь условное соглашение: такие методы не предназначены
 *   для вызова извне, хотя фактически такая возможность имеется. Не делайте
 *   так!
 *
 * - Чтобы не засорять кодовую базу, строковые константы вынесены в
 *   переменную strings.
 */


#let strings = (
  title: (
    minobrnauki: "МИНОБРНАУКИ РОССИИ\nФедеральное государственное бюджетное образовательное учреждение\nвысшего образования\n",
    sgu: "«САРАТОВСКИЙ НАЦИОНАЛЬНЫЙ ИССЛЕДОВАТЕЛЬСКИЙ ГОСУДАРСТВЕННЫЙ УНИВЕРСИТЕТ ИМЕНИ Н. Г. ЧЕРНЫШЕВСКОГО»\n",
    city: "Саратов",
    worktypes: (
      referat: [РЕФЕРАТ],
      coursework: [КУРСОВАЯ РАБОТА],
      diploma: [Выпускная квалификационная работа],
      autoref: [работа],
      nir: [работа],
      pract: [Отчёт о практике],
    ),
    from_course: "курса",
    from_group: "группы",
    from_speciality: "направления",
  ),
  student: (
    male: "студента",
    female: "студентки",
    plural: "студентов",
  ),
  caps_headings: (
    [СОДЕРЖАНИЕ],
    [ВВЕДЕНИЕ],
    [ЗАКЛЮЧЕНИЕ],
    [Список использованных источников],
    [Определения, обозначения и сокращения],
    [Обозначения и сокращения],
  ),
  specialities: (
    spec_kb: [10.05.01 --- Компьютерная безопасность],
    bac_ivt: [09.03.01 --- Информатика и вычислительная техника],
    bac_moais: [02.03.03 --- Математическое обеспечение и администрирование информационных систем],
    bac_fiit: [02.03.02 --- Фундаментальная информатика и информационные технологии],
    bac_pi: [09.03.04 --- Программная инженерия],
    mag_ivt: [09.04.01 --- Информатика и вычислительная техника],
    mag_moais: [02.04.03 --- Математическое обеспечение и администрирование информационных систем],
  ),
  error: (
    no_sex: [*6.21 КоАП РФ*],
    undefined_spec: [*НЕИЗВЕСТНАЯ СПЕЦИАЛЬНОСТЬ*],
  ),
)
// Переменная отвечающая за размер отступа красной строки
#let indent = 1.25cm
#let font_size = 14pt
// #let linespace = font_size
#let line_spacing = 1.75em / 2
#let styled = [#set text(red)].func()
#let space = [ ].func()
#let sequence = [].func()


#let modules = (
  /*
   * Модуль информации об авторе Позволяет получать более полную и
   * отформатированную информацию об авторе: студент/студентки/студентов
   * (get_author_sex), номер курса, группы и так далее. Конечно, некоторые из
   * этих вещей в открытом виде лежат в словаре author, но некоторые данные
   * нуждаются в постобработке или вовсе получаются косвенным путём.
   * Необходимость в постобработке может возникнуть и позднее, поэтому
   * настоятельно рекомендуется пользоваться именно этими методами, а не
   * получать код напрямую.
   */
  author_info: (
    /*
     * Определяет студенческо-половую сущность автора.
     * Принимает:
     *  - author - словарь про автора
     * Возвращает:
     *  - В зависимости от пола: "студента", "студентки", "студентов"
     */
    get_author_sex: author => {
      return strings.student.at(
        author.at("sex"),
        default: strings.error.no_sex,
      )
    },
    /*
     * Определяет курс автора (по номеру группы)
     * Принимает:
     *  - author - словарь про автора
     * Возвращает:
     *  - Номер курса в строковом формате
     */
    get_author_course: author => {
      return author.group.at(0)
    },
    /*
     * Определяет группу автора
     * Принимает:
     *  - author - словарь про автора
     * Возвращает:
     *  - Номер группы в строковом формате
     * Примечание: на текущий момент функция ничего не делает, но, возможно,
     * это не навсегда и в будущем здесь что-то может появиться. Чтобы потом не
     * мучиться с рефакторингом, лучше получать номер группы через неё.
     */
    get_author_group: author => {
      return author.group
    },
    /*
     * Определяет код и название направления автора
     * Принимает:
     *  - author - словарь про автора
     * Возвращает:
     *  - author.speciality, если таковой указан
     *  - В противном случае, если студент учится на КНиИТе, для студента
     *    работает аттракцион невиданной технологичности: код и название
     *    специальности определяются автоматически
     */
    get_speciality: author => {
      if author.at("speciality", default: none) != none {
        return author.speciality
      } else if author.faculty == [КНиИТ] {
        let specialities = (
          strings.specialities.bac_fiit,
          strings.specialities.bac_ivt,
          strings.specialities.spec_kb,
          strings.specialities.bac_moais,
          strings.specialities.bac_pi,
          [], // x6x
          strings.specialities.mag_ivt,
          strings.specialities.mag_moais,
          [], // x8x
        )
        if author.group.at(1) == "7" {
          // x7x
          if author.group.at(2) == "1" {
            // x71
            return specialities.at(6) // ивт
          } else if author.group.at(2) == "3" {
            // x73
            return specialities.at(7) // моаис
          }
          return []
        }
        let id = int(author.group.at(1)) - 1

        if id < 0 or id > 8 {
          return []
        }
        return specialities.at(id)
      }
      return strings.error.undefined_spec
    },
  ),
  /*
   * Модуль титульного листа Здесь происходит генерация титульного листа и
   * определяются все необходимые для этого методы. Поскольку его создание ---
   * задача не такая уж и тривиальная, здесь есть много приватных методов и ваш
   * покорный слуга ещё раз напоминает о нежелательности их вызова извне. Если
   * такая необходимость всё же возникает, лучше переименовать метод и убрать
   * подчёркивание: впоследствии это можно будет хотя бы как-то отладить.
   *
   * Изначально задумывалось, что единственный доступный для вызова извне метод
   * --- make, а в остальных не должно возникнуть необходимости.
   */
  title: (
    /*
     * Отвечает за вывод названия министерства и
     * университета на титульном листе
     */
    _default_header: () => {
      set align(center)
      // set text(font: "Tempora")
      text(strings.title.minobrnauki)
      v(0.2em)
      text(weight: "bold", strings.title.sgu)
      set align(left)
    },
    /*
     * Отвечает за вывод тела титульного листа: заголовок (название работы,
     * если не определено иное), тип работы, информация об авторе
     *
     * Информация о проверяющем преподавателе генерируется не здесь по
     * историческим причинам.
     */
    _default_body: data => {
      set align(center)
      v(3cm)
      text(weight: "bold", upper(data.title))
      par(data.worktype)
      v(1.5cm)
      set align(left)
      text(data.group + "\n")
      text(data.speciality + "\n")
      text(data.faculty + "\n" + data.author)
    },
    /*
     * Отвечает за вывод города и года на титульном листе
     */
    _default_footer: () => {
      v(1fr)
      set align(center)
      text(strings.title.city + " " + str(datetime.today().year()))
    },
    /*
     * Подпись "Проверено:" для титульного листа
     */
    _signature: (post, name) => {
      text("Проверено:\n")
      grid(
        columns: (1fr,) * 3,
        align: (left, center, right),
        row-gutter: 5pt,
        post, block(inset: (y: 13pt), line(length: 3cm, stroke: .4pt)), name
      )
    },
    /*
     * Строка "студента такой-то группы" для титульного листа
     */
    _get_author_string: (self, author) => {
      let sex = (self.author_info.get_author_sex)(author)
      let course = (self.author_info.get_author_course)(author)
      let group = (self.author_info.get_author_group)(author)
      if course.len() > 0 {
        course = (self.utils.strglue)(course, strings.title.from_course)
      }
      if group.len() > 0 {
        group = (self.utils.strglue)(group, strings.title.from_group)
      }
      let result = (self.utils.strglue)(sex, course, group)
      return result
    },
    /*
     * Получает заголовок титульного листа.
     * Принимает:
     *  - info - информация о документе
     * Возвращает:
     *  - В зависимости от типа:
     *    - Тему работы, если это не автореферат и не отчёт по НИРу
     *    - В противном случае названия соответствующих типов работ
     */
    _get_title_string: info => {
      if info.type == "autoref" {
        return [АВТОРЕФЕРАТ]
      }
      if info.type == "nir" {
        return [ОТЧЁТ О НАУЧНО-ИССЛЕДОВАТЕЛЬСКОЙ РАБОТЕ]
      }
      return info.at("title", default: [Тема работы])
    },
    /*
     * Генерирует строки текста для вывода на титульном листе
     * Принимает:
     *  - info - информация о документе
     * Возвращает:
     *  - Словарь:
     *     title: Заголовок
     *     worktype: Тип работы
     *     group: студент(а|ки|ов) s курса sex группы
     *     specialty: направления 69.14.88 --- Специальность
     *     faculty: факультета XXX
     *     author: автор(ы)? работы
     */
    _get_strings: (self, info) => {
      let author = info.at("author", default: (:))
      let title_string = (self.title._get_title_string)(info)
      let worktype = strings.title.worktypes.at(info.type, default: [])
      let group_string = (self.title._get_author_string)(self, author)
      let speciality_string = (self.utils.strglue)(
        strings.title.from_speciality,
        (self.author_info.get_speciality)(author),
      )
      let faculty_string = "факультета " + author.faculty
      return (
        title: title_string,
        worktype: worktype,
        group: group_string,
        speciality: speciality_string,
        faculty: faculty_string,
        author: author.name,
      )
    },
    /*
     * Генерирует титульный лист
     * Принимает:
     *  - info - информация о документе
     */
    make: (self, info) => {
      let strs = (self.title._get_strings)(self, info)
      (self.title._default_header)()
      (self.title._default_body)(strs)
      v(1fr)
      (self.title._signature)(info.inspector.degree, info.inspector.name)
      (self.title._default_footer)()
    },
  ),
  /*
   * Модуль генерации документа Здесь содержатся методы, влияющие на вид всего
   * документа в целом. Главный из них --- make --- вызывается из точки входа в
   * стилевой файл и отвечает за всё оформление выходного документа.
   */
  document: (
    apply_heading_styles: it => {
      set text(size: font_size)
      if it.depth == 1 {
        pagebreak(weak: true)
      }
      if (
        strings.caps_headings.contains(it.body)
      ) {
        align(center, it.body)
      } else if (
        it.body.has("children")
          and it.body.at("children").first() == [ПРИЛОЖЕНИЕ]
      ) {
        let children = it.body.at("children")
        let letter = children.at(2)
        let title = children.at(4, default: [])
        align(center, [ПРИЛОЖЕНИЕ #letter \ #title])
      } else {
        pad(left: indent, it)
      }
      v(line_spacing / 2)
    },
    /*
     * Генерирует страницу содержания
     * Принимает:
     *  - info - информация о документе
     */
    make_toc: (info: ()) => {
      show outline.entry.where(level: 1): it => {
        let heading = it.at("element", default: (:)).at("body", default: "")
        if not strings.caps_headings.contains(heading) {
          it
          return
        }
        grid(
          columns: (auto, 1pt, 1fr, 1pt, auto),
          align: (left, center, right),
          row-gutter: 0pt,
          rows: auto,
          inset: 0pt,
          heading, none, it.fill, none, it.page(),
        )
      }
      outline(indent: 2%, title: [СОДЕРЖАНИЕ])
    },
    /*
     * Генерирует весь документ
     * Принимает:
     *  - info - информация о документе
     *  - doc  - содержимое документа
     */
    make: (self, info: (), settings, doc) => {
      set page(
        paper: "a4",
        margin: (
          top: 2cm,
          bottom: 2cm,
          left: 2.5cm,
          right: 1.5cm,
        ),
      )
      set text(size: font_size, lang: "ru", font: "Times New Roman")

      if settings.title_page.at("enabled", default: true) {
        (self.title.make)(self, info)
      }

      show: thmrules.with(qed-symbol: $square$)
      show heading: self.document.apply_heading_styles
      show raw.where(block: true): it => {
        set par(justify: false)
        grid(
          columns: (100%, 100%),
          column-gutter: -100% - 1em,
          block(
            width: 100%,
            inset: 1em,
            for (i, line) in it.text.split("\n").enumerate() {
              box(
                width: 0pt,
                align(right, str(i + 1) + h(2em)),
              )
              hide(line)
              linebreak()
            },
          ),
          block(width: 100%, inset: 1em, it),
        )
      }


      set par(
        // Выравнивание по ширине
        justify: true,
        // отвечает за красные строки там, где их нет, но они должны быть
        first-line-indent: (amount: indent, all: true),
        leading: line_spacing,
        spacing: line_spacing,
      )

      // Вывод содержания
      if settings.contents_page.enabled {
        (self.document.make_toc)(info: info)
      }

      // Оформление элементов содержимого документа
      set heading(numbering: "1.1")
      set page(
        footer: context [
          #h(1fr)
          #counter(page).display("1")
        ],
      )
      set page(numbering: "1")
      set math.equation(numbering: "(1)", supplement: [])
      show figure.where(kind: image): set figure(supplement: "Рисунок")
      show figure.where(kind: table): set figure(supplement: "Таблица")
      show figure.where(kind: table): set figure.caption(position: top)
      show figure.caption.where(kind: table): set align(left)
      set figure.caption(separator: [ -- ])

      set quote(block: true)

      // Примерный размер "---". Определено на глаз, как сделать более точным
      // не разбирался.
      let shift-back-list = 1.5em
      set list(indent: indent - shift-back-list, marker: [#strong([---])])
      let shift-back-enum = 1.25em
      set enum(indent: indent - shift-back-enum)

      // Вывод самого документа
      doc
    },
  ),
  /*
   * Помощник Модуль-помощник не содержит особой функциональности и не имеет
   * конкретного назначения, но содержащиеся в нём методы могут быть полезны
   * где угодно и не привязаны к конкретной части документа
   */
  utils: (
    /*
     * Склеивает строки, игнорируя пустые
     * Принимает:
     *  - divider - разделитель (по умолчанию пробел)
     *  - соединяемые строки в неограниченном количестве
     * Примечание: метод похож по своей сути на join, но отличается от него
     * наличием проверки на пустые строки: рядом с ними разделитель не
     * ставится, что исключает присутствие двух разделителей подряд.
     */
    strglue: (divider: " ", ..strings) => {
      let result = ""
      for string in strings.pos() {
        if (
          (result.len() > 0) and ((type(string) != str) or (string.len() > 0))
        ) {
          result = result + " "
        }
        // TODO: string было бы неплохо обернуть в str(), но баг в системе
        // типов Typst не позволяет этого сделать
        result = result + string
      }
      return result
    },
  ),
)

#let intro = {
  [#heading(numbering: none, outlined: true, [ВВЕДЕНИЕ]) <intro>]
}


#let conclusion = {
  heading(numbering: none, outlined: true, [ЗАКЛЮЧЕНИЕ])
}

#let appendix-letters = "АБВГДЕЖЗИКЛМНОПРСТУФХЦЧШЩЭЮЯ"
#let appendix-counter = counter("appendix")
#let appendix(title) = {
  context {
    let number = appendix-counter.get().first()
    let letter = appendix-letters.clusters().at(number, default: str(number))
    align(
      center,
      heading(
        numbering: none,
        outlined: true,
        [ПРИЛОЖЕНИЕ #letter #title],
      ),
    )
  }
  appendix-counter.step()
}

#let thm-format = thmplain.with(
  inset: 0em,
  padding: (y: font_size / 2),
  titlefmt: strong,
  bodyfmt: emph,
  namefmt: x => [(#x)],
  base: none,
  separator: [#strong(".")#h(0.2em)],
)
#let definition = thm-format("definition", "Определение")
#let theorem = thm-format("theorem", "Теорема")
#let proof = thmproof("proof", "Доказательство")

// TODO: по какой-то причине эта функция всегда вставляет пустую строку в конце
#let source-file(file) = {
  raw(read(file), block: true)
}


/*
 * Точка входа, просто вызывает modules.document.make
 */
#let conf(
  title: none,
  info: (),
  type: "referat",
  settings: (),
  doc,
) = {
  info.title = title
  info.type = type
  settings.title_page = settings.at("title_page", default: (:))
  (modules.document.make)(modules, info: info, settings, doc)
}
